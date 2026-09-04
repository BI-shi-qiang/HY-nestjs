import { Injectable, NotFoundException, BadRequestException } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import * as path from "path";
import { mkdir, writeFile } from "node:fs/promises";
import { createHash } from "node:crypto";

import { AiService } from "../ai/ai.service";
import { MilvusService } from "../milvus/milvus.service";
import type { RagUser } from "../rag.types";
import type { DocumentSummary, SaveDocumentInput, TextChunk } from "./document.types";
import { buildDocumentFilter } from "../milvus/filter";
import { chunkMarkdown, normalizeMarkdown } from "./markdown-chunker";
import type { KnowledgeChunkRow } from "../milvus/milvus.types";
import { SysRagDocument } from "./entities/sys-rag-document.entity";
import type { DocumentQueryDto } from "./document.dto";

@Injectable()
export class DocumentService {
  private readonly storageRoot: string;
  private readonly locks = new Map<string, Promise<void>>();

  constructor(
    private readonly configService: ConfigService,
    private readonly ai: AiService,
    private readonly milvus: MilvusService,
    @InjectRepository(SysRagDocument)
    private readonly documentRepository: Repository<SysRagDocument>
  ) {
    this.storageRoot =
      configService.get<string>("RAG_STORAGE_ROOT") ?? path.resolve(process.cwd(), "data/rag");
  }

  // 分页查询文档列表（MySQL 元数据）
  async listDocuments(query: DocumentQueryDto) {
    const page = query.pageNum || 1;
    const size = query.pageSize || 10;

    const qb = this.documentRepository
      .createQueryBuilder("d")
      .where("d.isDeleted = :isDeleted", { isDeleted: 0 });

    if (query.keywords) {
      qb.andWhere("d.title LIKE :keywords", { keywords: `%${query.keywords}%` });
    }

    qb.orderBy("d.createTime", "DESC");

    const [list, total] = await qb
      .skip((page - 1) * size)
      .take(size)
      .getManyAndCount();

    return {
      data: list,
      page: { pageNum: page, pageSize: size, total },
    };
  }

  // 查询一份文档的全部版本（从 Milvus 聚合历史版本）
  async listVersions(
    user: RagUser,
    documentId: string
  ): Promise<Array<DocumentSummary & { isActive: boolean }>> {
    const rows = await this.milvus.query(buildDocumentFilter(user.tenantId, documentId));
    if (rows.length === 0) throw new NotFoundException("没有找到这个文档");

    const versions = new Map<number, Record<string, unknown>[]>();
    for (const row of rows) {
      const version = Number(row.version);
      const versionRows = versions.get(version) ?? [];
      versionRows.push(row);
      versions.set(version, versionRows);
    }

    return [...versions.entries()]
      .map(([version, versionRows]) => ({
        ...this.summarize(versionRows)[0],
        version,
        isActive: Boolean(versionRows[0].is_active),
      }))
      .sort((first, second) => second.version - first.version);
  }

  // 创建新文档：先建 MySQL 元数据行拿 id，再入库
  async createDocument(user: RagUser, input: SaveDocumentInput) {
    const doc = this.documentRepository.create({
      title: input.title,
      departmentId: input.departmentId,
      visibility: input.visibility,
      version: 0,
      chunkCount: 0,
    });
    const saved = await this.documentRepository.save(doc);
    const documentId = String(saved.id);

    return this.saveVersion(user, documentId, input);
  }

  // 为已有文档发布新版本
  async updateDocument(user: RagUser, documentId: string, input: SaveDocumentInput) {
    const doc = await this.documentRepository.findOne({
      where: { id: documentId, isDeleted: 0 },
    });
    if (!doc) throw new NotFoundException("没有找到需要更新的文档");

    return this.saveVersion(user, documentId, input);
  }

  // 删除文档（MySQL 软删除 + Milvus 活跃 chunk 置为非活跃）
  async deleteDocument(user: RagUser, documentId: string) {
    return this.withLock(`${user.tenantId}:${documentId}`, async () => {
      const doc = await this.documentRepository.findOne({
        where: { id: documentId, isDeleted: 0 },
      });
      if (!doc) throw new NotFoundException("没有找到这个文档");

      // MySQL 软删除
      doc.isDeleted = 1;
      await this.documentRepository.save(doc);

      // Milvus 中该文档的活跃 chunk 全部置为非活跃
      const rows = await this.milvus.query(buildDocumentFilter(user.tenantId, documentId, true));
      if (rows.length > 0) {
        await this.milvus.setActive(
          rows.map((row) => ({
            chunkId: String(row.chunk_id),
            tenantId: user.tenantId,
          })),
          false
        );
      }

      return { status: "success", documentId };
    });
  }

