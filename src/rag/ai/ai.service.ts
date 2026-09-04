import { Injectable, ServiceUnavailableException } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { GroundedAnswer, RerankedChunk } from "./ai.types";
import type { RetrievedChunk } from "../milvus/milvus.types";

const SUPPORTED_DIMENSIONS = new Set([256, 512, 1024, 2048]);
const REFUSAL_ANSWER = "根据当前知识库资料，无法回答这个问题。";

@Injectable()
export class AiService {
  private readonly apiKey: string | undefined;
  private readonly embeddingModel: string | undefined;
  private readonly rerankModel: string;
  private readonly chatModel: string;
  private readonly dimensions: number;

  // 构造函数中初始化配置
  constructor(private readonly configService: ConfigService) {
    // configService 从环境变量中获取配置项
    this.apiKey = this.configService.get<string>("ZHIPU_API_KEY")?.trim();
    this.embeddingModel = this.configService.get<string>("EMBEDDING_MODEL") ?? "embedding-3";
    this.rerankModel = this.configService.get<string>("RERANK_MODEL") ?? "rerank";
    this.chatModel = this.configService.get<string>("CHAT_MODEL") ?? "glm-4.7-flash";
    this.dimensions = Number(this.configService.get<number>("EMBEDDING_DIMENSION") ?? 512);
  }

  // 使用内置方法处理异常
  private assertConfig(): string {
    if (!this.apiKey) {
      throw new ServiceUnavailableException("智谱api无法调用!");
    }

    if (!SUPPORTED_DIMENSIONS.has(this.dimensions)) {
      throw new ServiceUnavailableException(
        "EMBEDDING_DIMENSION配置错误, 仅支持256, 512, 1024, 2048"
      );
    }

    return this.apiKey;
  }

