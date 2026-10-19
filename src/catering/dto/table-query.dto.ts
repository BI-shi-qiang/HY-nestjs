import { IsOptional, IsString } from "class-validator";
import { BaseQueryDto } from "@/common/dto/base-query.dto";

/**
 * 桌台分页查询参数
 */
export class TableQueryDto extends BaseQueryDto {
  @IsOptional()
  @IsString()
  tableNo?: string;

  @IsOptional()
  @IsString()
  status?: string;
}
