import { Module } from "@nestjs/common";

import { AiModule } from "./ai/ai.module";
import { MilvusModule } from "./milvus/milvus.module";
import { DocumentsModule } from "./document/document.module";
import { KnowledgeModule } from "./knowledge/knowledge.module";

/**
 * RAG（检索增强生成）模块
 * 聚合 AI、Milvus 向量库、知识文档、知识问答四个子模块
 */
@Module({
  imports: [AiModule, MilvusModule, DocumentsModule, KnowledgeModule],
})
export class RagModule {}
