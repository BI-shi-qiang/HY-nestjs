# 点餐(餐饮)模块完善计划

> 目标：把「点餐」从现在的**测试数据雏形**，完善成一套可由后台(vue3-element-admin)管理的、
> 按餐饮行业标准设计的完整模块，覆盖菜品、分类、桌台、订单、销售统计，小程序(uniapp-diancan)联动。
>
> 涉及三端：
> - 后端 `D:\project\GDZ\youlai-nest`
> - 后台 `D:\project\GDZ\vue3-element-admin`
> - 小程序 `D:\project\GDZ\uniapp-diancan\diancan`

---

## 一、现状盘点

### 后端（已有，雏形）
`src/order/` 模块已存在，含 4 张表 + 4 个接口：

| 实体 | 表名 | 字段要点 | 缺口 |
|:--|:--|:--|:--|
| DishCategory | `dish_category` | name / sort | 无 CRUD 接口 |
| Dish | `dish` | categoryId / name / unitPrice / unit / monthlySale / image(json) / sort / status | 无 CRUD、无沽清/口味/描述 |
| DishOrder | `dish_order` | tableNumber(字符串) / numberOfDiners / orderNo / orderTime / settleAmount / transacStatus / orderReceiving / menu(json) | 明细存 JSON、桌台是硬编码字符串、无状态流转接口 |
| SalesStat | `sales_stat` | statDate / amount | 无查询/报表接口 |

现有接口（`OrderController`，前缀 `/api/v1`）：
- `GET /dishes`（公开）取分类+菜品
- `POST /orders` 下单/加菜
- `GET /orders/current?table_number=` 当前桌未结账订单
- `GET /orders` 订单列表

### 小程序（已切到后端）
- `utils/request.js`：baseURL `http://192.168.216.192:8000/api/v1`，解包 `{code,msg,data}`（code `00000` 成功）
- `utils/auth.js`：`wx.login` → `POST /wxma/auth/silent-login` 换 JWT
- `diancan.vue`：`get('/dishes')` 取菜单、下单走 `POST /orders`
- **遗留问题**：桌号 `table_number`、人数 `number_of_diners` 是写死的（`'002'` / `5`）

### 后台（动态路由机制已就绪）
- 动态路由：`MenuAPI.getRoutes()` → 后端返回 `sys_menu` 树 → `transformRoutes` 把 `component` 字段（相对 `src/views/` 的路径）映射到 Vue 文件（`import.meta.glob("../views/**/**.vue")`）
- 菜单三类型：`C` 目录 / `M` 菜单 / `B` 按钮（权限）
- 权限标识惯例：`rag:document:list`、`rag:document:create` 这种 `模块:资源:动作`
- 已有 RAG 模块是「后端 + api + view + 菜单」的完整范例，可直接照抄结构
- **缺口**：没有「点餐管理」的目录/菜单/页面/api

---

## 二、目标与范围

1. 后台可管理：菜品分类、菜品、桌台、订单、销售统计 —— 全部增删改查。
2. 模块菜单/路由在后台（`sys_menu`）配置，页面组件 + API 按 youlai 规范补齐。
3. 按餐饮行业标准补全数据模型与状态机。
4. 小程序与后台数据打通（桌台扫码下单、订单实时可见）。

---

## 三、数据模型设计（按餐饮行业标准）

### 1. 菜品分类 `dish_category`
现有基础上补一个 `status`（启用/停用）：

| 字段 | 类型 | 说明 |
|:--|:--|:--|
| id | bigint PK | 分类 ID |
| name | varchar(50) | 分类名 |
| sort | int | 排序 |
| status | tinyint | 1 启用 / 0 停用 |

### 2. 菜品 `dish`
补「沽清 / 口味标签 / 描述」等餐饮常用字段：

| 字段 | 类型 | 说明 |
|:--|:--|:--|
| categoryId | bigint | 分类 ID |
| name | varchar(100) | 菜名 |
| unitPrice | decimal(10,2) | 单价 |
| unit | varchar(20) | 单位（份/例/扎…） |
| image | json | `[{url}]` 图片数组 |
| monthlySale | int | 月销量 |
| sort | int | 排序 |
| status | tinyint | 1 上架 / 0 下架 |
| **soldOut** | tinyint | 0 正常 / 1 沽清（售罄，前端置灰不可点） |
| **flavor** | varchar(50) | 口味/辣度标签，如「微辣/中辣/重辣」 |
| **description** | varchar(255) | 菜品描述（详情页展示） |

### 3. 桌台 `table`（**新增**，替代现在写死的 table_number）

| 字段 | 类型 | 说明 |
|:--|:--|:--|
| id | bigint PK | 桌台 ID |
| tableNo | varchar(20) | 桌号（如 A01、002） |
| area | varchar(50) | 区域（大厅/包间） |
| seatCount | int | 座位数 |
| status | tinyint | 1 空闲 / 2 就餐中 / 3 待结账 |
| qrCode | varchar(255) | 桌台二维码（扫码下单入口） |
| sort | int | 排序 |
| remark | varchar(255) | 备注 |

