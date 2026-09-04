import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
  Query,
  UploadedFile,
  UseInterceptors,
} from "@nestjs/common";
import { FileInterceptor } from "@nestjs/platform-express";
import { ApiOperation, ApiTags } from "@nestjs/swagger";

import { CurrentUser } from "@/common/decorators/current-user.decorator";
import { Permissions } from "@/common/decorators/auth.decorator";
import type { CurrentUserInfo } from "@/common/interfaces/current-user.interface";

import { DocumentService } from "./document.service";
import { DocumentQueryDto, SaveDocumentDto } from "./document.dto";
import { toRagUser } from "../rag.types";

@ApiTags("09.知识库文档")
@Controller("rag/documents")
export class DocumentController {
  constructor(private readonly documentService: DocumentService) {}

  @ApiOperation({ summary: "知识文档分页列表" })
  @Get()
  @Permissions("rag:document:list")
  list(@Query() query: DocumentQueryDto) {
    return this.documentService.listDocuments(query);
  }

  @ApiOperation({ summary: "知识文档版本列表" })
  @Get(":documentId/versions")
  @Permissions("rag:document:list")
  versions(@CurrentUser() user: CurrentUserInfo, @Param("documentId") documentId: string) {
    return this.documentService.listVersions(toRagUser(user), documentId);
  }

  @ApiOperation({ summary: "上传创建知识文档" })
  @Post()
  @Permissions("rag:document:create")
  @UseInterceptors(FileInterceptor("file", { limits: { fileSize: 2_000_000 } }))
  create(
    @CurrentUser() user: CurrentUserInfo,
    @Body() body: SaveDocumentDto,
    @UploadedFile() file?: Express.Multer.File
  ) {
    this.assertMarkdown(file);
    return this.documentService.createDocument(toRagUser(user), {
      ...body,
      fileName: file.originalname,
      content: file.buffer,
    });
  }

  @ApiOperation({ summary: "发布知识文档新版本" })
  @Put(":documentId")
  @Permissions("rag:document:update")
  @UseInterceptors(FileInterceptor("file", { limits: { fileSize: 2_000_000 } }))
  update(
    @CurrentUser() user: CurrentUserInfo,
    @Param("documentId") documentId: string,
    @Body() body: SaveDocumentDto,
    @UploadedFile() file?: Express.Multer.File
  ) {
    this.assertMarkdown(file);
    return this.documentService.updateDocument(toRagUser(user), documentId, {
      ...body,
      fileName: file.originalname,
      content: file.buffer,
    });
  }

  @ApiOperation({ summary: "删除知识文档" })
  @Delete(":documentId")
  @Permissions("rag:document:delete")
  delete(@CurrentUser() user: CurrentUserInfo, @Param("documentId") documentId: string) {
    return this.documentService.deleteDocument(toRagUser(user), documentId);
  }

  // 校验文件是否为 markdown 文件
  private assertMarkdown(file?: Express.Multer.File): asserts file is Express.Multer.File {
    if (!file) throw new BadRequestException("请上传文件");
    if (!file.originalname.toLowerCase().endsWith(".md")) {
      throw new BadRequestException("请上传 markdown 文件");
    }
  }
}
