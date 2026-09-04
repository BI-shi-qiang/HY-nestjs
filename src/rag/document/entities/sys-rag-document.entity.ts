import { Column, Entity } from "typeorm";
import { BaseEntity } from "@/common/entities/base.entity";

/**
 * RAG 知识文档元数据表
 * 每行对应一个已上传的知识文档；chunk 与向量存 Milvus（用本表 id 关联）
 */
@Entity("sys_rag_document")
export class SysRagDocument extends BaseEntity {
  @Column({ length: 120, comment: "文档标题" })
  title: string;

  @Column({ name: "department_id", length: 64, comment: "所属部门ID" })
  departmentId: string;

  @Column({ length: 16, comment: "可见性（company-公司 / department-部门）" })
  visibility: "company" | "department";

  @Column({ type: "int", default: 0, comment: "当前版本号" })
  version: number;

  @Column({ name: "chunk_count", type: "int", default: 0, comment: "当前版本 chunk 数" })
  chunkCount: number;

  @Column({ length: 64, nullable: true, comment: "内容校验和（用于判断是否变化）" })
  checksum: string | null;

  @Column({ name: "source_path", length: 512, nullable: true, comment: "原始 markdown 存储路径" })
  sourcePath: string | null;
}
