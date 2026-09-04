import { Module, Global } from "@nestjs/common";
import { AiService } from "./ai.service";

// 全局模块
@Global()
@Module({
  providers: [AiService],
  exports: [AiService],
})
export class AiModule {}
