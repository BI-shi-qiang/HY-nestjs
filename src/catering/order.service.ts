import { BadRequestException, Injectable, NotFoundException } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { DataSource, Not, Repository } from "typeorm";

import { Dish } from "./entities/dish.entity";
import { DishOrder } from "./entities/dish-order.entity";
import { SalesStat } from "./entities/sales-stat.entity";
import { DiningTable } from "./entities/dining-table.entity";
import { CreateOrderDto } from "./dto/create-order.dto";
import { OrderQueryDto } from "./dto/order-query.dto";
import { UpdateOrderStatusDto } from "./dto/update-order-status.dto";
import { SalesQueryDto } from "./dto/sales-query.dto";
import { SseService } from "../message/sse.service";
import { RequestContext } from "../common/context/request-context";

/**
 * 点餐服务：下单加菜、订单查询、状态流转、日销售额统计
 */
@Injectable()
export class OrderService {
  constructor(
    @InjectRepository(Dish)
    private readonly dishRepository: Repository<Dish>,
    @InjectRepository(DishOrder)
    private readonly orderRepository: Repository<DishOrder>,
    @InjectRepository(SalesStat)
    private readonly salesStatRepository: Repository<SalesStat>,
    @InjectRepository(DiningTable)
    private readonly tableRepository: Repository<DiningTable>,
    private readonly dataSource: DataSource,
    private readonly sseService: SseService
  ) {}

