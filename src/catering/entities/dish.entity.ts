import { Column, Entity } from "typeorm";
import { BaseEntity } from "@/common/entities/base.entity";

@Entity("dish")
export class Dish extends BaseEntity {
  @Column({ name: "category_id", type: "bigint", comment: "分类ID" })
  categoryId: string;

  @Column({ length: 100, comment: "菜品名称" })
  name: string;

  @Column({
    name: "unit_price",
    type: "decimal",
    precision: 10,
    scale: 2,
    default: 0,
    comment: "单价",
  })
  unitPrice: string;

  @Column({ length: 20, default: "份", comment: "单位" })
  unit: string;

  @Column({ name: "monthly_sale", type: "int", default: 0, comment: "月销量" })
  monthlySale: number;

  @Column({ type: "json", nullable: true, comment: "图片数组[{url}]" })
  image: { url: string }[];

  @Column({ type: "int", default: 0, comment: "排序" })
  sort: number;

  @Column({ type: "tinyint", default: 1, comment: "状态(1-上架 0-下架)" })
  status: number;

  @Column({ name: "sold_out", type: "tinyint", default: 0, comment: "是否沽清(0-正常 1-沽清)" })
  soldOut: number;

  @Column({ length: 50, nullable: true, comment: "口味/辣度标签" })
  flavor: string | null;

  @Column({ length: 255, nullable: true, comment: "菜品描述" })
  description: string | null;
}