### 4. 订单 `dish_order`
- 用 `tableId` 关联桌台，`tableNo` 冗余快照（避免 join、历史可读）
- 补「支付方式 / 备注」，把 `orderReceiving` 状态值规范化

| 字段 | 类型 | 说明 |
|:--|:--|:--|
| orderNo | varchar(64) | 订单号（时间戳+6 随机） |
| tableId | bigint | 桌台 ID |
| tableNo | varchar(20) | 桌号快照 |
| numberOfDiners | int | 就餐人数 |
| orderTime | datetime | 下单时间 |
| settleAmount | decimal(10,2) | 总金额 |
| transacStatus | varchar(20) | `unsettled` 未结账 / `settled` 已结账 |
| orderReceiving | varchar(20) | `pending` 待接单 / `received` 已接单 / `making` 制作中 / `finished` 已完成 / `cancelled` 已取消 |
| payType | varchar(20) | `wechat` 微信 / `cash` 现金 |
| remark | varchar(255) | 备注 |
| menu | json | 明细（见下，阶段二拆表） |

> 现有代码里接单状态是 `mis_orders`，建议规范为 `pending` 等英文枚举；**兼容处理**：小程序暂不感知，后台展示层做映射。

### 5. 订单明细 `order_item`（**阶段二拆表，可选**）
现在 `menu` 用 JSON 存明细（含加菜多轮），简单但不利于对账/统计。行业标准是拆成明细表：

| 字段 | 说明 |
|:--|:--|
| orderId | 订单 ID |
| dishId | 菜品 ID |
| dishName / unitPrice | 下单时**快照**（菜品改价不影响历史订单） |
| quantity | 数量 |
| amount | 小计 |

**建议**：阶段一先保留 `menu` JSON 打通流程；阶段二再拆 `order_item` + 迁移。

### 6. 销售统计 `sales_stat`
- 补 `orderCount`（当日订单数），支撑报表

---

## 四、后端接口设计

统一前缀 `/api/v1`，权限标识按 `catering:资源:动作` 命名。模块沿用 `src/order/`（或重命名 `catering`，见决策点），拆成 3 个 Controller：

### 分类 + 菜品（`DishController`，后台管理 + 小程序共用）
| 方法 | 路径 | 权限 | 说明 |
|:--|:--|:--|:--|
| GET | `/dishes` | 公开 | 小程序取分类+菜品（现有，保留） |
| GET | `/dish-categories` | `catering:category:list` | 分类分页/列表 |
| POST | `/dish-categories` | `catering:category:create` | 新增分类 |
| PUT | `/dish-categories/:id` | `catering:category:update` | 改分类 |
| DELETE | `/dish-categories/:id` | `catering:category:delete` | 删分类 |
| GET | `/dishes/page` | `catering:dish:list` | 菜品分页（后台） |
| POST | `/dishes` | `catering:dish:create` | 新增菜品 |
| PUT | `/dishes/:id` | `catering:dish:update` | 改菜品 |
| DELETE | `/dishes/:id` | `catering:dish:delete` | 删菜品 |
| PUT | `/dishes/:id/status` | `catering:dish:update` | 上/下架、沽清 |

### 桌台（`TableController`）
| 方法 | 路径 | 权限 | 说明 |
|:--|:--|:--|:--|
| GET | `/tables` | `catering:table:list` | 桌台列表 |
| POST | `/tables` | `catering:table:create` | 新增桌台 |
| PUT | `/tables/:id` | `catering:table:update` | 改桌台 |
| DELETE | `/tables/:id` | `catering:table:delete` | 删桌台 |

### 订单 + 统计（`OrderController`）
| 方法 | 路径 | 权限 | 说明 |
|:--|:--|:--|:--|
| POST | `/orders` | 公开（登录用户） | 小程序下单/加菜（现有） |
| GET | `/orders/current` | 公开（登录用户） | 当前桌未结账订单 |
| GET | `/orders` | `catering:order:list` | 订单分页（后台，可按桌号/状态/时间筛选） |
| GET | `/orders/:id` | `catering:order:detail` | 订单详情（含明细） |
| PUT | `/orders/:id/receive` | `catering:order:receive` | 接单 |
| PUT | `/orders/:id/settle` | `catering:order:settle` | 结账 |
| PUT | `/orders/:id/cancel` | `catering:order:cancel` | 取消 |
| GET | `/sales-stats` | `catering:sales:list` | 销售统计（日/月汇总） |

> 小程序侧订单接口要保持现有返回结构不变（`menu` 明细、`sett_amount` 等），避免改动小程序。

---

## 五、后台前端设计（vue3-element-admin）

### API 层 `src/api/catering/`
新增 `index.ts` + `types.ts`，按资源分对象（照抄 `src/api/rag/index.ts` 模式）：
- `CategoryAPI`、`DishAPI`、`TableAPI`、`OrderAPI`、`SalesAPI`
- baseURL 用 `/api/v1/...`，`request` 工具封装

