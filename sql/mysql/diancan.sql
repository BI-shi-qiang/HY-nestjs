/*
 点餐模块表结构 + 示例种子数据（完整版，含桌台、沽清/口味/描述等字段）
 执行方式：在 heyuan 库下执行本文件即可
*/
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for dish_category
-- ----------------------------
DROP TABLE IF EXISTS `dish_category`;
CREATE TABLE `dish_category` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '分类名称',
  `sort` int(11) NOT NULL DEFAULT 0 COMMENT '排序',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '状态(1-启用 0-停用)',
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint(20) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '逻辑删除标识(0-未删除 1-已删除)',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '菜品分类表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for dish
-- ----------------------------
DROP TABLE IF EXISTS `dish`;
CREATE TABLE `dish` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `category_id` bigint(20) NOT NULL COMMENT '分类ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '菜品名称',
  `unit_price` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '单价',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '份' COMMENT '单位',
  `monthly_sale` int(11) NOT NULL DEFAULT 0 COMMENT '月销量',
  `image` json NULL COMMENT '图片数组[{url}]',
  `sort` int(11) NOT NULL DEFAULT 0 COMMENT '排序',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '状态(1-上架 0-下架)',
  `sold_out` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否沽清(0-正常 1-沽清)',
  `flavor` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '口味/辣度标签',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '菜品描述',
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint(20) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '逻辑删除标识(0-未删除 1-已删除)',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_category` (`category_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '菜品表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for dining_table
-- ----------------------------
DROP TABLE IF EXISTS `dining_table`;
CREATE TABLE `dining_table` (
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

-- ----------------------------
-- Table structure for dish_order
-- ----------------------------
DROP TABLE IF EXISTS `dish_order`;
CREATE TABLE `dish_order` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `table_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '桌号',
  `table_id` bigint(20) NULL DEFAULT NULL COMMENT '桌台ID',
  `user_id` bigint(20) NULL DEFAULT NULL COMMENT '下单用户ID',
  `number_of_diners` int(11) NOT NULL DEFAULT 0 COMMENT '就餐人数',
  `order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '订单号',
  `order_time` datetime NULL DEFAULT NULL COMMENT '下单时间',
  `settle_amount` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '总金额',
  `transac_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'unsettled' COMMENT '结账状态(unsettled未结账 settled已结账)',
  `order_receiving` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending' COMMENT '接单状态(pending待接单 received已接单 making制作中 finished已完成 cancelled已取消)',
  `pay_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付方式(wechat微信 cash现金)',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `menu` json NULL COMMENT '菜品列表[{backup_data, goods_list}]',
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint(20) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '逻辑删除标识(0-未删除 1-已删除)',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_order_no` (`order_no`) USING BTREE,
  KEY `idx_table_status` (`table_number`, `transac_status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '点餐订单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sales_stat
-- ----------------------------
DROP TABLE IF EXISTS `sales_stat`;
CREATE TABLE `sales_stat` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `stat_date` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '统计日期 YYYY-MM-DD',
  `amount` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '当日销售额',
  `order_count` int(11) NOT NULL DEFAULT 0 COMMENT '当日订单数',
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint(20) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '逻辑删除标识(0-未删除 1-已删除)',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_stat_date` (`stat_date`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '日销售额统计表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of dish_category
-- ----------------------------
INSERT INTO `dish_category` (`id`, `name`, `sort`) VALUES
(1, '热菜', 1),
(2, '凉菜', 2),
(3, '汤羹', 3),
(4, '主食', 4),
(5, '饮品', 5);

-- ----------------------------
-- Records of dish（图片为占位 URL，后续替换成真实图片）
-- ----------------------------
INSERT INTO `dish` (`category_id`, `name`, `unit_price`, `unit`, `monthly_sale`, `image`, `sort`, `status`) VALUES
(1, '宫保鸡丁', 28.00, '份', 120, '[{"url":"https://dummyimage.com/300x300/ffb74d/ffffff"}]', 1, 1),
(1, '鱼香肉丝', 26.00, '份', 98,  '[{"url":"https://dummyimage.com/300x300/ffb74d/ffffff"}]', 2, 1),
(1, '麻婆豆腐', 18.00, '份', 86,  '[{"url":"https://dummyimage.com/300x300/ffb74d/ffffff"}]', 3, 1),
(1, '糖醋里脊', 32.00, '份', 75,  '[{"url":"https://dummyimage.com/300x300/ffb74d/ffffff"}]', 4, 1),
(2, '拍黄瓜',   12.00, '份', 60,  '[{"url":"https://dummyimage.com/300x300/81c784/ffffff"}]', 1, 1),
(2, '凉拌木耳', 15.00, '份', 54,  '[{"url":"https://dummyimage.com/300x300/81c784/ffffff"}]', 2, 1),
(2, '口水鸡',   28.00, '份', 66,  '[{"url":"https://dummyimage.com/300x300/81c784/ffffff"}]', 3, 1),
(3, '西红柿蛋汤', 12.00, '份', 80, '[{"url":"https://dummyimage.com/300x300/4fc3f7/ffffff"}]', 1, 1),
(3, '紫菜蛋花汤', 10.00, '份', 72, '[{"url":"https://dummyimage.com/300x300/4fc3f7/ffffff"}]', 2, 1),
(3, '玉米排骨汤', 26.00, '份', 45, '[{"url":"https://dummyimage.com/300x300/4fc3f7/ffffff"}]', 3, 1),
(4, '米饭',     2.00, '碗', 500, '[{"url":"https://dummyimage.com/300x300/ffd54f/ffffff"}]', 1, 1),
(4, '蛋炒饭',   15.00, '份', 110, '[{"url":"https://dummyimage.com/300x300/ffd54f/ffffff"}]', 2, 1),
(4, '手工水饺', 18.00, '份', 90,  '[{"url":"https://dummyimage.com/300x300/ffd54f/ffffff"}]', 3, 1),
(5, '可乐',     5.00, '瓶', 200,  '[{"url":"https://dummyimage.com/300x300/f06292/ffffff"}]', 1, 1),
(5, '鲜榨橙汁', 12.00, '杯', 85,  '[{"url":"https://dummyimage.com/300x300/f06292/ffffff"}]', 2, 1),
(5, '酸梅汤',   8.00, '杯', 95,   '[{"url":"https://dummyimage.com/300x300/f06292/ffffff"}]', 3, 1);

-- ----------------------------
-- Records of dining_table
-- ----------------------------
INSERT INTO `dining_table` (`table_no`, `area`, `seat_count`, `status`, `sort`) VALUES
('001', '大厅', 4, 1, 1),
('002', '大厅', 4, 1, 2),
('003', '大厅', 6, 1, 3),
('A01', '包间', 8, 1, 4),
('A02', '包间', 10, 1, 5);

SET FOREIGN_KEY_CHECKS = 1;
