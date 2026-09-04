import type { CurrentUserInfo } from "@/common/interfaces/current-user.interface";

/**
 * 单租户 ID
 * 本项目未开启多租户，rag-try 中的 tenantId 在这里用常量代替；
 * 如需支持多租户，可改为从 config 读取 RAG_TENANT_ID。
 */
export const RAG_TENANT_ID = "heyuan";

/**
 * RAG 模块的用户上下文（替代 rag-try 的 DemoUser）
 */
export interface RagUser {
  /** 租户 ID（单租户常量） */
  tenantId: string;
  /** 用户 ID */
  userId: string;
  /** 所属部门 ID */
  departmentId: string;
  /** 是否为管理员（可查看全部文档） */
  isAdmin: boolean;
}

/**
 * 从 JWT 用户对象转换为 RAG 用户上下文
 *
 * 注意：request.user 中并没有 isRoot 字段，需用 roles 判断管理员身份。
 * 超级管理员(ROOT) / 系统管理员(ADMIN) 视为 admin，可查看全部文档。
 */
export function toRagUser(user: CurrentUserInfo): RagUser {
  const roles = user.roles ?? [];
  return {
    tenantId: RAG_TENANT_ID,
    userId: user.userId,
    departmentId: user.deptId ?? "",
    isAdmin: roles.includes("ROOT") || roles.includes("ADMIN"),
  };
}
