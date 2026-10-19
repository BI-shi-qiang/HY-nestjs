import { IsOptional, IsString } from "class-validator";
import { BaseQueryDto } from "@/common/dto/base-query.dto";

/**
 * 菜品分页查询参数
 */
export class DishQueryDto extends BaseQueryDto {
  @IsOptional()
  @IsString()
  categoryId?: string;

  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsString()
  status?: string;
}
