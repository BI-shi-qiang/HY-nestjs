import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { DocumentController } from "./document.controller";
import { DocumentService } from "./document.service";
import { SysRagDocument } from "./entities/sys-rag-document.entity";

@Module({
  imports: [TypeOrmModule.forFeature([SysRagDocument])],
  controllers: [DocumentController],
  providers: [DocumentService],
  exports: [DocumentService],
})
export class DocumentsModule {}
