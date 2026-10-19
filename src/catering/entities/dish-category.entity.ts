import { Column, Entity } from "typeorm";
import { BaseEntity } from "@/common/entities/base.entity";

@Entity("dish_category")
export class DishCategory extends BaseEntity {
  @Column({ length: 50, comment: "分类名称" })
  name: string;

  @Column({ type: "int", default: 0, comment: "排序" })
  sort: number;

  @Column({ type: "tinyint", default: 1, comment: "状态(1-启用 0-停用)" })
  status: number;
}
