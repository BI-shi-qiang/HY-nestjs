/*
 点餐模块升级脚本（针对已用 diancan.sql 初始化的 heyuan 库）
 新增：桌台表 + 菜品/分类/订单/销售统计补字段 + 桌台种子数据
 执行方式：在 heyuan 库下执行本文件即可（本脚本只执行一次，重复执行会报重复列）
*/
SET NAMES utf8mb4;

-- ============================
-- 1. 新增桌台表 dining_table
-- ============================
CREATE TABLE IF NOT EXISTS `dining_table` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `table_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '桌号',
  `area` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '区域（大厅/包间）',
  `seat_count` int(11) NOT NULL DEFAULT 0 COMMENT '座位数',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '状态(1-空闲 2-就餐中 3-待结账)',
  `qr_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '二维码',
  `sort` int(11) NOT NULL DEFAULT 0 COMMENT '排序',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint(20) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '逻辑删除标识(0-未删除 1-已删除)',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_table_no` (`table_no`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '桌台表' ROW_FORMAT = Dynamic;

-- ============================
-- 2. dish_category 补 status
-- ============================
ALTER TABLE `dish_category`
  ADD COLUMN `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '状态(1-启用 0-停用)' AFTER `sort`;

-- ============================
-- 3. dish 补 沽清/口味/描述
-- ============================
ALTER TABLE `dish`
  ADD COLUMN `sold_out` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否沽清(0-正常 1-沽清)' AFTER `status`,
  ADD COLUMN `flavor` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '口味/辣度标签' AFTER `sold_out`,
  ADD COLUMN `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '菜品描述' AFTER `flavor`;

-- ============================
-- 4. dish_order 补 桌台ID/支付方式/备注 + 规范接单状态
-- ============================
ALTER TABLE `dish_order`
  ADD COLUMN `table_id` bigint(20) NULL DEFAULT NULL COMMENT '桌台ID' AFTER `table_number`,
  ADD COLUMN `pay_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付方式(wechat微信 cash现金)' AFTER `order_receiving`,
  ADD COLUMN `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注' AFTER `pay_type`;

ALTER TABLE `dish_order`
  MODIFY COLUMN `order_receiving` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending' COMMENT '接单状态(pending待接单 received已接单 making制作中 finished已完成 cancelled已取消)';

UPDATE `dish_order` SET `order_receiving` = 'pending' WHERE `order_receiving` = 'mis_orders';

-- ============================
-- 5. sales_stat 补 当日订单数
-- ============================
ALTER TABLE `sales_stat`
  ADD COLUMN `order_count` int(11) NOT NULL DEFAULT 0 COMMENT '当日订单数' AFTER `amount`;

-- ============================
-- 6. 桌台种子数据
-- ============================
INSERT INTO `dining_table` (`table_no`, `area`, `seat_count`, `status`, `sort`) VALUES
('001', '大厅', 4, 1, 1),
('002', '大厅', 4, 1, 2),
('003', '大厅', 6, 1, 3),
('A01', '包间', 8, 1, 4),
('A02', '包间', 10, 1, 5);

-- ============================
-- 7. 后台菜单 + 权限（供后台「菜单管理」页面手动配置，此处仅作结构参考）
-- 目录：点餐管理（C，component 为空）
--   ├─ 菜品分类（M，component=catering/category/index，perm=catering:category:list）
--   ├─ 菜品管理（M，component=catering/dish/index，perm=catering:dish:list）
--   ├─ 桌台管理（M，component=catering/table/index，perm=catering:table:list）
--   ├─ 订单管理（M，component=catering/order/index，perm=catering:order:list）
--   └─ 销售统计（M，component=catering/sales/index，perm=catering:sales:list）
-- 各菜单下再挂按钮权限（B），如：
--   catering:category:create/update/delete
--   catering:dish:create/update/delete
--   catering:table:create/update/delete
--   catering:order:detail/receive/settle/cancel/delete
-- 注：超级管理员（ROOT）默认放行，无需逐条授权。
-- ============================
