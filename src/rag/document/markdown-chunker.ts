import type { Root, RootContent } from "mdast";
import { unified } from "unified";
import remarkParse from "remark-parse";
import { toString } from "mdast-util-to-string";
import type { TextChunk } from "./document.types";

interface Section {
  heading: string;
  paragraphs: string[];
}
// 格式化Markdown字符串
export function normalizeMarkdown(markdown: string): string {
  return markdown.replaceAll("\r\n", "\n").replaceAll("\r", "\n").trim();
}

// 拆成chunk前先按照标题拆成多个章节
function parseSections(markdown: string): Section[] {
  // 解析Markdown字符串为AST树,tree就是根节点，每个节点会包含type、depth、value等属性
  const tree = unified().use(remarkParse).parse(markdown) as Root;
  const sections: Section[] = [];
  const headingPath: string[] = [];
  let current: Section = { heading: "", paragraphs: [] };

  const flush = () => {
    if (current.paragraphs.length > 0) sections.push(current);
  };

  for (const node of tree.children) {
    // 遍历AST树的所有子节点
    if (node.type === "heading") {
      flush();
      const depth = node.depth;
      headingPath.splice(depth - 1);
      headingPath[depth - 1] = toString(node).trim();
      current = {
        heading: headingPath.filter(Boolean).join(" / "),
        paragraphs: [],
      };
      continue;
    }

    const text = nodeToText(node);
    if (text) current.paragraphs.push(text);
  }

  flush();
  return sections;
}

// 处理不同类型的markdown节点
function nodeToText(node: RootContent): string {
  if (node.type === "code") {
    return node.value.trim();
  }

  return toString(node).replace(/\s+/gu, " ").trim();
}

// 处理超过 chunk 最大长度的文本
function splitLongText(text: string, maxLength: number, overlap: number) {
  const parts: string[] = [];
  const step = Math.max(1, maxLength - overlap);

  for (let start = 0; start < text.length; start += step) {
    parts.push(text.slice(start, start + maxLength));
    if (start + maxLength >= text.length) break;
  }

  return parts;
}

// 按照标题段落拆成chunk
export function chunkMarkdown(markdown: string, maxLength = 700, overlap = 80): TextChunk[] {
  const normalized = normalizeMarkdown(markdown);
  if (!normalized) return [];

  const chunks: string[] = [];

  for (const section of parseSections(normalized)) {
    const prefix = section.heading ? `${section.heading}\n\n` : "";
    const bodyLimit = Math.max(100, maxLength - prefix.length);
    let current = "";

    const flush = () => {
      if (!current) return;
      chunks.push(`${prefix}${current}`.trim());
      current = "";
    };

    for (const paragraph of section.paragraphs) {
      if (paragraph.length > bodyLimit) {
        flush();
        for (const part of splitLongText(paragraph, bodyLimit, overlap)) {
          chunks.push(`${prefix}${part}`.trim());
        }
        continue;
      }

      const next = current ? `${current}\n\n${paragraph}` : paragraph;
      if (next.length > bodyLimit) flush();
      current = current ? `${current}\n\n${paragraph}` : paragraph;
    }

    flush();
  }

  return chunks.map((content, index) => ({ index, content }));
}
