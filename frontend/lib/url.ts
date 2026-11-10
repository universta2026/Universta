// Links that come from the CMS (subject_sections.url) are checked here before they reach an <a>.
// The API already filters them; this is the second layer of defence.
// Allowed: https://, mailto:, tel:, paths starting with "/" (not "//") and "#anchors".
export function safeHref(url: string | null | undefined): string | null {
  if (!url) return null;
  const value = url.trim();
  if (value.startsWith("#")) return value;
  if (value.startsWith("/") && !value.startsWith("//")) return value;
  if (/^(https:\/\/|mailto:|tel:)/i.test(value)) return value;
  return null;
}
