// Helpers for the international-student pages. No content lives here:
// countries, destination rules and all page text come from the API (Directus-editable).

export const HOME_STORAGE_KEY = "universta.home-country";

/** /subjects/engineering/international-student  or  /subjects/engineering/international-students/india[?spec=..&level=..] */
export function internationalHref(p: { subject: string; from?: string; spec?: string; level?: string }) {
  if (!p.from) return `/subjects/${p.subject}/international-student`;
  const q = new URLSearchParams();
  if (p.spec) q.set("spec", p.spec);
  if (p.level) q.set("level", p.level);
  const s = q.toString();
  return `/subjects/${p.subject}/international-students/${p.from}${s ? `?${s}` : ""}`;
}

/** Replaces {subject}, {country}... in an editable text. Unknown placeholders are left alone
 *  (so a {highlighted word} in a title still works). */
export function fill(template: string, values: Record<string, string>) {
  return template.replace(/\{(\w+)\}/g, (m, k: string) => (k in values ? values[k] : m));
}
