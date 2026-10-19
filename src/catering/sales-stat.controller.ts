import { Controller, Get, Query } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";

import { Permissions } from "../common/decorators/auth.decorator";
import { OrderService } from "./order.service";
import { SalesQueryDto } from "./dto/sales-query.dto";

/**
 * 销售统计（后台）
 */
@ApiTags("点餐-销售统计")
@Controller("sales-stats")
export class SalesStatController {
  constructor(private readonly orderService: OrderService) {}

  @ApiOperation({ summary: "销售统计（单日/区间/近30天）" })
  @Permissions("catering:sales:list")
  @Get()
  getSalesStats(@Query() query: SalesQueryDto) {
    return this.orderService.getSalesStats(query);
  }
}
