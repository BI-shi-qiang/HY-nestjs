import { Body, Controller, Delete, Get, Param, Post, Put, Query } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";

import { Public } from "../common/decorators/auth.decorator";
import { Permissions } from "../common/decorators/auth.decorator";
import { DishService } from "./dish.service";
import { CreateDishDto, UpdateDishDto, UpdateDishStatusDto } from "./dto/dish.dto";
import { DishQueryDto } from "./dto/dish-query.dto";

/**
 * 菜品接口：小程序公开「分类+菜品」 + 后台菜品增删改查
 */
@ApiTags("点餐-菜品")
@Controller("dishes")
export class DishController {
  constructor(private readonly dishService: DishService) {}

  @ApiOperation({ summary: "获取菜品及分类（小程序）" })
  @Public()
  @Get()
  getDishes() {
    return this.dishService.getDishes();
  }

  @ApiOperation({ summary: "菜品分页（后台）" })
  @Permissions("catering:dish:list")
  @Get("page")
  getDishPage(@Query() query: DishQueryDto) {
    return this.dishService.getDishPage(query);
  }

  @ApiOperation({ summary: "菜品详情（后台）" })
  @Permissions("catering:dish:list")
  @Get(":id")
  getDish(@Param("id") id: string) {
    return this.dishService.getDish(id);
  }

  @ApiOperation({ summary: "新增菜品" })
  @Permissions("catering:dish:create")
  @Post()
  createDish(@Body() dto: CreateDishDto) {
    return this.dishService.createDish(dto);
  }

  @ApiOperation({ summary: "修改菜品" })
  @Permissions("catering:dish:update")
  @Put(":id")
  updateDish(@Param("id") id: string, @Body() dto: UpdateDishDto) {
    return this.dishService.updateDish(id, dto);
  }

  @ApiOperation({ summary: "上/下架、沽清" })
  @Permissions("catering:dish:update")
  @Put(":id/status")
  updateDishStatus(@Param("id") id: string, @Body() dto: UpdateDishStatusDto) {
    return this.dishService.updateDishStatus(id, dto);
  }

  @ApiOperation({ summary: "删除菜品" })
  @Permissions("catering:dish:delete")
  @Delete(":id")
  deleteDish(@Param("id") id: string) {
    return this.dishService.deleteDish(id);
  }
}
