/*
 Navicat Premium Dump SQL

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 80012 (8.0.12)
 Source Host           : localhost:3306
 Source Schema         : youlai_admin

 Target Server Type    : MySQL
 Target Server Version : 80012 (8.0.12)
 File Encoding         : 65001

 Date: 21/06/2026 20:12:07
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `config_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置名称',
  `config_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置key',
  `config_value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置值',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人ID',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` bigint(20) NULL DEFAULT NULL COMMENT '更新人ID',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '逻辑删除标识(0-未删除 1-已删除)',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_config
-- ----------------------------
INSERT INTO `sys_config` VALUES (1, '系统限流QPS', 'IP_QPS_THRESHOLD_LIMIT', '10', '单个IP请求的最大每秒查询数（QPS）阈值Key', '2026-06-16 23:01:53', 1, NULL, NULL, 0);

-- ----------------------------
-- Table structure for sys_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_dept`;
CREATE TABLE `sys_dept`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '部门名称',
  `code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '部门编号',
  `parent_id` bigint(20) NULL DEFAULT 0 COMMENT '父节点id',
  `tree_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '父节点id路径',
  `sort` smallint(6) NULL DEFAULT 0 COMMENT '显示顺序',
  `status` tinyint(4) NULL DEFAULT 1 COMMENT '状态(1-正常 0-禁用)',
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint(20) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint(4) NULL DEFAULT 0 COMMENT '逻辑删除标识(1-已删除 0-未删除)',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_code`(`code` ASC) USING BTREE COMMENT '部门编号唯一索引'
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '部门管理表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dept
-- ----------------------------
INSERT INTO `sys_dept` VALUES (4, '荷源', 'HEYUAN', 0, '0', 1, 1, 2, '2026-06-18 10:47:08', 2, '2026-06-18 10:47:08', 0);
INSERT INTO `sys_dept` VALUES (5, '生产部', 'production', 4, '0/4', 1, 1, 2, '2026-06-18 10:49:31', 2, '2026-06-18 10:50:32', 0);
INSERT INTO `sys_dept` VALUES (6, '运营部', 'operation', 4, '0/4', 2, 1, 2, '2026-06-18 10:49:59', 2, '2026-06-18 10:50:41', 0);
INSERT INTO `sys_dept` VALUES (7, '财务部', 'finance', 4, '0/4', 3, 1, 2, '2026-06-18 10:51:07', 2, '2026-06-18 10:51:07', 0);
INSERT INTO `sys_dept` VALUES (8, '综合管理部', 'admin', 4, '0/4', 4, 1, 2, '2026-06-18 10:51:32', 2, '2026-06-18 10:51:32', 0);
INSERT INTO `sys_dept` VALUES (9, '开发部', 'dev', 4, '0/4', 5, 1, 2, '2026-06-18 10:52:45', 2, '2026-06-18 10:52:45', 0);

-- ----------------------------
-- Table structure for sys_dict
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict`;
CREATE TABLE `sys_dict`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键 ',
  `dict_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '类型编码',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '类型名称',
  `status` tinyint(1) NULL DEFAULT 0 COMMENT '状态(0:正常;1:禁用)',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人ID',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` bigint(20) NULL DEFAULT NULL COMMENT '修改人ID',
  `is_deleted` tinyint(4) NULL DEFAULT 0 COMMENT '是否删除(1-删除，0-未删除)',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_dict_code`(`dict_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '数据字典类型表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict
-- ----------------------------
INSERT INTO `sys_dict` VALUES (1, 'gender', '性别', 1, NULL, '2026-06-16 23:01:52', 1, '2026-06-16 23:01:52', 1, 0);
INSERT INTO `sys_dict` VALUES (2, 'notice_type', '通知类型', 1, NULL, '2026-06-16 23:01:52', 1, '2026-06-16 23:01:52', 1, 0);
INSERT INTO `sys_dict` VALUES (3, 'notice_level', '通知级别', 1, NULL, '2026-06-16 23:01:52', 1, '2026-06-16 23:01:52', 1, 0);

-- ----------------------------
-- Table structure for sys_dict_item
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_item`;
CREATE TABLE `sys_dict_item`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `dict_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关联字典编码，与sys_dict表中的dict_code对应',
  `value` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '字典项值',
  `label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '字典项标签',
  `tag_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '标签类型，用于前端样式展示（如success、warning等）',
  `status` tinyint(4) NULL DEFAULT 0 COMMENT '状态（1-正常，0-禁用）',
  `sort` int(11) NULL DEFAULT 0 COMMENT '排序',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人ID',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` bigint(20) NULL DEFAULT NULL COMMENT '修改人ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '数据字典项表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict_item
-- ----------------------------
INSERT INTO `sys_dict_item` VALUES (1, 'gender', '1', '男', 'primary', 1, 1, NULL, '2026-06-16 23:01:52', 1, '2026-06-16 23:01:52', 1);
INSERT INTO `sys_dict_item` VALUES (2, 'gender', '2', '女', 'danger', 1, 2, NULL, '2026-06-16 23:01:52', 1, '2026-06-16 23:01:52', 1);
INSERT INTO `sys_dict_item` VALUES (3, 'gender', '0', '保密', 'info', 1, 3, NULL, '2026-06-16 23:01:52', 1, '2026-06-16 23:01:52', 1);
INSERT INTO `sys_dict_item` VALUES (4, 'notice_type', '1', '系统升级', 'success', 1, 1, '', '2026-06-16 23:01:52', 1, '2026-06-16 23:01:52', 1);
INSERT INTO `sys_dict_item` VALUES (5, 'notice_type', '2', '系统维护', 'primary', 1, 2, '', '2026-06-16 23:01:52', 1, '2026-06-16 23:01:52', 1);
INSERT INTO `sys_dict_item` VALUES (6, 'notice_type', '3', '安全警告', 'danger', 1, 3, '', '2026-06-16 23:01:52', 1, '2026-06-16 23:01:52', 1);
INSERT INTO `sys_dict_item` VALUES (7, 'notice_type', '4', '假期通知', 'success', 1, 4, '', '2026-06-16 23:01:52', 1, '2026-06-16 23:01:52', 1);
INSERT INTO `sys_dict_item` VALUES (8, 'notice_type', '5', '公司新闻', 'primary', 1, 5, '', '2026-06-16 23:01:52', 1, '2026-06-16 23:01:52', 1);
INSERT INTO `sys_dict_item` VALUES (9, 'notice_type', '99', '其他', 'info', 1, 99, '', '2026-06-16 23:01:52', 1, '2026-06-16 23:01:52', 1);
INSERT INTO `sys_dict_item` VALUES (10, 'notice_level', 'L', '低', 'info', 1, 1, '', '2026-06-16 23:01:52', 1, '2026-06-16 23:01:52', 1);
INSERT INTO `sys_dict_item` VALUES (11, 'notice_level', 'M', '中', 'warning', 1, 2, '', '2026-06-16 23:01:52', 1, '2026-06-16 23:01:52', 1);
INSERT INTO `sys_dict_item` VALUES (12, 'notice_level', 'H', '高', 'danger', 1, 3, '', '2026-06-16 23:01:52', 1, '2026-06-16 23:01:52', 1);

-- ----------------------------
-- Table structure for sys_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_log`;
CREATE TABLE `sys_log`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `module` tinyint(4) NOT NULL COMMENT '模块，数字枚举，参考 LogModule 枚举',
  `action_type` tinyint(4) NOT NULL COMMENT '操作类型，数字枚举，参考 ActionType 枚举',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '前端显示标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '自定义日志内容',
  `operator_id` bigint(20) NULL DEFAULT NULL COMMENT '操作人ID',
  `operator_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人名称',
  `request_uri` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请求路径',
  `request_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请求方法',
  `ip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `province` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '省份',
  `city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '城市',
  `device` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '设备',
  `os` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作系统',
  `browser` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '浏览器',
  `status` tinyint(4) NULL DEFAULT 1 COMMENT '0失败 1成功',
  `error_msg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '错误信息',
  `execution_time` int(11) NULL DEFAULT NULL COMMENT '执行时间(ms)',
  `create_time` datetime NULL DEFAULT NULL COMMENT '操作时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_module_action_time`(`module` ASC, `action_type` ASC, `create_time` ASC) USING BTREE,
  INDEX `idx_operator_time`(`operator_id` ASC, `create_time` ASC) USING BTREE,
  INDEX `idx_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 40 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统操作日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_log
-- ----------------------------
INSERT INTO `sys_log` VALUES (1, 5, 5, '菜单管理-删除', NULL, 2, 'admin', '/api/v1/menus/2', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 110, '2026-06-17 19:19:53');
INSERT INTO `sys_log` VALUES (2, 5, 5, '菜单管理-删除', NULL, 2, 'admin', '/api/v1/menus/6', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 92, '2026-06-17 19:30:02');
INSERT INTO `sys_log` VALUES (3, 5, 5, '菜单管理-删除', NULL, 2, 'admin', '/api/v1/menus/7', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 82, '2026-06-17 19:30:54');
INSERT INTO `sys_log` VALUES (4, 5, 5, '菜单管理-删除', NULL, 2, 'admin', '/api/v1/menus/8', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 14, '2026-06-17 19:31:03');
INSERT INTO `sys_log` VALUES (5, 5, 5, '菜单管理-删除', NULL, 2, 'admin', '/api/v1/menus/9', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 15, '2026-06-17 19:31:12');
INSERT INTO `sys_log` VALUES (6, 5, 5, '菜单管理-删除', NULL, 2, 'admin', '/api/v1/menus/4', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 67, '2026-06-17 19:34:47');
INSERT INTO `sys_log` VALUES (7, 5, 5, '菜单管理-删除', NULL, 2, 'admin', '/api/v1/menus/5', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 19, '2026-06-17 19:34:49');
INSERT INTO `sys_log` VALUES (8, 2, 4, '用户管理-修改', NULL, 2, 'admin', '/api/v1/users/2', 'PUT', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 86, '2026-06-17 19:52:21');
INSERT INTO `sys_log` VALUES (9, 1, 2, '登录-登出', NULL, NULL, NULL, '/api/v1/auth/logout', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 1, '2026-06-17 22:07:32');
INSERT INTO `sys_log` VALUES (10, 1, 2, '登录-登出', NULL, NULL, NULL, '/api/v1/auth/logout', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 1, '2026-06-18 00:34:25');
INSERT INTO `sys_log` VALUES (11, 2, 5, '用户管理-删除', NULL, 2, 'admin', '/api/v1/users/7', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 72, '2026-06-18 10:23:02');
INSERT INTO `sys_log` VALUES (12, 2, 5, '用户管理-删除', NULL, 2, 'admin', '/api/v1/users/6', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 12, '2026-06-18 10:23:05');
INSERT INTO `sys_log` VALUES (13, 2, 5, '用户管理-删除', NULL, 2, 'admin', '/api/v1/users/5', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 12, '2026-06-18 10:23:08');
INSERT INTO `sys_log` VALUES (14, 2, 5, '用户管理-删除', NULL, 2, 'admin', '/api/v1/users/4', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 14, '2026-06-18 10:23:10');
INSERT INTO `sys_log` VALUES (15, 2, 5, '用户管理-删除', NULL, 2, 'admin', '/api/v1/users/3', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 14, '2026-06-18 10:23:14');
INSERT INTO `sys_log` VALUES (16, 3, 5, '角色管理-删除', NULL, 2, 'admin', '/api/v1/roles/7', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 16, '2026-06-18 10:23:24');
INSERT INTO `sys_log` VALUES (17, 3, 5, '角色管理-删除', NULL, 2, 'admin', '/api/v1/roles/6', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 28, '2026-06-18 10:23:27');
INSERT INTO `sys_log` VALUES (18, 3, 5, '角色管理-删除', NULL, 2, 'admin', '/api/v1/roles/5', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 29, '2026-06-18 10:23:29');
INSERT INTO `sys_log` VALUES (19, 3, 5, '角色管理-删除', NULL, 2, 'admin', '/api/v1/roles/4', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 30, '2026-06-18 10:23:33');
INSERT INTO `sys_log` VALUES (20, 3, 5, '角色管理-删除', NULL, 2, 'admin', '/api/v1/roles/3', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 14, '2026-06-18 10:23:37');
INSERT INTO `sys_log` VALUES (21, 4, 5, '部门管理-删除', NULL, 2, 'admin', '/api/v1/depts/3', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 112, '2026-06-18 10:24:40');
INSERT INTO `sys_log` VALUES (22, 4, 5, '部门管理-删除', NULL, 2, 'admin', '/api/v1/depts/2', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 11, '2026-06-18 10:24:43');
INSERT INTO `sys_log` VALUES (23, 4, 4, '部门管理-修改', NULL, 2, 'admin', '/api/v1/depts/5', 'PUT', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 106, '2026-06-18 10:50:13');
INSERT INTO `sys_log` VALUES (24, 4, 4, '部门管理-修改', NULL, 2, 'admin', '/api/v1/depts/5', 'PUT', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 106, '2026-06-18 10:50:32');
INSERT INTO `sys_log` VALUES (25, 4, 4, '部门管理-修改', NULL, 2, 'admin', '/api/v1/depts/6', 'PUT', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 46, '2026-06-18 10:50:41');
INSERT INTO `sys_log` VALUES (26, 2, 4, '用户管理-修改', NULL, 2, 'admin', '/api/v1/users/2', 'PUT', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 87, '2026-06-18 11:15:45');
INSERT INTO `sys_log` VALUES (27, 4, 5, '部门管理-删除', NULL, 2, 'admin', '/api/v1/depts/1', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 120, '2026-06-18 11:19:28');
INSERT INTO `sys_log` VALUES (28, 1, 2, '登录-登出', NULL, NULL, NULL, '/api/v1/auth/logout', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 0, '2026-06-18 14:32:39');
INSERT INTO `sys_log` VALUES (29, 2, 4, '用户管理-修改', NULL, 1, 'root', '/api/v1/users/password', 'PUT', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 0, 'Business Exception', 1, '2026-06-18 14:35:56');
INSERT INTO `sys_log` VALUES (30, 2, 4, '用户管理-修改', NULL, 1, 'root', '/api/v1/users/password', 'PUT', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 0, 'Business Exception', 0, '2026-06-18 14:36:47');
INSERT INTO `sys_log` VALUES (31, 2, 4, '用户管理-修改', NULL, 1, 'root', '/api/v1/users/password', 'PUT', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 0, 'Business Exception', 0, '2026-06-18 14:39:17');
INSERT INTO `sys_log` VALUES (32, 2, 5, '用户管理-删除', NULL, 1, 'root', '/api/v1/users/mobile', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 1, '2026-06-18 14:57:24');
INSERT INTO `sys_log` VALUES (33, 2, 4, '用户管理-修改', NULL, 1, 'root', '/api/v1/users/profile', 'PUT', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 28, '2026-06-18 15:00:18');
INSERT INTO `sys_log` VALUES (34, 2, 4, '用户管理-修改', NULL, 1, 'root', '/api/v1/users/profile', 'PUT', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 45, '2026-06-18 15:50:58');
INSERT INTO `sys_log` VALUES (35, 1, 2, '登录-登出', NULL, NULL, NULL, '/api/v1/auth/logout', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 0, '2026-06-18 15:53:28');
INSERT INTO `sys_log` VALUES (36, 2, 4, '用户管理-修改', NULL, 2, 'admin', '/api/v1/users/profile', 'PUT', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 74, '2026-06-18 15:58:26');
INSERT INTO `sys_log` VALUES (37, 1, 2, '登录-登出', NULL, NULL, NULL, '/api/v1/auth/logout', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 0, '2026-06-18 16:04:25');
INSERT INTO `sys_log` VALUES (38, 2, 4, '用户管理-修改', NULL, 1, 'root', '/api/v1/users/profile', 'PUT', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 27, '2026-06-18 16:04:59');
INSERT INTO `sys_log` VALUES (39, 1, 2, '登录-登出', NULL, NULL, NULL, '/api/v1/auth/logout', 'DELETE', '::1', NULL, NULL, 'Windows 10', 'Windows 10', 'Edge 149.0.0.0', 1, NULL, 1, '2026-06-18 16:05:37');

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `parent_id` bigint(20) NOT NULL COMMENT '父菜单ID',
  `tree_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '父节点ID路径',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '菜单名称',
  `type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '菜单类型（C-目录 M-菜单 B-按钮）',
  `route_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '路由名称（Vue Router 中用于命名路由）',
  `route_path` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '路由路径（Vue Router 中定义的 URL 路径）',
  `component` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '组件路径（组件页面完整路径，相对于 src/views/，缺省后缀 .vue）',
  `perm` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '【按钮】权限标识',
  `always_show` tinyint(4) NULL DEFAULT 0 COMMENT '【目录】只有一个子路由是否始终显示（1-是 0-否）',
  `keep_alive` tinyint(4) NULL DEFAULT 0 COMMENT '【菜单】是否开启页面缓存（1-是 0-否）',
  `visible` tinyint(1) NULL DEFAULT 1 COMMENT '显示状态（1-显示 0-隐藏）',
  `sort` int(11) NULL DEFAULT 0 COMMENT '排序',
  `icon` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '菜单图标',
  `redirect` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '跳转路径',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `params` json NULL COMMENT '路由参数',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2807 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统菜单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES (1, 0, '0', '系统管理', 'C', '', '/system', 'Layout', NULL, NULL, NULL, 1, 1, 'system', '/system/user', '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (210, 1, '0,1', '用户管理', 'M', 'User', 'user', 'system/user/index', NULL, NULL, 1, 1, 1, 'el-icon-User', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (220, 1, '0,1', '角色管理', 'M', 'Role', 'role', 'system/role/index', NULL, NULL, 1, 1, 2, 'role', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (230, 1, '0,1', '菜单管理', 'M', 'SysMenu', 'menu', 'system/menu/index', NULL, NULL, 1, 1, 3, 'menu', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (240, 1, '0,1', '部门管理', 'M', 'Dept', 'dept', 'system/dept/index', NULL, NULL, 1, 1, 4, 'tree', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (250, 1, '0,1', '字典管理', 'M', 'Dict', 'dict', 'system/dict/index', NULL, NULL, 1, 1, 5, 'dict', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (251, 1, '0,1', '字典项', 'M', 'DictItem', 'dict-item', 'system/dict/dict-item', NULL, 0, 1, 0, 6, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (260, 1, '0,1', '系统日志', 'M', 'Log', 'log', 'system/log/index', NULL, 0, 1, 1, 7, 'document', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (270, 1, '0,1', '系统配置', 'M', 'Config', 'config', 'system/config/index', NULL, 0, 1, 1, 8, 'setting', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (280, 1, '0,1', '通知公告', 'M', 'Notice', 'notice', 'system/notice/index', NULL, NULL, NULL, 1, 9, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2101, 210, '0,1,210', '用户查询', 'B', NULL, '', NULL, 'sys:user:list', NULL, NULL, 1, 1, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2102, 210, '0,1,210', '用户新增', 'B', NULL, '', NULL, 'sys:user:create', NULL, NULL, 1, 2, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2103, 210, '0,1,210', '用户编辑', 'B', NULL, '', NULL, 'sys:user:update', NULL, NULL, 1, 3, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2104, 210, '0,1,210', '用户删除', 'B', NULL, '', NULL, 'sys:user:delete', NULL, NULL, 1, 4, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2105, 210, '0,1,210', '重置密码', 'B', NULL, '', NULL, 'sys:user:reset-password', NULL, NULL, 1, 5, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2106, 210, '0,1,210', '用户导入', 'B', NULL, '', NULL, 'sys:user:import', NULL, NULL, 1, 6, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2107, 210, '0,1,210', '用户导出', 'B', NULL, '', NULL, 'sys:user:export', NULL, NULL, 1, 7, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2201, 220, '0,1,220', '角色查询', 'B', NULL, '', NULL, 'sys:role:list', NULL, NULL, 1, 1, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2202, 220, '0,1,220', '角色新增', 'B', NULL, '', NULL, 'sys:role:create', NULL, NULL, 1, 2, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2203, 220, '0,1,220', '角色编辑', 'B', NULL, '', NULL, 'sys:role:update', NULL, NULL, 1, 3, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2204, 220, '0,1,220', '角色删除', 'B', NULL, '', NULL, 'sys:role:delete', NULL, NULL, 1, 4, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2205, 220, '0,1,220', '角色分配权限', 'B', NULL, '', NULL, 'sys:role:assign', NULL, NULL, 1, 5, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2301, 230, '0,1,230', '菜单查询', 'B', NULL, '', NULL, 'sys:menu:list', NULL, NULL, 1, 1, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2302, 230, '0,1,230', '菜单新增', 'B', NULL, '', NULL, 'sys:menu:create', NULL, NULL, 1, 2, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2303, 230, '0,1,230', '菜单编辑', 'B', NULL, '', NULL, 'sys:menu:update', NULL, NULL, 1, 3, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2304, 230, '0,1,230', '菜单删除', 'B', NULL, '', NULL, 'sys:menu:delete', NULL, NULL, 1, 4, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2401, 240, '0,1,240', '部门查询', 'B', NULL, '', NULL, 'sys:dept:list', NULL, NULL, 1, 1, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2402, 240, '0,1,240', '部门新增', 'B', NULL, '', NULL, 'sys:dept:create', NULL, NULL, 1, 2, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2403, 240, '0,1,240', '部门编辑', 'B', NULL, '', NULL, 'sys:dept:update', NULL, NULL, 1, 3, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2404, 240, '0,1,240', '部门删除', 'B', NULL, '', NULL, 'sys:dept:delete', NULL, NULL, 1, 4, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2501, 250, '0,1,250', '字典查询', 'B', NULL, '', NULL, 'sys:dict:list', NULL, NULL, 1, 1, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2502, 250, '0,1,250', '字典新增', 'B', NULL, '', NULL, 'sys:dict:create', NULL, NULL, 1, 2, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2503, 250, '0,1,250', '字典编辑', 'B', NULL, '', NULL, 'sys:dict:update', NULL, NULL, 1, 3, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2504, 250, '0,1,250', '字典删除', 'B', NULL, '', NULL, 'sys:dict:delete', NULL, NULL, 1, 4, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2511, 251, '0,1,251', '字典项查询', 'B', NULL, '', NULL, 'sys:dict-item:list', NULL, NULL, 1, 1, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2512, 251, '0,1,251', '字典项新增', 'B', NULL, '', NULL, 'sys:dict-item:create', NULL, NULL, 1, 2, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2513, 251, '0,1,251', '字典项编辑', 'B', NULL, '', NULL, 'sys:dict-item:update', NULL, NULL, 1, 3, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2514, 251, '0,1,251', '字典项删除', 'B', NULL, '', NULL, 'sys:dict-item:delete', NULL, NULL, 1, 4, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2601, 260, '0,1,260', '日志查询', 'B', NULL, '', NULL, 'sys:log:list', NULL, NULL, 1, 1, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2701, 270, '0,1,270', '系统配置查询', 'B', NULL, '', NULL, 'sys:config:list', 0, 1, 1, 1, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2702, 270, '0,1,270', '系统配置新增', 'B', NULL, '', NULL, 'sys:config:create', 0, 1, 1, 2, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2703, 270, '0,1,270', '系统配置修改', 'B', NULL, '', NULL, 'sys:config:update', 0, 1, 1, 3, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2704, 270, '0,1,270', '系统配置删除', 'B', NULL, '', NULL, 'sys:config:delete', 0, 1, 1, 4, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2705, 270, '0,1,270', '系统配置刷新', 'B', NULL, '', NULL, 'sys:config:refresh', 0, 1, 1, 5, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2801, 280, '0,1,280', '通知查询', 'B', NULL, '', NULL, 'sys:notice:list', NULL, NULL, 1, 1, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2802, 280, '0,1,280', '通知新增', 'B', NULL, '', NULL, 'sys:notice:create', NULL, NULL, 1, 2, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2803, 280, '0,1,280', '通知编辑', 'B', NULL, '', NULL, 'sys:notice:update', NULL, NULL, 1, 3, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2804, 280, '0,1,280', '通知删除', 'B', NULL, '', NULL, 'sys:notice:delete', NULL, NULL, 1, 4, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2805, 280, '0,1,280', '通知发布', 'B', NULL, '', NULL, 'sys:notice:publish', 0, 1, 1, 5, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);
INSERT INTO `sys_menu` VALUES (2806, 280, '0,1,280', '通知撤回', 'B', NULL, '', NULL, 'sys:notice:revoke', 0, 1, 1, 6, '', NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', NULL);

-- ----------------------------
-- Table structure for sys_notice
-- ----------------------------
DROP TABLE IF EXISTS `sys_notice`;
CREATE TABLE `sys_notice`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '通知标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '通知内容',
  `type` tinyint(4) NOT NULL COMMENT '通知类型（关联字典编码：notice_type）',
  `level` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '通知等级（字典code：notice_level）',
  `target_type` tinyint(4) NOT NULL COMMENT '目标类型（1: 全体, 2: 指定）',
  `target_user_ids` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '目标人ID集合（多个使用英文逗号,分割）',
  `publisher_id` bigint(20) NULL DEFAULT NULL COMMENT '发布人ID',
  `publish_status` tinyint(4) NULL DEFAULT 0 COMMENT '发布状态（0: 未发布, 1: 已发布, -1: 已撤回）',
  `publish_time` datetime NULL DEFAULT NULL COMMENT '发布时间',
  `revoke_time` datetime NULL DEFAULT NULL COMMENT '撤回时间',
  `create_by` bigint(20) NOT NULL COMMENT '创建人ID',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_by` bigint(20) NULL DEFAULT NULL COMMENT '更新人ID',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint(1) NULL DEFAULT 0 COMMENT '是否删除（0: 未删除, 1: 已删除）',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统通知公告表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_notice
-- ----------------------------
INSERT INTO `sys_notice` VALUES (1, 'v3.0.0 版本发布 - 多租户功能上线', '<p>🎉 新版本发布，主要更新内容：</p><p>1. 新增多租户功能，支持租户隔离和数据管理</p><p>2. 优化系统性能，提升响应速度</p><p>3. 完善权限管理，增强安全性</p><p>4. 修复已知问题，提升系统稳定性</p>', 1, 'H', 1, NULL, 1, 1, '2024-12-15 10:00:00', NULL, 1, '2024-12-15 10:00:00', 1, '2024-12-15 10:00:00', 0);
INSERT INTO `sys_notice` VALUES (2, '系统维护通知 - 2024年12月20日', '<p>⏰ 系统维护通知</p><p>系统将于 <strong>2024年12月20日（本周五）凌晨 2:00-4:00</strong> 进行例行维护升级。</p><p>维护期间系统将暂停服务，请提前做好数据备份工作。</p><p>给您带来的不便，敬请谅解！</p>', 2, 'H', 1, NULL, 1, 1, '2024-12-18 14:30:00', NULL, 1, '2024-12-18 14:30:00', 1, '2024-12-18 14:30:00', 0);
INSERT INTO `sys_notice` VALUES (3, '安全提醒 - 防范钓鱼邮件', '<p>⚠️ 安全提醒</p><p>近期发现有不法分子通过钓鱼邮件进行网络攻击，请大家提高警惕：</p><p>1. 不要点击来源不明的邮件链接</p><p>2. 不要下载可疑附件</p><p>3. 遇到可疑邮件请及时联系IT部门</p><p>4. 定期修改密码，使用强密码策略</p>', 3, 'H', 1, NULL, 1, 1, '2024-12-10 09:00:00', NULL, 1, '2024-12-10 09:00:00', 1, '2024-12-10 09:00:00', 0);
INSERT INTO `sys_notice` VALUES (4, '元旦假期安排通知', '<p>📅 元旦假期安排</p><p>根据国家法定节假日安排，公司元旦假期时间为：</p><p><strong>2024年12月30日（周一）至 2025年1月1日（周三）</strong>，共3天。</p><p>2024年12月29日（周日）正常上班。</p><p>祝大家元旦快乐，假期愉快！</p>', 4, 'M', 1, NULL, 1, 1, '2024-12-25 16:00:00', NULL, 1, '2024-12-25 16:00:00', 1, '2024-12-25 16:00:00', 0);
INSERT INTO `sys_notice` VALUES (5, '新产品发布会邀请', '<p>🎊 新产品发布会邀请</p><p>公司将于 <strong>2025年1月15日下午14:00</strong> 在总部会议室举办新产品发布会。</p><p>届时将展示最新研发的产品和技术成果，欢迎全体员工参加。</p><p>请各部门提前安排好工作，准时参加。</p>', 5, 'M', 1, NULL, 1, 1, '2024-12-28 11:00:00', NULL, 1, '2024-12-28 11:00:00', 1, '2024-12-28 11:00:00', 0);
INSERT INTO `sys_notice` VALUES (6, 'v2.16.1 版本更新', '<p>✨ 版本更新</p><p>v2.16.1 版本已发布，主要修复内容：</p><p>1. 修复 WebSocket 重复连接导致的后台线程阻塞问题</p><p>2. 优化通知公告功能，提升用户体验</p><p>3. 修复部分已知bug</p><p>建议尽快更新到最新版本。</p>', 1, 'M', 1, NULL, 1, 1, '2024-12-05 15:30:00', NULL, 1, '2024-12-05 15:30:00', 1, '2024-12-05 15:30:00', 0);
INSERT INTO `sys_notice` VALUES (7, '年终总结会议通知', '<p>📋 年终总结会议通知</p><p>各部门年终总结会议将于 <strong>2024年12月30日上午9:00</strong> 召开。</p><p>请各部门负责人提前准备好年度工作总结和下年度工作计划。</p><p>会议地点：总部大会议室</p>', 5, 'M', 2, '1,2', 1, 1, '2024-12-22 10:00:00', NULL, 1, '2024-12-22 10:00:00', 1, '2024-12-22 10:00:00', 0);
INSERT INTO `sys_notice` VALUES (8, '系统功能优化完成', '<p>✅ 系统功能优化</p><p>已完成以下功能优化：</p><p>1. 优化用户管理界面，提升操作体验</p><p>2. 增强数据导出功能，支持更多格式</p><p>3. 优化搜索功能，提升查询效率</p><p>4. 修复部分界面显示问题</p>', 1, 'L', 1, NULL, 1, 1, '2024-12-12 14:20:00', NULL, 1, '2024-12-12 14:20:00', 1, '2024-12-12 14:20:00', 0);
INSERT INTO `sys_notice` VALUES (9, '员工培训计划', '<p>📚 员工培训计划</p><p>为提升员工专业技能，公司将于 <strong>2025年1月8日-10日</strong> 组织技术培训。</p><p>培训内容：</p><p>1. 新技术框架应用</p><p>2. 代码规范与最佳实践</p><p>3. 系统架构设计</p><p>请各部门合理安排工作，确保培训顺利进行。</p>', 5, 'M', 1, NULL, 1, 1, '2024-12-20 09:30:00', NULL, 1, '2024-12-20 09:30:00', 1, '2024-12-20 09:30:00', 0);
INSERT INTO `sys_notice` VALUES (10, '数据备份提醒', '<p>💾 数据备份提醒</p><p>请各部门注意定期备份重要数据，建议每周至少备份一次。</p><p>备份方式：</p><p>1. 使用系统自带备份功能</p><p>2. 手动导出重要数据</p><p>3. 联系IT部门协助备份</p><p>数据安全，人人有责！</p>', 3, 'L', 1, NULL, 1, 1, '2024-12-08 08:00:00', NULL, 1, '2024-12-08 08:00:00', 1, '2024-12-08 08:00:00', 0);

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色名称',
  `code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色编码',
  `sort` int(11) NULL DEFAULT NULL COMMENT '显示顺序',
  `status` tinyint(1) NULL DEFAULT 1 COMMENT '角色状态(1-正常 0-停用)',
  `data_scope` tinyint(4) NULL DEFAULT NULL COMMENT '数据权限(1-所有数据 2-部门及子部门数据 3-本部门数据 4-本人数据 5-自定义部门数据)',
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人 ID',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint(20) NULL DEFAULT NULL COMMENT '更新人ID',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint(1) NULL DEFAULT 0 COMMENT '逻辑删除标识(0-未删除 1-已删除)',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_name`(`name` ASC) USING BTREE COMMENT '角色名称唯一索引',
  UNIQUE INDEX `uk_code`(`code` ASC) USING BTREE COMMENT '角色编码唯一索引'
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统角色表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '超级管理员', 'ROOT', 1, 1, 1, NULL, '2026-06-16 23:01:53', NULL, '2026-06-16 23:01:53', 0);
INSERT INTO `sys_role` VALUES (2, '系统管理员', 'ADMIN', 2, 1, 1, NULL, '2026-06-16 23:01:53', NULL, NULL, 0);

-- ----------------------------
-- Table structure for sys_role_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_dept`;
CREATE TABLE `sys_role_dept`  (
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  `dept_id` bigint(20) NOT NULL COMMENT '部门ID',
  UNIQUE INDEX `uk_roleid_deptid`(`role_id` ASC, `dept_id` ASC) USING BTREE COMMENT '角色部门唯一索引'
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色部门关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_dept
-- ----------------------------
INSERT INTO `sys_role_dept` VALUES (7, 1);
INSERT INTO `sys_role_dept` VALUES (7, 2);

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu`  (
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  `menu_id` bigint(20) NOT NULL COMMENT '菜单ID',
  UNIQUE INDEX `uk_roleid_menuid`(`role_id` ASC, `menu_id` ASC) USING BTREE COMMENT '角色菜单唯一索引'
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色菜单关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_menu
-- ----------------------------
INSERT INTO `sys_role_menu` VALUES (2, 1);
INSERT INTO `sys_role_menu` VALUES (2, 2);
INSERT INTO `sys_role_menu` VALUES (2, 4);
INSERT INTO `sys_role_menu` VALUES (2, 5);
INSERT INTO `sys_role_menu` VALUES (2, 6);
INSERT INTO `sys_role_menu` VALUES (2, 7);
INSERT INTO `sys_role_menu` VALUES (2, 8);
INSERT INTO `sys_role_menu` VALUES (2, 9);
INSERT INTO `sys_role_menu` VALUES (2, 210);
INSERT INTO `sys_role_menu` VALUES (2, 220);
INSERT INTO `sys_role_menu` VALUES (2, 230);
INSERT INTO `sys_role_menu` VALUES (2, 240);
INSERT INTO `sys_role_menu` VALUES (2, 250);
INSERT INTO `sys_role_menu` VALUES (2, 251);
INSERT INTO `sys_role_menu` VALUES (2, 260);
INSERT INTO `sys_role_menu` VALUES (2, 270);
INSERT INTO `sys_role_menu` VALUES (2, 280);
INSERT INTO `sys_role_menu` VALUES (2, 310);
INSERT INTO `sys_role_menu` VALUES (2, 501);
INSERT INTO `sys_role_menu` VALUES (2, 502);
INSERT INTO `sys_role_menu` VALUES (2, 503);
INSERT INTO `sys_role_menu` VALUES (2, 504);
INSERT INTO `sys_role_menu` VALUES (2, 601);
INSERT INTO `sys_role_menu` VALUES (2, 701);
INSERT INTO `sys_role_menu` VALUES (2, 702);
INSERT INTO `sys_role_menu` VALUES (2, 703);
INSERT INTO `sys_role_menu` VALUES (2, 704);
INSERT INTO `sys_role_menu` VALUES (2, 705);
INSERT INTO `sys_role_menu` VALUES (2, 706);
INSERT INTO `sys_role_menu` VALUES (2, 707);
INSERT INTO `sys_role_menu` VALUES (2, 708);
INSERT INTO `sys_role_menu` VALUES (2, 709);
INSERT INTO `sys_role_menu` VALUES (2, 801);
INSERT INTO `sys_role_menu` VALUES (2, 802);
INSERT INTO `sys_role_menu` VALUES (2, 803);
INSERT INTO `sys_role_menu` VALUES (2, 804);
INSERT INTO `sys_role_menu` VALUES (2, 910);
INSERT INTO `sys_role_menu` VALUES (2, 911);
INSERT INTO `sys_role_menu` VALUES (2, 912);
INSERT INTO `sys_role_menu` VALUES (2, 913);
INSERT INTO `sys_role_menu` VALUES (2, 1001);
INSERT INTO `sys_role_menu` VALUES (2, 1002);
INSERT INTO `sys_role_menu` VALUES (2, 2101);
INSERT INTO `sys_role_menu` VALUES (2, 2102);
INSERT INTO `sys_role_menu` VALUES (2, 2103);
INSERT INTO `sys_role_menu` VALUES (2, 2104);
INSERT INTO `sys_role_menu` VALUES (2, 2105);
INSERT INTO `sys_role_menu` VALUES (2, 2106);
INSERT INTO `sys_role_menu` VALUES (2, 2107);
INSERT INTO `sys_role_menu` VALUES (2, 2201);
INSERT INTO `sys_role_menu` VALUES (2, 2202);
INSERT INTO `sys_role_menu` VALUES (2, 2203);
INSERT INTO `sys_role_menu` VALUES (2, 2204);
INSERT INTO `sys_role_menu` VALUES (2, 2205);
INSERT INTO `sys_role_menu` VALUES (2, 2301);
INSERT INTO `sys_role_menu` VALUES (2, 2302);
INSERT INTO `sys_role_menu` VALUES (2, 2303);
INSERT INTO `sys_role_menu` VALUES (2, 2304);
INSERT INTO `sys_role_menu` VALUES (2, 2401);
INSERT INTO `sys_role_menu` VALUES (2, 2402);
INSERT INTO `sys_role_menu` VALUES (2, 2403);
INSERT INTO `sys_role_menu` VALUES (2, 2404);
INSERT INTO `sys_role_menu` VALUES (2, 2501);
INSERT INTO `sys_role_menu` VALUES (2, 2502);
INSERT INTO `sys_role_menu` VALUES (2, 2503);
INSERT INTO `sys_role_menu` VALUES (2, 2504);
INSERT INTO `sys_role_menu` VALUES (2, 2511);
INSERT INTO `sys_role_menu` VALUES (2, 2512);
INSERT INTO `sys_role_menu` VALUES (2, 2513);
INSERT INTO `sys_role_menu` VALUES (2, 2514);
INSERT INTO `sys_role_menu` VALUES (2, 2601);
INSERT INTO `sys_role_menu` VALUES (2, 2701);
INSERT INTO `sys_role_menu` VALUES (2, 2702);
INSERT INTO `sys_role_menu` VALUES (2, 2703);
INSERT INTO `sys_role_menu` VALUES (2, 2704);
INSERT INTO `sys_role_menu` VALUES (2, 2705);
INSERT INTO `sys_role_menu` VALUES (2, 2801);
INSERT INTO `sys_role_menu` VALUES (2, 2802);
INSERT INTO `sys_role_menu` VALUES (2, 2803);
INSERT INTO `sys_role_menu` VALUES (2, 2804);
INSERT INTO `sys_role_menu` VALUES (2, 2805);
INSERT INTO `sys_role_menu` VALUES (2, 2806);

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户名',
  `nickname` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '昵称',
  `gender` tinyint(1) NULL DEFAULT 1 COMMENT '性别((1-男 2-女 0-保密)',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '密码',
  `dept_id` int(11) NULL DEFAULT NULL COMMENT '部门ID',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户头像',
  `mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系方式',
  `status` tinyint(1) NULL DEFAULT 1 COMMENT '状态(1-正常 0-禁用)',
  `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户邮箱',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人ID',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` bigint(20) NULL DEFAULT NULL COMMENT '修改人ID',
  `is_deleted` tinyint(1) NULL DEFAULT 0 COMMENT '逻辑删除标识(0-未删除 1-已删除)',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'root', '荷源-超级管理员', 0, '$2b$10$Cg/ZM23EayJ0oQ4pDBtEn.DhK9G6ExPMZPMysDNSISRH8v5WRuJze', NULL, '/uploads/20260618/e5c04806-66f7-44f2-9b40-311d81d40bed.png', '18325093411', 1, '2260107228@qq.com', '2026-06-16 23:01:53', NULL, '2026-06-18 16:04:59', 1, 0);
INSERT INTO `sys_user` VALUES (2, 'admin', '系统管理员', 1, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', 4, '/uploads/20260618/640836f5-350d-4325-b2f1-06519b3ee946.png', '18888888888', 1, 'youlaitech@163.com', '2026-06-16 23:01:53', NULL, '2026-06-18 15:58:26', 2, 0);

-- ----------------------------
-- Table structure for sys_user_notice
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_notice`;
CREATE TABLE `sys_user_notice`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `notice_id` bigint(20) NOT NULL COMMENT '公共通知id',
  `user_id` bigint(20) NOT NULL COMMENT '用户id',
  `is_read` tinyint(4) NULL DEFAULT 0 COMMENT '读取状态（0: 未读, 1: 已读）',
  `read_time` datetime NULL DEFAULT NULL COMMENT '阅读时间',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint(4) NULL DEFAULT 0 COMMENT '逻辑删除(0: 未删除, 1: 已删除)',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户通知公告关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_notice
-- ----------------------------
INSERT INTO `sys_user_notice` VALUES (1, 1, 2, 1, NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', 0);
INSERT INTO `sys_user_notice` VALUES (2, 2, 2, 1, NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', 0);
INSERT INTO `sys_user_notice` VALUES (3, 3, 2, 1, NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', 0);
INSERT INTO `sys_user_notice` VALUES (4, 4, 2, 1, NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', 0);
INSERT INTO `sys_user_notice` VALUES (5, 5, 2, 1, NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', 0);
INSERT INTO `sys_user_notice` VALUES (6, 6, 2, 1, NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', 0);
INSERT INTO `sys_user_notice` VALUES (7, 7, 2, 1, NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', 0);
INSERT INTO `sys_user_notice` VALUES (8, 8, 2, 1, NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', 0);
INSERT INTO `sys_user_notice` VALUES (9, 9, 2, 1, NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', 0);
INSERT INTO `sys_user_notice` VALUES (10, 10, 2, 1, NULL, '2026-06-16 23:01:53', '2026-06-16 23:01:53', 0);

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`, `role_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户角色关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES (1, 1);
INSERT INTO `sys_user_role` VALUES (2, 2);

-- ----------------------------
-- Table structure for sys_user_social
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_social`;
CREATE TABLE `sys_user_social`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `platform` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '平台类型(WECHAT_MINI/WECHAT_MP/ALIPAY/QQ/APPLE)',
  `openid` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '平台openid',
  `unionid` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '微信unionid',
  `nickname` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '第三方昵称',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '第三方头像URL',
  `session_key` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '微信session_key',
  `verified` tinyint(1) NULL DEFAULT 1 COMMENT '是否已验证(1-已验证 0-未验证)',
  `create_time` datetime NULL DEFAULT NULL COMMENT '绑定时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_platform_openid`(`platform` ASC, `openid` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_unionid`(`unionid` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户第三方账号绑定表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_social
-- ----------------------------

-- ----------------------------
-- Table structure for sys_rag_document (RAG 知识文档元数据)
-- ----------------------------
DROP TABLE IF EXISTS `sys_rag_document`;
CREATE TABLE `sys_rag_document`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '文档ID（同时作为 Milvus 的 document_id）',
  `title` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '文档标题',
  `department_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '所属部门ID',
  `visibility` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'department' COMMENT '可见性(company-公司/department-部门)',
  `version` int(11) NOT NULL DEFAULT 0 COMMENT '当前版本号',
  `chunk_count` int(11) NOT NULL DEFAULT 0 COMMENT '当前版本 chunk 数',
  `checksum` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '内容校验和',
  `source_path` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '原始 markdown 存储路径',
  `create_by` bigint(20) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint(20) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '逻辑删除标识(0-未删除 1-已删除)',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'RAG知识文档元数据表' ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
