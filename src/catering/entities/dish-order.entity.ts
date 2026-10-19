import { Column, Entity } from "typeorm";
import { BaseEntity } from "@/common/entities/base.entity";

@Entity("dish_order")
export class DishOrder extends BaseEntity {
  @Column({ name: "table_number", length: 20, comment: "桌号" })
  tableNumber: string;

  @Column({ name: "table_id", type: "bigint", nullable: true, comment: "桌台ID" })
  tableId: string | null;

  @Column({ name: "user_id", type: "bigint", nullable: true, comment: "下单用户ID" })
  userId: string | null;

  @Column({ name: "number_of_diners", type: "int", default: 0, comment: "就餐人数" })
  numberOfDiners: number;

  @Column({ name: "order_no", length: 64, comment: "订单号" })
  orderNo: string;

  @Column({ name: "order_time", type: "datetime", nullable: true, comment: "下单时间" })
  orderTime: Date;

  @Column({
    name: "settle_amount",
    type: "decimal",
    precision: 10,
    scale: 2,
    default: 0,
    comment: "总金额",
  })
  settleAmount: string;

  @Column({ name: "transac_status", length: 20, default: "unsettled", comment: "结账状态" })
  transacStatus: string;

  @Column({
    name: "order_receiving",
    length: 20,
    default: "pending",
    comment: "接单状态(pending待接单 received已接单 making制作中 finished已完成 cancelled已取消)",
  })
  orderReceiving: string;

  @Column({ name: "pay_type", length: 20, nullable: true, comment: "支付方式(wechat微信 cash现金)" })
  payType: string | null;

  @Column({ length: 255, nullable: true, comment: "备注" })
  remark: string | null;

  @Column({ type: "json", nullable: true, comment: "菜品列表[{backup_data, goods_list}]" })
  menu: any[];
}
