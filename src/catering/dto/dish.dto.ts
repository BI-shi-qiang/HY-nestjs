import { ApiProperty } from "@nestjs/swagger";
import { PartialType } from "@nestjs/swagger";
import { Type } from "class-transformer";
import {
  IsArray,
  IsIn,
  IsInt,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  MaxLength,
} from "class-validator";

/**
 * 菜品创建参数
 */
export class CreateDishDto {
  @ApiProperty({ description: "分类ID" })
  @IsNotEmpty({ message: "分类不能为空" })
  @IsString()
  categoryId: string;

  @ApiProperty({ description: "菜品名称" })
  @IsNotEmpty({ message: "菜品名称不能为空" })
  @IsString()
  @MaxLength(100)
  name: string;

  @ApiProperty({ description: "单价" })
  @IsNotEmpty({ message: "单价不能为空" })
  @Type(() => Number)
  @IsNumber()
  unitPrice: number;

  @ApiProperty({ description: "单位", required: false, default: "份" })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  unit?: string;

  @ApiProperty({ description: "图片数组[{url}]", required: false })
  @IsOptional()
  @IsArray()
  @Type(() => Object)
  image?: { url: string }[];

  @ApiProperty({ description: "排序", required: false, default: 0 })
  @IsOptional()
  @IsInt()
  sort?: number;

  @ApiProperty({ description: "状态(1-上架 0-下架)", required: false, default: 1 })
  @IsOptional()
  @IsInt()
  @IsIn([0, 1])
  status?: number;

  @ApiProperty({ description: "是否沽清(0-正常 1-沽清)", required: false, default: 0 })
  @IsOptional()
  @IsInt()
  @IsIn([0, 1])
  soldOut?: number;

  @ApiProperty({ description: "口味/辣度标签", required: false })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  flavor?: string;

  @ApiProperty({ description: "菜品描述", required: false })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  description?: string;
}

/**
 * 菜品更新参数
 */
export class UpdateDishDto extends PartialType(CreateDishDto) {}

/**
 * 菜品上下架/沽清参数
 */
export class UpdateDishStatusDto {
  @ApiProperty({ description: "状态(1-上架 0-下架)", required: false })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @IsIn([0, 1])
  status?: number;

  @ApiProperty({ description: "是否沽清(0-正常 1-沽清)", required: false })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @IsIn([0, 1])
  soldOut?: number;
}
