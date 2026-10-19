import { ApiProperty } from "@nestjs/swagger";
import { IsArray, IsInt, IsNotEmpty, IsOptional, IsString } from "class-validator";
import { Type } from "class-transformer";

/**
 * 点餐下单参数
 */
export class CreateOrderDto {
  @ApiProperty({ description: "桌号" })
  @IsNotEmpty({ message: "桌号不能为空" })
  @IsString()
  table_number: string;

  @ApiProperty({ description: "就餐人数", required: false })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  number_of_diners?: number;

  @ApiProperty({ description: "桌台ID（扫桌台码下单时传）", required: false })
  @IsOptional()
  @IsString()
  table_id?: string;

  @ApiProperty({ description: "支付方式(wechat微信 cash现金)", required: false })
  @IsOptional()
  @IsString()
  pay_type?: string;

  @ApiProperty({ description: "备注", required: false })
  @IsOptional()
  @IsString()
  remark?: string;

  @ApiProperty({ description: "菜品列表（每项含 _id/quantity/unitprice/name/unit/image 等）" })
  @IsArray()
  @IsNotEmpty({ message: "菜品列表不能为空" })
  @Type(() => Object)
  goods_list: Record<string, any>[];
}
