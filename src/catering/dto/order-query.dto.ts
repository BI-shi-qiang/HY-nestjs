import { IsOptional, IsString } from "class-validator";
import { BaseQueryDto } from "@/common/dto/base-query.dto";

/**
 * 订单分页查询参数（后台）
 */
export class OrderQueryDto extends BaseQueryDto {
  @IsOptional()
  @IsString()
  tableNumber?: string;

  @IsOptional()
  @IsString()
  transacStatus?: string;

  @IsOptional()
  @IsString()
  orderReceiving?: string;
}
