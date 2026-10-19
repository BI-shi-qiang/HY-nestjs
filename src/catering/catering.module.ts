import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";

import { SseModule } from "../message/sse.module";
import { AuthModule } from "../auth/auth.module";

import { DishCategory } from "./entities/dish-category.entity";
import { Dish } from "./entities/dish.entity";
import { DishOrder } from "./entities/dish-order.entity";
import { SalesStat } from "./entities/sales-stat.entity";
import { DiningTable } from "./entities/dining-table.entity";

import { DishService } from "./dish.service";
import { TableService } from "./table.service";
import { OrderService } from "./order.service";

import { DishCategoryController } from "./dish-category.controller";
import { DishController } from "./dish.controller";
import { TableController } from "./table.controller";
import { OrderController } from "./order.controller";
import { SalesStatController } from "./sales-stat.controller";

@Module({
  imports: [
    SseModule,
    AuthModule,
    TypeOrmModule.forFeature([DishCategory, Dish, DishOrder, SalesStat, DiningTable]),
  ],
  controllers: [
    DishCategoryController,
    DishController,
    TableController,
    OrderController,
    SalesStatController,
  ],
  providers: [DishService, TableService, OrderService],
})
export class CateringModule {}
