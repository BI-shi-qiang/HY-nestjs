import { Column, Entity } from "typeorm";
import { BaseEntity } from "@/common/entities/base.entity";

/**
 * 桌台实体
 * 对应小程序下单时的桌号，扫码带 tableId 进入点餐页
 */
@Entity("dining_table")
export class DiningTable extends BaseEntity {
  @Column({ name: "table_no", length: 20, comment: "桌号" })
  tableNo: string;

  @Column({ length: 50, nullable: true, comment: "区域（大厅/包间）" })
  area: string | null;

  @Column({ name: "seat_count", type: "int", default: 0, comment: "座位数" })
  seatCount: number;

  @Column({ type: "tinyint", default: 1, comment: "状态(1-空闲 2-就餐中 3-待结账)" })
  status: number;

  @Column({ name: "qr_code", length: 255, nullable: true, comment: "二维码" })
  qrCode: string | null;

  @Column({ type: "int", default: 0, comment: "排序" })
  sort: number;

  @Column({ length: 255, nullable: true, comment: "备注" })
  remark: string | null;
}
