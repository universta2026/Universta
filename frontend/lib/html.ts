// Turns rich text (HTML from Directus) into plain text, for cards, previews and search.
const ENTITIES: Record<string, string> = {
  "&nbsp;": " ",
  "&amp;": "&",
  "&lt;": "<",
  "&gt;": ">",
  "&quot;": '"',
  "&apos;": "'",
  "&#39;": "'",
};

export function stripHtml(html: string | null | undefined): string {
  if (!html) return "";
  return html
    .replace(/<(script|style)[^>]*>[\s\S]*?<\/\1>/gi, "") // drop code blocks entirely
    .replace(/<\/(p|div|li|h[1-6]|blockquote)>/gi, " ")
    .replace(/<br\s*\/?>/gi, " ")
    .replace(/<[^>]*>/g, "")
    .replace(/&(nbsp|amp|lt|gt|quot|apos|#39);/g, (m) => ENTITIES[m] ?? m)
    .replace(/\s+/g, " ")
    .trim();
}