  /**
   * 下单 / 加菜（事务：写订单 + 菜品销量自增 + 日销售额/订单数累加）
   */
  async createOrder(dto: CreateOrderDto) {
    const { table_number, table_id, number_of_diners = 0, pay_type, remark, goods_list } = dto;

    if (!goods_list || goods_list.length === 0) {
      throw new BadRequestException("菜品列表不能为空");
    }

    // 桌号：优先用传入的 table_number，否则按 table_id 反查桌号作为快照
    let tableNumber = table_number;
    if (!tableNumber && table_id) {
      const table = await this.tableRepository.findOne({
        where: { id: table_id, isDeleted: 0 },
      });
      if (!table) throw new BadRequestException("桌台不存在");
      tableNumber = table.tableNo;
    }
    if (!tableNumber) throw new BadRequestException("桌号不能为空");

    const userId = RequestContext.getUserId();

    const settleAmount = goods_list.reduce(
      (sum, g) => sum + Number(g.unitprice ?? 0) * Number(g.quantity ?? 0),
      0
    );
    const orderNo = this.generateOrderNo();
    const orderTime = new Date();
    const menuEntry = { backup_data: "备用字段", goods_list };

    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      const where: any = {
        transacStatus: "unsettled",
        isDeleted: 0,
        orderReceiving: Not("cancelled"),
      };
      if (table_id) where.tableId = table_id;
      else where.tableNumber = tableNumber;

      const existing = await queryRunner.manager.findOne(DishOrder, { where });

      let result: DishOrder;
      let isNew = false;
      if (!existing) {
        isNew = true;
        const order = queryRunner.manager.create(DishOrder, {
          tableNumber,
          tableId: table_id ?? null,
          userId,
          numberOfDiners: number_of_diners,
          orderNo,
          orderTime,
          settleAmount: settleAmount.toFixed(2),
          transacStatus: "unsettled",
          orderReceiving: "pending",
          payType: pay_type ?? null,
          remark: remark ?? null,
          menu: [menuEntry],
          isDeleted: 0,
        });
        result = await queryRunner.manager.save(order);

        // 新开桌：桌台置为「就餐中」
        if (table_id) {
          await queryRunner.manager.update(
            DiningTable,
            { id: table_id, isDeleted: 0 },
            { status: 2 }
          );
        }
      } else {
        // 加菜：金额累加、menu 前插
        existing.settleAmount = (Number(existing.settleAmount) + settleAmount).toFixed(2);
        existing.orderReceiving = "pending";
        if (!existing.userId && userId) existing.userId = userId; // 兼容旧订单补记下单用户
        existing.menu = [menuEntry, ...(existing.menu ?? [])];
        result = await queryRunner.manager.save(existing);
      }

      // 菜品月销量自增
      for (const g of goods_list) {
        const dishId = g._id;
        const qty = Number(g.quantity ?? 0);
        if (dishId && qty > 0) {
          await queryRunner.manager.increment(
            Dish,
            { id: dishId, isDeleted: 0 },
            "monthlySale",
            qty
          );
        }
      }

      // 当日销售额 / 订单数累加
      const statDate = this.today();
      const stat = await queryRunner.manager.findOne(SalesStat, {
        where: { statDate, isDeleted: 0 },
      });
      if (stat) {
        stat.amount = (Number(stat.amount) + settleAmount).toFixed(2);
        if (isNew) stat.orderCount = (stat.orderCount ?? 0) + 1;
        await queryRunner.manager.save(stat);
      } else {
        const newStat = queryRunner.manager.create(SalesStat, {
          statDate,
          amount: settleAmount.toFixed(2),
          orderCount: 1,
          isDeleted: 0,
        });
        await queryRunner.manager.save(newStat);
      }

      await queryRunner.commitTransaction();

      // 下单/加菜成功后，SSE 广播「新订单」给店员端（后台订单页实时刷新）
      const orderItemCount = (result.menu ?? []).reduce(
        (n, m) =>
          n + (m.goods_list ?? []).reduce((s: number, g: any) => s + Number(g.quantity ?? 0), 0),
        0
      );
      this.sseService.broadcastEvent("new-order", {
        orderNo: result.orderNo,
        tableNumber: result.tableNumber,
        settleAmount: Number(result.settleAmount),
        itemCount: orderItemCount,
        isAddDish: !isNew,
      });

      return {
        order_no: result.orderNo,
        table_number: result.tableNumber,
        order_time: result.orderTime,
        settle_amount: Number(result.settleAmount),
      };
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  /**
   * 当前桌未结账订单（小程序订单详情页）
   */
  async getCurrentOrder(tableNumber: string) {
    if (!tableNumber) return null;
    const order = await this.orderRepository.findOne({
      where: {
        tableNumber,
        transacStatus: "unsettled",
        isDeleted: 0,
        orderReceiving: Not("cancelled"),
      },
      order: { orderTime: "DESC" },
    });
    if (!order) return null;
    return this.toOrderView(order);
  }

  /**
   * 订单列表（小程序「我的订单」页，返回数组）
   */
  async listOrders() {
    const orders = await this.orderRepository.find({
      where: { isDeleted: 0 },
      order: { orderTime: "DESC" },
    });
    return orders.map((o) => this.toOrderView(o));
  }

  /**
   * 我的订单（小程序，按当前登录用户过滤）
   */
  async getMyOrders() {
    const userId = RequestContext.getUserId();
    if (!userId) return [];
    const orders = await this.orderRepository.find({
      where: { userId, isDeleted: 0 },
      order: { orderTime: "DESC" },
    });
    return orders.map((o) => this.toOrderView(o));
  }

  /**
   * 订单分页（后台）
   */
  async getOrderPage(query: OrderQueryDto) {
    const page = query.pageNum || 1;
    const size = query.pageSize || 10;

    const qb = this.orderRepository.createQueryBuilder("o").where("o.isDeleted = 0");
    if (query.tableNumber) {
      qb.andWhere("o.tableNumber LIKE :tableNumber", { tableNumber: `%${query.tableNumber}%` });
    }
    if (query.transacStatus) {
      qb.andWhere("o.transacStatus = :transacStatus", { transacStatus: query.transacStatus });
    }
    if (query.orderReceiving) {
      qb.andWhere("o.orderReceiving = :orderReceiving", { orderReceiving: query.orderReceiving });
    }

    qb.orderBy("o.orderTime", "DESC");

    const [list, total] = await qb
      .skip((page - 1) * size)
      .take(size)
      .getManyAndCount();

    const data = list.map((o) => this.toAdminOrderView(o));

    return {
      data,
      page: { pageNum: page, pageSize: size, total },
    };
  }

  /**
   * 订单详情（后台）
   */
  async getOrder(id: string) {
    const order = await this.getOrderEntity(id);
    return this.toOrderView(order);
  }

  /**
   * 接单
   */
  async receiveOrder(id: string) {
    const order = await this.getOrderEntity(id);
    order.orderReceiving = "received";
    await this.orderRepository.save(order);
    return this.toOrderView(order);
  }

  /**
   * 结账：置为已结账 + 记录支付方式 + 释放桌台
   */
  async settleOrder(id: string, dto: UpdateOrderStatusDto) {
    const order = await this.getOrderEntity(id);
    order.transacStatus = "settled";
    if (dto.payType) order.payType = dto.payType;
    if (dto.remark) order.remark = dto.remark;
    await this.orderRepository.save(order);
    await this.freeTable(order.tableId);
    return this.toOrderView(order);
  }

  /**
   * 取消订单：置为已取消 + 释放桌台
   */
  async cancelOrder(id: string) {
    const order = await this.getOrderEntity(id);
    order.orderReceiving = "cancelled";
    await this.orderRepository.save(order);
    await this.freeTable(order.tableId);
    return this.toOrderView(order);
  }

  /**
   * 删除订单（软删除）：
   * 行业标准里订单不对账时需留痕，故不物理删除；只允许删除已结账/已取消的订单，
   * 进行中（未结账且未取消）的订单需先取消或结账。
   */
  async deleteOrder(id: string) {
    const order = await this.getOrderEntity(id);
    if (order.transacStatus === "unsettled" && order.orderReceiving !== "cancelled") {
      throw new BadRequestException("进行中的订单不能删除，请先取消或结账");
    }
    order.isDeleted = 1;
    await this.orderRepository.save(order);
    return { success: true };
  }

  /**
   * 销售统计：单日 / 区间 / 近 30 天
   */
  async getSalesStats(query: SalesQueryDto) {
    const { date, startDate, endDate } = query;

    const qb = this.salesStatRepository.createQueryBuilder("s").where("s.isDeleted = 0");

    if (date) {
      qb.andWhere("s.statDate = :date", { date });
    } else {
      const start = startDate || this.daysAgo(29);
      const end = endDate || this.today();
      qb.andWhere("s.statDate >= :start", { start }).andWhere("s.statDate <= :end", { end });
    }

    qb.orderBy("s.statDate", "ASC");
    const rows = await qb.getMany();

    const list = rows.map((r) => ({
      statDate: r.statDate,
      amount: Number(r.amount),
      orderCount: r.orderCount ?? 0,
    }));
    const totalAmount = list.reduce((sum, r) => sum + r.amount, 0);
    const totalCount = list.reduce((sum, r) => sum + r.orderCount, 0);

    return {
      list,
      total: { amount: Number(totalAmount.toFixed(2)), orderCount: totalCount },
    };
  }

  // ============================ 内部工具 ============================

  private async getOrderEntity(id: string) {
    const order = await this.orderRepository.findOne({ where: { id, isDeleted: 0 } });
    if (!order) throw new NotFoundException("订单不存在");
    return order;
  }

  /** 释放桌台（置为「空闲」） */
  private async freeTable(tableId?: string) {
    if (!tableId) return;
    await this.tableRepository.update({ id: tableId, isDeleted: 0 }, { status: 1 });
  }

  /** 小程序/详情返回结构（snake_case，兼容现有小程序） */
  private toOrderView(o: DishOrder) {
    return {
      id: o.id,
      table_id: o.tableId,
      table_number: o.tableNumber,
      number_of_diners: o.numberOfDiners,
      order_time: o.orderTime,
      order_no: o.orderNo,
      settle_amount: Number(o.settleAmount),
      transac_status: o.transacStatus,
      order_receiving: o.orderReceiving,
      pay_type: o.payType,
      remark: o.remark,
      menu: o.menu ?? [],
    };
  }

  /** 后台订单列表返回结构（camelCase + 明细份数） */
  private toAdminOrderView(o: DishOrder) {
    const itemCount = (o.menu ?? []).reduce(
      (n, m) =>
        n + (m.goods_list ?? []).reduce((s: number, g: any) => s + Number(g.quantity ?? 0), 0),
      0
    );
    return {
      id: o.id,
      orderNo: o.orderNo,
      tableId: o.tableId,
      tableNumber: o.tableNumber,
      numberOfDiners: o.numberOfDiners,
      orderTime: o.orderTime,
      settleAmount: Number(o.settleAmount),
      transacStatus: o.transacStatus,
      orderReceiving: o.orderReceiving,
      payType: o.payType,
      remark: o.remark,
      itemCount,
    };
  }

  /** 当天日期字符串 YYYY-MM-DD（本地时区） */
  private today(): string {
    const now = new Date();
    const mm = String(now.getMonth() + 1).padStart(2, "0");
    const dd = String(now.getDate()).padStart(2, "0");
    return `${now.getFullYear()}-${mm}-${dd}`;
  }

  /** N 天前日期字符串 YYYY-MM-DD */
  private daysAgo(n: number): string {
    const d = new Date();
    d.setDate(d.getDate() - n);
    const mm = String(d.getMonth() + 1).padStart(2, "0");
    const dd = String(d.getDate()).padStart(2, "0");
    return `${d.getFullYear()}-${mm}-${dd}`;
  }

  /** 生成订单号：时间戳 + 6 位随机数（对齐原小程序 utils.Code 逻辑） */
  private generateOrderNo(): string {
    let code = "";
    for (let i = 0; i < 6; i++) {
      code += Math.floor(Math.random() * 10);
    }
    return `${Date.now()}${code}`;
  }
}
