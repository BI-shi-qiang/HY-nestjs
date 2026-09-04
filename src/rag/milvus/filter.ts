import type { RagUser } from "../rag.types";

// 字符串中处理反斜杠和双引号
export function escapeFilterValue(value: string): string {
  return value.replace("\\", "\\\\").replaceAll('"', '\\"');
}

// 构造Milvus字符串的等值表达式
export function equal(field: string, value: string): string {
  return `${field} == "${escapeFilterValue(value)}"`;
}

// 确认用户身份，限制查看文档;管理员看全部文档，普通用户看自己部门文档
export function buildPermissionFilter(user: RagUser): string {
  const tenant = equal("tenant_id", user.tenantId);
  const active = "is_active == true";

  if (user.isAdmin) {
    return `${tenant} and ${active}`;
  }

  const department = equal("department_id", user.departmentId);
  return `${tenant} and ${active} and (visibility == "company" or ${department})`;
}

// tenantId就是区分多家公司的字段，选择生效版本，不同公司之间的文档是独立的
export function buildDocumentFilter(
  tenantId: string,
  documentId: string,
  activeOnly = false
): string {
  const parts = [equal("tenant_id", tenantId), equal("document_id", documentId)];

  if (activeOnly) {
    parts.push("is_active == true");
  }

  return parts.join(" and ");
}
