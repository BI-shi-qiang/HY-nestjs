import { ApiProperty } from "@nestjs/swagger";
import { PartialType } from "@nestjs/swagger";
import { IsIn, IsInt, IsNotEmpty, IsOptional, IsString, MaxLength } from "class-validator";

/**
 * 菜品分类创建参数
 */
export class CreateCategoryDto {
  @ApiProperty({ description: "分类名称" })
  @IsNotEmpty({ message: "分类名称不能为空" })
  @IsString()
  @MaxLength(50)
  name: string;

  @ApiProperty({ description: "排序", required: false, default: 0 })
  @IsOptional()
  @IsInt()
  sort?: number;

  @ApiProperty({ description: "状态(1-启用 0-停用)", required: false, default: 1 })
  @IsOptional()
  @IsInt()
  @IsIn([0, 1])
  status?: number;
}

/**
 * 菜品分类更新参数
 */
export class UpdateCategoryDto extends PartialType(CreateCategoryDto) {}
