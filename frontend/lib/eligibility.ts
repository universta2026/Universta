// Helpers for the international-student pages. No content lives here:
// countries, destination rules and all page text come from the API (Directus-editable).

export const HOME_STORAGE_KEY = "universta.home-country";

/** subject[/spec][/level]/international-student[/country], e.g.
 *  /subjects/engineering/civil-engineering/bachelors/international-student/india */
export function internationalHref(p: { subject: string; from?: string; spec?: string; level?: string }) {
  // Without a country the visitor still has to pick one, on the matching "pick your country" page.
  // The specialization / level stays in the URL so it is not lost after the country is chosen.
  const path = [p.subject, p.spec, p.level].filter(Boolean).join("/");
  return p.from ? `/subjects/${path}/international-student/${p.from}` : `/subjects/${path}/international-student`;
}

/** Replaces {subject}, {country}... in an editable text. Unknown placeholders are left alone
 *  (so a {highlighted word} in a title still works). */
export function fill(template: string, values: Record<string, string>) {
  return template.replace(/\{(\w+)\}/g, (m, k: string) => (k in values ? values[k] : m));
}
