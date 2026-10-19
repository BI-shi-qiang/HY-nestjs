import { Body, Controller, Delete, Get, Param, Post, Put, Query } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";

import { Permissions, Public } from "../common/decorators/auth.decorator";
import { TableService } from "./table.service";
import { CreateTableDto, UpdateTableDto } from "./dto/table.dto";
import { TableQueryDto } from "./dto/table-query.dto";

/**
 * 桌台管理（后台）
 */
@ApiTags("点餐-桌台")
@Controller("tables")
export class TableController {
  constructor(private readonly tableService: TableService) {}

  @ApiOperation({ summary: "桌台分页列表" })
  @Permissions("catering:table:list")
  @Get()
  getTablePage(@Query() query: TableQueryDto) {
    return this.tableService.getTablePage(query);
  }

  @ApiOperation({ summary: "桌台信息（小程序扫码进入）" })
  @Public()
  @Get(":id/info")
  getTableInfo(@Param("id") id: string) {
    return this.tableService.getTableInfo(id);
  }

  @ApiOperation({ summary: "桌台详情" })
  @Permissions("catering:table:list")
  @Get(":id")
  getTable(@Param("id") id: string) {
    return this.tableService.getTable(id);
  }

  @ApiOperation({ summary: "新增桌台" })
  @Permissions("catering:table:create")
  @Post()
  create(@Body() dto: CreateTableDto) {
    return this.tableService.createTable(dto);
  }

  @ApiOperation({ summary: "生成桌台小程序码" })
  @Permissions("catering:table:update")
  @Post(":id/qrcode")
  generateQrCode(@Param("id") id: string) {
    return this.tableService.generateQrCode(id);
  }

  @ApiOperation({ summary: "修改桌台" })
  @Permissions("catering:table:update")
  @Put(":id")
  update(@Param("id") id: string, @Body() dto: UpdateTableDto) {
    return this.tableService.updateTable(id, dto);
  }

  @ApiOperation({ summary: "删除桌台" })
  @Permissions("catering:table:delete")
  @Delete(":id")
  delete(@Param("id") id: string) {
    return this.tableService.deleteTable(id);
  }
}
