import { ApiProperty } from "@nestjs/swagger";
import { PartialType } from "@nestjs/swagger";
import { Type } from "class-transformer";
import { IsIn, IsInt, IsNotEmpty, IsOptional, IsString, MaxLength } from "class-validator";

/**
 * 桌台创建参数
 */
export class CreateTableDto {
  @ApiProperty({ description: "桌号" })
  @IsNotEmpty({ message: "桌号不能为空" })
  @IsString()
  @MaxLength(20)
  tableNo: string;

  @ApiProperty({ description: "区域（大厅/包间）", required: false })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  area?: string;

  @ApiProperty({ description: "座位数", required: false, default: 0 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  seatCount?: number;

  @ApiProperty({ description: "状态(1-空闲 2-就餐中 3-待结账)", required: false, default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @IsIn([1, 2, 3])
  status?: number;

  @ApiProperty({ description: "二维码", required: false })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  qrCode?: string;

  @ApiProperty({ description: "排序", required: false, default: 0 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  sort?: number;

  @ApiProperty({ description: "备注", required: false })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  remark?: string;
}

/**
 * 桌台更新参数
 */
export class UpdateTableDto extends PartialType(CreateTableDto) {}
