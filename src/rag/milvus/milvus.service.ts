import {
  Injectable,
  Logger,
  OnModuleInit,
  OnApplicationShutdown,
  ServiceUnavailableException,
} from "@nestjs/common";
import {
  MilvusClient,
  DataType,
  IndexType,
  MetricType,
  RRFRanker,
  FunctionType,
} from "@zilliz/milvus2-sdk-node";
import { ConfigService } from "@nestjs/config";
import type { KnowledgeChunkRow, RetrievedChunk } from "./milvus.types";
import type { RagUser } from "../rag.types";
import { buildPermissionFilter } from "./filter";

const OUTPUT_FIELDS = [
  "chunk_id",
  "tenant_id",
  "document_id",
  "version",
  "chunk_index",
  "is_active",
  "department_id",
  "visibility",
  "title",
  "source_path",
  "checksum",
  "content",
  "updated_at",
];

@Injectable()
export class MilvusService implements OnModuleInit, OnApplicationShutdown {
  // 这个implements后面的两个是nest的钩子函数，分别是 ： 应用都启动后就自动连接milvus 和 关闭服务时断开连接
  private readonly client: MilvusClient;
  private readonly collectionName: string;
  private readonly dimensions: number;
  private readonly logger = new Logger(MilvusService.name);
  // Milvus 是否已连接并就绪
  private ready = false;

  // 初始化连接对象
  constructor(private readonly configService: ConfigService) {
    const configuredAddress = this.configService.get<string>("MILVUS_ADDRESS") ?? "127.0.0.1:19530";
    const address = configuredAddress.replace(/(^|:\/\/)localhost(?=:\d+$)/, "$127.0.0.1");

    this.collectionName =
      this.configService.get<string>("MILVUS_COLLECTION") ?? "enterprise_knowledge_chunks";
    this.dimensions = Number(this.configService.get<number>("EMBEDDING_DIMENSION") ?? 512);
    // 数据库连接对象
    this.client = new MilvusClient({
      address,
      token: this.configService.get<string>("MILVUS_TOKEN")?.trim() || undefined,
    });
  }

  // 连接函数：连不上 Milvus 时不阻塞整个后端启动，只记录警告，调用 RAG 接口时再报错
  async onModuleInit(): Promise<void> {
    try {
      await this.client.connectPromise;
      await this.ensureCollection();
      this.ready = true;
      this.logger.log(`Milvus 已连接，collection: ${this.collectionName}`);
    } catch (error) {
      this.logger.warn(
        `无法连接或初始化 Milvus，RAG 相关接口暂不可用: ${
          error instanceof Error ? error.message : String(error)
        }`
      );
    }
  }

  // 关闭连接函数
  async onApplicationShutdown(): Promise<void> {
    if (!this.ready) return;
    await this.client.closeConnection();
  }

  // 校验 Milvus 是否就绪，未就绪时抛出明确错误
  private assertReady(): void {
    if (!this.ready) {
      throw new ServiceUnavailableException("Milvus 未连接，知识库功能暂不可用");
    }
  }

  // 检查连接
  private ensureOk(response: unknown, action: string): void {
    const wrapper = response as Record<string, unknown> | undefined;
    const status = (wrapper?.status as Record<string, unknown> | undefined) ?? wrapper;
    const code = Number(status?.code ?? 0);
    const errorCode = status?.error_code;

    if (code !== 0 || (errorCode && errorCode !== "Success")) {
      throw new Error(`${action}失败：${JSON.stringify(status)}`);
    }
  }

