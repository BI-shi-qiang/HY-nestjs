import { Column, Entity } from "typeorm";
import { BaseEntity } from "@/common/entities/base.entity";

@Entity("sales_stat")
export class SalesStat extends BaseEntity {
  @Column({ name: "stat_date", length: 10, comment: "统计日期 YYYY-MM-DD" })
  statDate: string;

  @Column({ type: "decimal", precision: 10, scale: 2, default: 0, comment: "当日销售额" })
  amount: string;

  @Column({ name: "order_count", type: "int", default: 0, comment: "当日订单数" })
  orderCount: number;
}
