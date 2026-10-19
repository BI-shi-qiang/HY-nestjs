/*
 点餐模块：dish_order 增加下单用户ID（支持「我的订单」按用户过滤）
 执行方式：在 heyuan 库下执行本文件即可
*/
ALTER TABLE `dish_order`
  ADD COLUMN `user_id` bigint(20) NULL DEFAULT NULL COMMENT '下单用户ID' AFTER `table_id`;
