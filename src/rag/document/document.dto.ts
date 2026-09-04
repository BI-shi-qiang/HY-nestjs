import { IsIn, IsNotEmpty, IsOptional, IsString, MaxLength } from "class-validator";
import { BaseQueryDto } from "@/common/dto/base-query.dto";

export class SaveDocumentDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  title: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(64)
  departmentId: string;

  @IsIn(["company", "department"])
  visibility: "company" | "department";
}

/** 知识文档分页查询参数 */
export class DocumentQueryDto extends BaseQueryDto {
  @IsOptional()
  @IsString()
  keywords?: string;
}
