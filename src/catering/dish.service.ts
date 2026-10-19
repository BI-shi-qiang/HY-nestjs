import { BadRequestException, Injectable, NotFoundException } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";

import { DishCategory } from "./entities/dish-category.entity";
import { Dish } from "./entities/dish.entity";
import { CreateCategoryDto, UpdateCategoryDto } from "./dto/dish-category.dto";
import { CreateDishDto, UpdateDishDto, UpdateDishStatusDto } from "./dto/dish.dto";
import { DishQueryDto } from "./dto/dish-query.dto";

/**
 * 菜品与分类服务
 * 含小程序公开的「分类+菜品」接口，以及后台的分类/菜品增删改查
 */
@Injectable()
export class DishService {
  constructor(
    @InjectRepository(DishCategory)
    private readonly categoryRepository: Repository<DishCategory>,
    @InjectRepository(Dish)
    private readonly dishRepository: Repository<Dish>
  ) {}

  // ============================ 小程序公开接口 ============================

  /**
   * 获取菜品及分类（结构对齐原小程序云函数 dish-data 的返回）
   */
  async getDishes() {
    const categories = await this.categoryRepository.find({
      where: { isDeleted: 0, status: 1 },
      order: { sort: "ASC" },
    });
    const dishes = await this.dishRepository.find({
      where: { isDeleted: 0, status: 1 },
      order: { sort: "ASC" },
    });

    return {
      categories: categories.map((c) => ({ cid: c.id, value: c.name })),
      goods: categories.map((c) => ({
        cid: c.id,
        category: c.name,
        good_query: dishes
          .filter((d) => String(d.categoryId) === String(c.id))
          .map((d) => ({
            _id: d.id,
            name: d.name,
            image: d.image?.length ? d.image : [{ url: "" }],
            unitprice: Number(d.unitPrice),
            unit: d.unit,
            monthlysale: d.monthlySale,
            cid: c.id,
            category: c.name,
            sold_out: d.soldOut ?? 0,
            flavor: d.flavor ?? null,
            description: d.description ?? null,
            quantity: 0,
          })),
      })),
    };
  }

  // ============================ 分类 CRUD ============================

  /**
   * 分类列表（数量少，直接返回数组，供后台表格与下拉复用）
   */
  async listCategories() {
    return this.categoryRepository.find({
      where: { isDeleted: 0 },
      order: { sort: "ASC" },
    });
  }

  async createCategory(dto: CreateCategoryDto) {
    const category = this.categoryRepository.create({
      name: dto.name,
      sort: dto.sort ?? 0,
      status: dto.status ?? 1,
    });
    return this.categoryRepository.save(category);
  }

  async updateCategory(id: string, dto: UpdateCategoryDto) {
    const category = await this.getCategory(id);
    if (dto.name !== undefined) category.name = dto.name;
    if (dto.sort !== undefined) category.sort = dto.sort;
    if (dto.status !== undefined) category.status = dto.status;
    return this.categoryRepository.save(category);
  }

  async deleteCategory(id: string) {
    const category = await this.getCategory(id);
    // 分类下存在有效菜品时不允许删除
    const dishCount = await this.dishRepository.count({
      where: { categoryId: id, isDeleted: 0 },
    });
    if (dishCount > 0) {
      throw new BadRequestException("该分类下存在菜品，无法删除");
    }
    category.isDeleted = 1;
    return this.categoryRepository.save(category);
  }

  private async getCategory(id: string) {
    const category = await this.categoryRepository.findOne({
      where: { id, isDeleted: 0 },
    });
    if (!category) throw new NotFoundException("分类不存在");
    return category;
  }

  // ============================ 菜品 CRUD ============================

  /**
   * 菜品分页（后台）
   */
  async getDishPage(query: DishQueryDto) {
    const page = query.pageNum || 1;
    const size = query.pageSize || 10;

    const qb = this.dishRepository.createQueryBuilder("d").where("d.isDeleted = 0");
    if (query.categoryId) {
      qb.andWhere("d.categoryId = :categoryId", { categoryId: query.categoryId });
    }
    if (query.name) {
      qb.andWhere("d.name LIKE :name", { name: `%${query.name}%` });
    }
    if (query.status !== undefined && query.status !== null && query.status !== "") {
      qb.andWhere("d.status = :status", { status: Number(query.status) });
    }

    qb.orderBy("d.sort", "ASC").addOrderBy("d.id", "DESC");

    const [list, total] = await qb
      .skip((page - 1) * size)
      .take(size)
      .getManyAndCount();

    const data = await this.attachCategoryName(list);

    return {
      data,
      page: { pageNum: page, pageSize: size, total },
    };
  }