  // 创建加载企业知识库
  private async ensureCollection() {
    const exists = await this.client.hasCollection({
      collection_name: this.collectionName,
    });

    if (!exists.value) {
      const result = await this.client.createCollection({
        collection_name: this.collectionName,
        num_partitions: 16,
        fields: [
          {
            name: "chunk_id",
            data_type: DataType.VarChar,
            is_primary_key: true,
            max_length: 256,
          },
          {
            name: "tenant_id",
            data_type: DataType.VarChar,
            max_length: 64,
            is_partition_key: true,
          },
          {
            name: "document_id",
            data_type: DataType.VarChar,
            max_length: 64,
          },
          {
            name: "version",
            data_type: DataType.Int32,
          },
          {
            name: "chunk_index",
            data_type: DataType.Int32,
          },
          {
            name: "is_active",
            data_type: DataType.Bool,
          },
          {
            name: "department_id",
            data_type: DataType.VarChar,
            max_length: 64,
          },
          {
            name: "visibility",
            data_type: DataType.VarChar,
            max_length: 32,
          },
          {
            name: "title",
            data_type: DataType.VarChar,
            max_length: 256,
          },
          {
            name: "source_path",
            data_type: DataType.VarChar,
            max_length: 512,
          },
          {
            name: "checksum",
            data_type: DataType.VarChar,
            max_length: 64,
          },
          {
            name: "content",
            data_type: DataType.VarChar,
            max_length: 8192,
            enable_analyzer: true,
            enable_match: true,
            analyzer_params: {
              tokenizer: "jieba",
              filter: ["removepunct"],
            },
          },
          {
            name: "dense_vector",
            data_type: DataType.FloatVector,
            dim: this.dimensions,
          },
          {
            name: "sparse_vector",
            data_type: DataType.SparseFloatVector,
          },
          {
            name: "updated_at",
            data_type: DataType.Int64,
          },
        ],
        functions: [
          {
            name: "content_bm25",
            type: FunctionType.BM25,
            input_field_names: ["content"],
            output_field_names: ["sparse_vector"],
            params: {},
          },
        ],
        index_params: [
          {
            field_name: "dense_vector",
            index_type: IndexType.AUTOINDEX,
            metric_type: MetricType.COSINE,
          },
          {
            field_name: "sparse_vector",
            index_type: IndexType.SPARSE_INVERTED_INDEX,
            metric_type: MetricType.BM25,
            params: { inverted_index_algo: "DAAT_MAXSCORE" },
          },
        ],
      });

      this.ensureOk(result, "创建 Collection");
    }

    await this.client.loadCollection({
      collection_name: this.collectionName,
    });
  }

  // 查询
  async query(filter: string, limit = 5000): Promise<Record<string, unknown>[]> {
    this.assertReady();
    const result = await this.client.query({
      collection_name: this.collectionName,
      filter,
      output_fields: OUTPUT_FIELDS,
      limit,
    });

    return (result.data ?? []) as Record<string, unknown>[];
  }

  // 批量写入新Chunk
  async insertChunks(rows: KnowledgeChunkRow[]): Promise<void> {
    this.assertReady();
    const result = await this.client.insert({
      collection_name: this.collectionName,
      data: rows,
    });
    this.ensureOk(result, "批量写入新Chunk");
    await this.client.flushSync({ collection_names: [this.collectionName] });
  }

  // 切换一组chunk 的生效状态
  async setActive(
    rows: Array<{ chunkId: string; tenantId: string }>,
    isActive: boolean
  ): Promise<void> {
    if (rows.length === 0) return;
    this.assertReady();

    const result = await this.client.upsert({
      collection_name: this.collectionName,
      partial_update: true,
      data: rows.map((row) => ({
        chunk_id: row.chunkId,
        tenant_id: row.tenantId,
        is_active: isActive,
      })),
    });
    this.ensureOk(result, "切换一组chunk 的生效状态");
    await this.client.flushSync({ collection_names: [this.collectionName] });
  }

  // Dense + BM25 混合检索
  async hybridSearch(
    user: RagUser,
    question: string,
    queryVector: number[],
    limit = 8
  ): Promise<{ filter: string; chunks: RetrievedChunk[] }> {
    this.assertReady();
    const filter = buildPermissionFilter(user);
    const result = await this.client.hybridSearch({
      collection_name: this.collectionName,
      data: [
        {
          anns_field: "dense_vector",
          data: queryVector,
          limit: 12,
          expr: filter,
        },
        {
          anns_field: "sparse_vector",
          data: question,
          limit: 12,
          expr: filter,
        },
      ],
      rerank: RRFRanker(60),
      limit,
      output_fields: OUTPUT_FIELDS,
    });

    const rows = result.results as Record<string, unknown>[];
    return {
      filter,
      chunks: rows.map((row) => this.toRetrievedChunk(row)),
    };
  }

  // 将搜索结果转换成统一chunk结构
  private toRetrievedChunk(row: Record<string, unknown>): RetrievedChunk {
    return {
      chunkId: String(row.chunk_id ?? row.id),
      tenantId: String(row.tenant_id),
      documentId: String(row.document_id),
      version: Number(row.version),
      chunkIndex: Number(row.chunk_index),
      departmentId: String(row.department_id),
      visibility: row.visibility as "company" | "department",
      title: String(row.title),
      sourcePath: String(row.source_path),
      checksum: String(row.checksum),
      content: String(row.content),
      retrievalScore: Number(row.score ?? 0),
    };
  }
}