### 页面 `src/views/catering/`
| 页面 | 组件路径 | 功能 |
|:--|:--|:--|
| 分类管理 | `catering/category/index.vue` | 表格 + 新增/编辑弹窗 + 排序 + 启停 |
| 菜品管理 | `catering/dish/index.vue` | 表格 + 弹窗（图片上传走现有 Upload/OSS、分类下拉、上下架、沽清开关） |
| 桌台管理 | `catering/table/index.vue` | 表格 + 弹窗（桌号/区域/状态/二维码） |
| 订单管理 | `catering/order/index.vue` | 订单列表 + 明细抽屉 + 接单/结账/取消按钮 + 状态筛选 |
| 销售统计 | `catering/sales/index.vue` | 日销售额趋势（复用 ECharts 组件）+ 汇总卡片 |

### 菜单/权限配置（后台「菜单管理」页面或 SQL）
在后端 `sys_menu` 表新增：

```
点餐管理（C 目录，component 空）
├── 菜品分类（M，component=catering/category/index，perm=catering:category:list）
├── 菜品管理（M，component=catering/dish/index）
├── 桌台管理（M，component=catering/table/index）
├── 订单管理（M，component=catering/order/index）
└── 销售统计（M，component=catering/sales/index）
```
每个菜单下再挂按钮权限（B），如菜品管理的 `create/update/delete`、订单管理的 `receive/settle/cancel`。

---

## 六、小程序联动调整

1. **桌台**：扫桌台二维码 → 带 `tableId` 进入点餐页，替代写死的 `'002'`（阶段一可先保留 `'002'`，阶段二接二维码）。
2. **下单**：`POST /orders` 时传 `tableId`（+ 可选 `remark`），人数取用户输入或默认。
3. **状态展示**：订单详情/我的订单读后端 `transac_status`、`order_receiving`，展示「待接单/制作中/已完成」。
4. **沽清/下架**：菜品接口已过滤 `status=1` 且 `soldOut=0` 的才展示，小程序无需改（后端过滤）。

---

## 七、分阶段执行计划

| 阶段 | 内容 | 产出 |
|:--|:--|:--|
| **P1 数据模型 + SQL** | 新增 `table` 实体；`dish` 补 soldOut/flavor/description；`dish_order` 补 tableId/payType/remark；`sales_stat` 补 orderCount；生成建表 SQL + 菜单/权限 SQL | 实体 + `sql/` 脚本 |
| **P2 后端 CRUD 接口** | 拆 DishController/TableController/OrderController；补齐分类/菜品/桌台/订单/统计的增删改查 + 状态流转；加 `@Permissions` 权限；订单接单/结账/取消 | 后端接口 + Swagger |
| **P3 后台前端** | `src/api/catering/` + 5 个页面 + 菜单配置 | 后台可管理点餐 |
| **P4 实时接单（可选）** | 下单后 SSE 推送到后台「订单管理」实时刷新（复用现有 `src/message/sse`） | 后厨/收银实时接单 |
| **P5 小程序联动** | 桌台二维码带 tableId、订单状态展示 | 小程序接入 |
| **P6 明细拆表（可选）** | `menu` JSON → `order_item` 表 + 迁移 | 规范化对账 |

> 建议先做 P1~P3（核心价值：后台能管理点餐数据），P4~P6 视需要推进。

---

## 八、需要你拍板的决策点

1. **模块命名**：继续用 `src/order/`，还是重命名为 `catering`（餐饮）更贴切？
   - 推荐：**保留 `order` 并扩展**（少改动、小程序接口不变），权限标识用 `catering:*`。
2. **订单明细**：阶段一保留 `menu` JSON（快、兼容小程序），阶段二拆 `order_item` 表？
   - 推荐：**两阶段**，先 JSON 后拆表。
3. **订单状态值**：把 `mis_orders` 规范成 `pending/received/making/finished/cancelled`？
   - 推荐：**规范化**，展示层做中英文映射。
4. **实时推送**：后台接单用**现有 SSE**（推荐），还是继续用小程序当前的 GoEasy？
   - 推荐：**SSE**，与后端体系统一，GoEasy 可下线。
5. **桌台二维码**：阶段一先用桌号下拉/手输，阶段二再生成二维码（复用 File/OSS 或返回带参路径）？

---

## 九、风险与注意

- 现有小程序已依赖 `POST /orders` 的入参（`table_number` / `number_of_diners` / `goods_list`）和返回结构，后端改动要**向后兼容**，避免小程序报错。
- 订单金额/菜名要用**快照**（改价不影响历史订单）；若阶段一用 JSON 明细，`goods_list` 里已带 name/unitprice 快照，天然满足。
- 图片上传复用现有 `File`/OSS 模块（`OSS_TYPE=local` 已在跑），菜品 `image` 存 `[{url}]`。
- 权限码新增后，需给「超级管理员/系统管理员」角色授权，否则后台看不到新菜单。
