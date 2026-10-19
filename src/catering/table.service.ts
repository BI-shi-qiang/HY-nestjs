import { Injectable, NotFoundException } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { ConfigService } from "@nestjs/config";
import { Repository } from "typeorm";
import * as path from "path";
import { mkdir, writeFile } from "node:fs/promises";

import { DiningTable } from "./entities/dining-table.entity";
import { WxMaAuthService } from "../auth/wxma-auth.service";
import { CreateTableDto, UpdateTableDto } from "./dto/table.dto";
import { TableQueryDto } from "./dto/table-query.dto";

/**
 * 桌台服务：桌台增删改查
 */
@Injectable()
export class TableService {
  constructor(
    @InjectRepository(DiningTable)
    private readonly tableRepository: Repository<DiningTable>,
    private readonly wxMaAuthService: WxMaAuthService,
    private readonly configService: ConfigService
  ) {}

  async getTablePage(query: TableQueryDto) {
    const page = query.pageNum || 1;
    const size = query.pageSize || 10;

    const qb = this.tableRepository.createQueryBuilder("t").where("t.isDeleted = 0");
    if (query.tableNo) {
      qb.andWhere("t.tableNo LIKE :tableNo", { tableNo: `%${query.tableNo}%` });
    }
    if (query.status !== undefined && query.status !== null && query.status !== "") {
      qb.andWhere("t.status = :status", { status: Number(query.status) });
    }

    qb.orderBy("t.sort", "ASC").addOrderBy("t.id", "ASC");

    const [list, total] = await qb
      .skip((page - 1) * size)
      .take(size)
      .getManyAndCount();

    return {
      data: list,
      page: { pageNum: page, pageSize: size, total },
    };
  }

  async getTable(id: string) {
    return this.getTableEntity(id);
  }

  /** 桌台信息（小程序扫码进入时拉取桌号） */
  async getTableInfo(id: string) {
    const table = await this.getTableEntity(id);
    return {
      id: table.id,
      tableNo: table.tableNo,
      area: table.area,
      status: table.status,
    };
  }

  /** 生成桌台小程序码：调微信生成图片 → 存本地 → 回写 qrCode */
  async generateQrCode(id: string) {
    const table = await this.getTableEntity(id);

    const envVersion = this.configService.get<string>("WX_MINIAPP_ENV_VERSION") || "develop";
    const imageBuffer = await this.wxMaAuthService.generateUnlimitedQrCode(
      `t=${table.id}`,
      "pages/diancan/diancan",
      envVersion
    );

    const storageRoot =
      this.configService.get<string>("OSS_LOCAL_STORAGE_PATH") ||
      path.resolve(process.cwd(), "data/oss");
    const qrDir = path.join(storageRoot, "qrcode");
    await mkdir(qrDir, { recursive: true });
    const fileName = `table-${table.id}.png`;
    await writeFile(path.join(qrDir, fileName), imageBuffer);

    const url = `/uploads/qrcode/${fileName}`;
    table.qrCode = url;
    await this.tableRepository.save(table);

    return { tableId: table.id, tableNo: table.tableNo, qrCode: url };
  }

  async createTable(dto: CreateTableDto) {
    const table = this.tableRepository.create({
      tableNo: dto.tableNo,
      area: dto.area ?? null,
      seatCount: dto.seatCount ?? 0,
      status: dto.status ?? 1,
      qrCode: dto.qrCode ?? null,
      sort: dto.sort ?? 0,
      remark: dto.remark ?? null,
    });
    return this.tableRepository.save(table);
  }

  async updateTable(id: string, dto: UpdateTableDto) {
    const table = await this.getTableEntity(id);
    if (dto.tableNo !== undefined) table.tableNo = dto.tableNo;
    if (dto.area !== undefined) table.area = dto.area;
    if (dto.seatCount !== undefined) table.seatCount = dto.seatCount;
    if (dto.status !== undefined) table.status = dto.status;
    if (dto.qrCode !== undefined) table.qrCode = dto.qrCode;
    if (dto.sort !== undefined) table.sort = dto.sort;
    if (dto.remark !== undefined) table.remark = dto.remark;
    return this.tableRepository.save(table);
  }

  async deleteTable(id: string) {
    const table = await this.getTableEntity(id);
    table.isDeleted = 1;
    await this.tableRepository.save(table);
    return { success: true };
  }

  private async getTableEntity(id: string) {
    const table = await this.tableRepository.findOne({ where: { id, isDeleted: 0 } });
    if (!table) throw new NotFoundException("桌台不存在");
    return table;
  }
}