  /**
   * 菜品详情（后台编辑表单）
   */
  async getDish(id: string) {
    const dish = await this.getDishEntity(id);
    return this.toDishView(dish);
  }

  async createDish(dto: CreateDishDto) {
    const dish = this.dishRepository.create({
      categoryId: dto.categoryId,
      name: dto.name,
      unitPrice: dto.unitPrice !== null ? Number(dto.unitPrice).toFixed(2) : "0.00",
      unit: dto.unit ?? "份",
      image: dto.image ?? [],
      sort: dto.sort ?? 0,
      status: dto.status ?? 1,
      soldOut: dto.soldOut ?? 0,
      flavor: dto.flavor ?? null,
      description: dto.description ?? null,
    });
    await this.dishRepository.save(dish);
    return this.toDishView(dish);
  }

  async updateDish(id: string, dto: UpdateDishDto) {
    const dish = await this.getDishEntity(id);
    if (dto.categoryId !== undefined) dish.categoryId = dto.categoryId;
    if (dto.name !== undefined) dish.name = dto.name;
    if (dto.unitPrice !== undefined) dish.unitPrice = Number(dto.unitPrice).toFixed(2);
    if (dto.unit !== undefined) dish.unit = dto.unit;
    if (dto.image !== undefined) dish.image = dto.image;
    if (dto.sort !== undefined) dish.sort = dto.sort;
    if (dto.status !== undefined) dish.status = dto.status;
    if (dto.soldOut !== undefined) dish.soldOut = dto.soldOut;
    if (dto.flavor !== undefined) dish.flavor = dto.flavor;
    if (dto.description !== undefined) dish.description = dto.description;
    await this.dishRepository.save(dish);
    return this.toDishView(dish);
  }

  async updateDishStatus(id: string, dto: UpdateDishStatusDto) {
    const dish = await this.getDishEntity(id);
    if (dto.status !== undefined) dish.status = dto.status;
    if (dto.soldOut !== undefined) dish.soldOut = dto.soldOut;
    await this.dishRepository.save(dish);
    return this.toDishView(dish);
  }

  async deleteDish(id: string) {
    const dish = await this.getDishEntity(id);
    dish.isDeleted = 1;
    await this.dishRepository.save(dish);
    return { success: true };
  }

  private async getDishEntity(id: string) {
    const dish = await this.dishRepository.findOne({ where: { id, isDeleted: 0 } });
    if (!dish) throw new NotFoundException("菜品不存在");
    return dish;
  }

  /**
   * 批量回填分类名称（避免 N+1）
   */
  private async attachCategoryName(dishes: Dish[]) {
    const categoryIds = [...new Set(dishes.map((d) => String(d.categoryId)))];
    const categories = categoryIds.length
      ? await this.categoryRepository
          .createQueryBuilder("c")
          .where("c.id IN (:...ids)", { ids: categoryIds })
          .getMany()
      : [];
    const nameMap = new Map(categories.map((c) => [String(c.id), c.name]));

    return dishes.map((d) => ({
      id: d.id,
      categoryId: d.categoryId,
      categoryName: nameMap.get(String(d.categoryId)) ?? "",
      name: d.name,
      unitPrice: Number(d.unitPrice),
      unit: d.unit,
      image: d.image ?? [],
      monthlySale: d.monthlySale,
      sort: d.sort,
      status: d.status,
      soldOut: d.soldOut ?? 0,
      flavor: d.flavor ?? null,
      description: d.description ?? null,
      createTime: d.createTime,
      updateTime: d.updateTime,
    }));
  }

  private toDishView(d: Dish) {
    return {
      id: d.id,
      categoryId: d.categoryId,
      name: d.name,
      unitPrice: Number(d.unitPrice),
      unit: d.unit,
      image: d.image ?? [],
      monthlySale: d.monthlySale,
      sort: d.sort,
      status: d.status,
      soldOut: d.soldOut ?? 0,
      flavor: d.flavor ?? null,
      description: d.description ?? null,
      createTime: d.createTime,
      updateTime: d.updateTime,
    };
  }
}
