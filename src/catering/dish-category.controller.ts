import { Body, Controller, Delete, Get, Param, Post, Put } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";

import { Permissions } from "../common/decorators/auth.decorator";
import { DishService } from "./dish.service";
import { CreateCategoryDto, UpdateCategoryDto } from "./dto/dish-category.dto";

/**
 * 菜品分类管理（后台）
 */
@ApiTags("点餐-分类")
@Controller("dish-categories")
export class DishCategoryController {
  constructor(private readonly dishService: DishService) {}

  @ApiOperation({ summary: "分类列表" })
  @Permissions("catering:category:list")
  @Get()
  list() {
    return this.dishService.listCategories();
  }

  @ApiOperation({ summary: "新增分类" })
  @Permissions("catering:category:create")
  @Post()
  create(@Body() dto: CreateCategoryDto) {
    return this.dishService.createCategory(dto);
  }

  @ApiOperation({ summary: "修改分类" })
  @Permissions("catering:category:update")
  @Put(":id")
  update(@Param("id") id: string, @Body() dto: UpdateCategoryDto) {
    return this.dishService.updateCategory(id, dto);
  }

  @ApiOperation({ summary: "删除分类" })
  @Permissions("catering:category:delete")
  @Delete(":id")
  delete(@Param("id") id: string) {
    return this.dishService.deleteCategory(id);
  }
}
