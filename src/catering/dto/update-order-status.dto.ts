import { ApiProperty } from "@nestjs/swagger";
import { IsOptional, IsString, MaxLength } from "class-validator";

/**
 * 订单状态流转参数（结账/接单等）
 */
export class UpdateOrderStatusDto {
  @ApiProperty({ description: "支付方式(wechat微信 cash现金)", required: false })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  payType?: string;

  @ApiProperty({ description: "备注", required: false })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  remark?: string;
}
