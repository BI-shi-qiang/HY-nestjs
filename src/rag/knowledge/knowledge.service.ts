import { Injectable } from "@nestjs/common";
import { AiService } from "../ai/ai.service";
import { MilvusService } from "../milvus/milvus.service";
import type { RagUser } from "../rag.types";

@Injectable()
export class KnowledgeService {
  constructor(
    private readonly ai: AiService,
    private readonly milvus: MilvusService
  ) {}

  async query(user: RagUser, question: string) {
    const startedAt = performance.now();

    // 生成问题向量
    const [queryVector] = await this.ai.createEmbedding([question]);

    // Dense + BM25混合检索，查出相关的几个文档
    const retrieval = await this.milvus.hybridSearch(user, question, queryVector);

    // rerank 精排
    const reranked = await this.ai.rerank(question, retrieval.chunks, 4);

    // 生成回答
    const groundedAnswer = await this.ai.generateAnswer(question, reranked);

    // 信息来源
    const chunkById = new Map(reranked.map((chunk) => [chunk.chunkId, chunk]));
    const sources = groundedAnswer.sourceChunkIds.map((chunkId) => {
      const chunk = chunkById.get(chunkId);
      if (!chunk) throw new Error(`未找到文档 ${chunkId}`);

      return {
        chunkId: chunk.chunkId,
        documentId: chunk.documentId,
        title: chunk.title,
        version: chunk.version,
        chunkIndex: chunk.chunkIndex,
        sourcePath: chunk.sourcePath,
        content: chunk.content,
      };
    });

    return {
      status: groundedAnswer.status,
      answer: groundedAnswer.answer,
      sources,
      pipeline: {
        permissionFilter: retrieval.filter,
        recalledCount: retrieval.chunks.length,
        rerankedCount: reranked.length,
        latencyMs: Math.round(performance.now() - startedAt),
        candidates: reranked.map((chunk, index) => ({
          rank: index + 1,
          chunkId: chunk.chunkId,
          title: chunk.title,
          version: chunk.version,
          retrievalScore: chunk.retrievalScore,
          rerankScore: chunk.rerankScore,
          content: chunk.content,
        })),
      },
    };
  }
}
