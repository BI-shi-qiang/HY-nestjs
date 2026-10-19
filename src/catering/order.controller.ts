import { Body, Controller, Delete, Get, Param, Post, Put, Query } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";

import { Permissions } from "../common/decorators/auth.decorator";
import { OrderService } from "./order.service";
import { CreateOrderDto } from "./dto/create-order.dto";
import { OrderQueryDto } from "./dto/order-query.dto";
import { UpdateOrderStatusDto } from "./dto/update-order-status.dto";

/**
 * 订单接口：小程序下单/查询 + 后台订单管理
 * 统一挂在全局前缀 /api/v1 下，最终路由为 /api/v1/orders、/api/v1/orders/current 等
 */
@ApiTags("点餐-订单")
@Controller("orders")
export class OrderController {
  constructor(private readonly orderService: OrderService) {}

  @ApiOperation({ summary: "下单/加菜（小程序）" })
  @Post()
  createOrder(@Body() dto: CreateOrderDto) {
    return this.orderService.createOrder(dto);
  }

  @ApiOperation({ summary: "当前桌未结账订单（小程序）" })
  @Get("current")
  getCurrentOrder(@Query("table_number") tableNumber: string) {
    return this.orderService.getCurrentOrder(tableNumber);
  }

  @ApiOperation({ summary: "订单列表（小程序「我的订单」）" })
  @Get()
  listOrders() {
    return this.orderService.listOrders();
  }

  @ApiOperation({ summary: "订单分页（后台）" })
  @Permissions("catering:order:list")
  @Get("page")
  getOrderPage(@Query() query: OrderQueryDto) {
    return this.orderService.getOrderPage(query);
  }

  @ApiOperation({ summary: "我的订单（小程序，按用户过滤）" })
  @Get("mine")
  getMyOrders() {
    return this.orderService.getMyOrders();
  }

  @ApiOperation({ summary: "订单详情（后台/小程序共用，登录即可访问）" })
  @Get(":id")
  getOrder(@Param("id") id: string) {
    return this.orderService.getOrder(id);
  }

  @ApiOperation({ summary: "接单" })
  @Permissions("catering:order:receive")
  @Put(":id/receive")
  receive(@Param("id") id: string) {
    return this.orderService.receiveOrder(id);
  }

  @ApiOperation({ summary: "结账" })
  @Permissions("catering:order:settle")
  @Put(":id/settle")
  settle(@Param("id") id: string, @Body() dto: UpdateOrderStatusDto) {
    return this.orderService.settleOrder(id, dto);
  }

  @ApiOperation({ summary: "取消订单" })
  @Permissions("catering:order:cancel")
  @Put(":id/cancel")
  cancel(@Param("id") id: string) {
    return this.orderService.cancelOrder(id);
  }

  @ApiOperation({ summary: "删除订单（软删除）" })
  @Permissions("catering:order:delete")
  @Delete(":id")
  deleteOrder(@Param("id") id: string) {
    return this.orderService.deleteOrder(id);
  }
}
