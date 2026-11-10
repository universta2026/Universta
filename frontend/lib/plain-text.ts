// CMS description fields can contain rich-text HTML (<p>, <strong> ...).
// Use this wherever a description is shown as plain text so tags never appear on the page.
// Dependency-free so it also works in client components.
export function plainText(html: string | null | undefined): string {
  if (!html) return "";
  return html
    .replace(/<\s*(br|\/p|\/li|\/div|\/h[1-6])\s*\/?>/gi, " ")
    .replace(/<[^>]*>/g, "")
    .replace(/&nbsp;/g, " ")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&amp;/g, "&")
    .replace(/\s+/g, " ")
    .trim();
}
