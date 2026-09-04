import { Body, Controller, HttpCode, HttpStatus, Post } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";

import { CurrentUser } from "@/common/decorators/current-user.decorator";
import { Public } from "@/common/decorators/auth.decorator";
import type { CurrentUserInfo } from "@/common/interfaces/current-user.interface";

import { KnowledgeService } from "./knowledge.service";
import { QueryKnowledgeDto } from "./knowledge.dto";
import { RAG_TENANT_ID, toRagUser } from "../rag.types";
import type { RagUser } from "../rag.types";

@ApiTags("09.知识问答")
@Controller("rag/knowledge")
export class KnowledgeController {
  constructor(private readonly knowledgeService: KnowledgeService) {}

  @ApiOperation({ summary: "知识库问答" })
  @Post("query")
  @HttpCode(HttpStatus.OK)
  query(@CurrentUser() user: CurrentUserInfo, @Body() body: QueryKnowledgeDto) {
    return this.knowledgeService.query(toRagUser(user), body.question.trim());
  }

  @ApiOperation({ summary: "知识库问答（公开，免登录）" })
  @Public()
  @Post("public")
  @HttpCode(HttpStatus.OK)
  queryPublic(@Body() body: QueryKnowledgeDto) {
    // 匿名用户：非管理员、无部门 → 只能检索到「全公司可见」的文档
    const anonymousUser: RagUser = {
      tenantId: RAG_TENANT_ID,
      userId: "",
      departmentId: "",
      isAdmin: false,
    };
    return this.knowledgeService.query(anonymousUser, body.question.trim());
  }
}