  // 文档入库主流程：
  // 1. 统一文档格式  2. 切分 chunk  3. 读取元数据/判断变化
  // 4. 向量化  5. 组装 chunk  6. 写源文件  7. 写 Milvus
  // 8. 切换新版本生效  9. 回写 MySQL 元数据
  private async saveVersion(user: RagUser, documentId: string, input: SaveDocumentInput) {
    return this.withLock(`${user.tenantId}:${documentId}`, async () => {
      // 1. 统一文档格式
      const markdown = normalizeMarkdown(input.content.toString("utf8"));
      if (!markdown) throw new BadRequestException("文档不能为空");

      // 2. 切分 chunk
      const chunks = chunkMarkdown(markdown);
      if (chunks.length === 0) {
        throw new BadRequestException("文档中没有可以入库的正文");
      }

      // 3. 读取 MySQL 元数据
      const doc = await this.documentRepository.findOne({
        where: { id: documentId, isDeleted: 0 },
      });
      if (!doc) throw new NotFoundException("没有找到需要更新的文档");

      // 4. 校验内容是否变化
      const checksum = this.hash(markdown);
      const unchanged =
        doc.version > 0 &&
        String(doc.checksum) === checksum &&
        String(doc.title) === input.title &&
        String(doc.departmentId) === input.departmentId &&
        String(doc.visibility) === input.visibility;

      if (unchanged) {
        return { status: "skipped", reason: "文档内容未改变，无需更新", documentId };
      }

      // 5. 新版本号 + 源文件路径
      const version = doc.version + 1;
      const sourcePath = path.posix.join(user.tenantId, documentId, `v${version}.md`);

      // 6. 向量化
      const vectors = await this.ai.createEmbedding(chunks.map((chunk) => chunk.content));

      // 7. 组装 chunk + vector + metadata
      const rows = this.createRows({
        user,
        documentId,
        version,
        checksum,
        sourcePath,
        input,
        chunks,
        vectors,
      });

      // 8. 记录原始文档内容
      await this.writeSource(sourcePath, markdown);

      // 9. 写入 Milvus
      await this.milvus.insertChunks(rows);

      // 10. 切换新版本 chunk 为生效状态
      const previous = await this.milvus.query(
        buildDocumentFilter(user.tenantId, documentId, true)
      );
      const prevChunks = previous.map((row) => ({
        chunkId: String(row.chunk_id),
        tenantId: user.tenantId,
      }));
      const nextChunks = rows.map((row) => ({
        chunkId: row.chunk_id,
        tenantId: user.tenantId,
      }));

      if (prevChunks.length > 0) {
        await this.milvus.setActive(prevChunks, false);
      }
      try {
        await this.milvus.setActive(nextChunks, true);
      } catch (error) {
        if (prevChunks.length > 0) {
          await this.milvus.setActive(prevChunks, true);
        }
        throw error;
      }

      // 11. 回写 MySQL 元数据
      doc.title = input.title;
      doc.departmentId = input.departmentId;
      doc.visibility = input.visibility;
      doc.version = version;
      doc.chunkCount = chunks.length;
      doc.checksum = checksum;
      doc.sourcePath = sourcePath;
      await this.documentRepository.save(doc);

      return {
        status: version === 1 ? "created" : "updated",
        documentId,
        version,
        chunkCount: chunks.length,
      };
    });
  }

  // 组装 chunk + vector + metadata 的函数
  private createRows(options: {
    user: RagUser;
    documentId: string;
    version: number;
    checksum: string;
    sourcePath: string;
    input: SaveDocumentInput;
    chunks: TextChunk[];
    vectors: number[][];
  }): KnowledgeChunkRow[] {
    const updateAt = Date.now();
    return options.chunks.map((chunk, index) => ({
      chunk_id: `${options.user.tenantId}:${options.documentId}:v${options.version}:${chunk.index}:${this.hash(chunk.content).slice(0, 12)}`,
      tenant_id: options.user.tenantId,
      document_id: options.documentId,
      version: options.version,
      chunk_index: chunk.index,
      is_active: false,
      department_id: options.input.departmentId,
      visibility: options.input.visibility,
      title: options.input.title,
      source_path: options.sourcePath,
      checksum: options.checksum,
      content: chunk.content,
      dense_vector: options.vectors[index],
      updated_at: updateAt,
    }));
  }

  // 文档摘要
  private summarize(rows: Record<string, unknown>[]): DocumentSummary[] {
    const documents = new Map<string, Record<string, unknown>[]>();
    for (const row of rows) {
      const key = `${String(row.document_id)};${Number(row.version)}`;
      const documentRows = documents.get(key) ?? [];
      documentRows.push(row);
      documents.set(key, documentRows);
    }

    return [...documents.values()]
      .map((documentRows) => {
        const first = documentRows[0];
        return {
          documentId: String(first.document_id),
          title: String(first.title),
          version: Number(first.version),
          departmentId: String(first.department_id),
          visibility: first.visibility as "company" | "department",
          checksum: String(first.checksum),
          sourcePath: String(first.source_path),
          chunkCount: documentRows.length,
          updatedAt: Number(first.updated_at),
        };
      })
      .sort((first, second) => second.updatedAt - first.updatedAt);
  }

  // 按照租户文档版本保存原始文档内容
  private async writeSource(relativePath: string, markdown: string) {
    const fullPath = path.join(this.storageRoot, ...relativePath.split("/"));
    await mkdir(path.dirname(fullPath), { recursive: true });
    await writeFile(fullPath, markdown, "utf8");
  }

  // 去重重复 chunkId
  private hash(text: string): string {
    return createHash("sha256").update(text).digest("hex");
  }

  // 单进程锁（同一时间如果出现多个请求，只允许一个请求执行）
  private async withLock<T>(key: string, task: () => Promise<T>): Promise<T> {
    while (this.locks.has(key)) await this.locks.get(key);

    let release: () => void = () => {};
    const lock = new Promise<void>((resolve) => {
      release = resolve;
    });
    this.locks.set(key, lock);

    try {
      return await task();
    } finally {
      release();
      this.locks.delete(key);
    }
  }
}
