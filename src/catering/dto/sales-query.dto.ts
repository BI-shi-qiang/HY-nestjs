import { IsOptional, IsString } from "class-validator";

/**
 * 销售统计查询参数
 */
export class SalesQueryDto {
  @IsOptional()
  @IsString()
  date?: string; // YYYY-MM-DD 单日

  @IsOptional()
  @IsString()
  startDate?: string; // YYYY-MM-DD

  @IsOptional()
  @IsString()
  endDate?: string; // YYYY-MM-DD
}