  // 发请求，支持重试3次
  private async fetchWithRetry(url: string, init: RequestInit, maxAttempts = 3): Promise<Response> {
    let response: Response | undefined;

    for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
      response = await fetch(url, init);
      const retryable = response.status >= 429 || response.status >= 500;
      if (!retryable || attempt === maxAttempts) return response;
      await new Promise((resolve) => setTimeout(resolve, 400 * 2 ** (attempt - 1)));
    }
    throw new ServiceUnavailableException("智谱api调用失败, 请稍后再试!");
  }

  // 校验模型返回结果
  private validateAnswer(value: unknown, chunks: RerankedChunk[]): GroundedAnswer {
    if (!value || typeof value !== "object") {
      throw new ServiceUnavailableException(`生成模型没有返回有效的JSON`);
    }

    const answer = value as Partial<GroundedAnswer>;
    if (answer.status === "insufficient_evidence") {
      return this.createRefusal();
    }

    if (
      answer.status !== "answered" ||
      typeof answer.answer !== "string" ||
      !answer.answer.trim() ||
      !Array.isArray(answer.sourceChunkIds) ||
      answer.sourceChunkIds.length === 0
    ) {
      throw new ServiceUnavailableException(`生成模型回答结构不完整`);
    }

    // 校验引用的 Chunk ID 必须来自本次候选集，防止模型编造不存在的引用。
    const allowedIds = new Set(chunks.map((chunk) => chunk.chunkId));
    const sourceChunkIds = [...new Set(answer.sourceChunkIds)];
    if (sourceChunkIds.some((chunkId) => !allowedIds.has(chunkId))) {
      throw new ServiceUnavailableException("模型引用了不存在的 Chunk ID。");
    }

    return {
      status: "answered",
      answer: answer.answer.trim(),
      sourceChunkIds,
    };
  }

  // embedding模型 将文件转向量，在document中用于处理文档，然后存入库中
  async createEmbedding(inputs: string[]): Promise<number[][]> {
    const apiKey = this.assertConfig();
    const output: number[][] = [];

    for (let start = 0; start < inputs.length; start += 64) {
      const batch = inputs.slice(start, start + 64);
      const response = await this.fetchWithRetry(
        "https://open.bigmodel.cn/api/paas/v4/embeddings",
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${apiKey}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            model: this.embeddingModel,
            input: batch,
            dimensions: this.dimensions,
          }),
        }
      );
      const result = (await response.json()) as {
        data?: Array<{ index: number; embedding: number[] }>;
        error?: unknown;
      };

      if (!response.ok || !Array.isArray(result.data)) {
        throw new ServiceUnavailableException(
          `embedding api调用失败, 请稍后再试! ${response.status} ${JSON.stringify(result)}`
        );
      }

      output.push(
        ...result.data
          .sort((first, second) => first.index - second.index)
          .map((item) => item.embedding)
      );
    }

    return output;
  }

  // Rerank模型 将查询出来的结果再精排序，选出最相关的
  async rerank(question: string, chunks: RetrievedChunk[], topN = 4): Promise<RerankedChunk[]> {
    if (chunks.length === 0) return [];
    const apiKey = this.assertConfig();
    const response = await this.fetchWithRetry("https://open.bigmodel.cn/api/paas/v4/rerank", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: this.rerankModel,
        query: question,
        documents: chunks.map((chunk) => `${chunk.title}\n${chunk.content}`),
        top_n: Math.min(topN, chunks.length),
        return_documents: false,
        return_raw_scores: true,
      }),
    });

    const result = (await response.json()) as {
      results?: Array<{ index: number; relevance_score: number }>;
    };

    if (!response.ok || !Array.isArray(result.results)) {
      throw new ServiceUnavailableException(
        `rerank api调用失败, 请稍后再试! ${response.status} ${JSON.stringify(result)}`
      );
    }

    return result.results.map((item) => {
      const chunk = chunks[item.index];
      if (!chunk) {
        throw new ServiceUnavailableException(`rerank api返回了无效文档下标：${item.index}`);
      }
      return { ...chunk, rerankScore: Number(item.relevance_score) };
    });
  }

  // chat模型 将根据Rerank后的结果+问题，生成有依据的回答
  async generateAnswer(question: string, chunks: RerankedChunk[]): Promise<GroundedAnswer> {
    if (chunks.length === 0) return this.createRefusal();
    const apiKey = this.assertConfig();
    const response = await this.fetchWithRetry(
      "https://open.bigmodel.cn/api/paas/v4/chat/completions",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${apiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: this.chatModel,
          messages: this.buildAnswerMessages(question, chunks),
          response_format: { type: "json_object" },
          thinking: { type: "disabled" },
          temperature: 0,
          stream: false,
        }),
      }
    );
    const result = (await response.json()) as {
      choices?: Array<{ message?: { content?: string } }>;
    };

    if (!response.ok) {
      throw new ServiceUnavailableException(
        `chat api调用失败, 请稍后再试! ${response.status} ${JSON.stringify(result)}`
      );
    }

    const content = result.choices?.[0]?.message?.content;
    if (!content) {
      throw new ServiceUnavailableException(`生成模型没有返回内容`);
    }

    let parsed: unknown;
    try {
      parsed = JSON.parse(content);
    } catch {
      throw new ServiceUnavailableException(`生成模型没有返回有效的JSON`);
    }

    return this.validateAnswer(parsed, chunks);
  }

  // 构建chat模型的请求消息
  private buildAnswerMessages(question: string, chunks: RerankedChunk[]) {
    return [
      {
        role: "system",
        content: `你是企业知识库问答助手，也是阿毕助手，问道有关阿毕，也就是毕世强的一些个人信息时，可以略带闲谈的语气，返回几条相关信息就行，不用很正式返回全部信息，只能根据本次提供的知识库 Chunk 回答。
        规则：
        1.Chunk 能直接支持答案时，返回 status=answered, 并给出 answer 和直接支持答案的sourceChunkIds。
        2.Chunk 无法支持答案时，不得使用模型自身知识补充或猜测。返回status=insufficient_evidence、answer="${REFUSAL_ANSWER}"、sourceChunkIds=[]。
        3.sourceChunkIds 只能从本次提供的chunk ID 中选择。
        4.资料给出了明确的金额、时间或条件阈值时，可以用用户提供的数据做简单比较，这仍然属于有依据的回答。
        5.回答“会不会、是否”这类问题时，第一句直接写“会”或者“不会”,不要含糊的“是的”或“不是”。
        6.只返回 JSON：{"status":"answered 或 insufficient_evidence", "answer":"答案","sourceChunkIds":["Chunk ID"]}
        `,
      },
      {
        role: "user",
        content: `用户问题：${question}\n\n知识库 Chunk: \n${JSON.stringify(
          chunks.map((chunk) => ({
            id: chunk.chunkId,
            title: chunk.title,
            content: chunk.content,
          })),
          null,
          2
        )}`,
      },
    ];
  }

  // 拒绝回答
  private createRefusal(): GroundedAnswer {
    return {
      status: "insufficient_evidence",
      answer: REFUSAL_ANSWER,
      sourceChunkIds: [],
    };
  }
}
