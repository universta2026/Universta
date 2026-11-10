// Study-level helpers (display names, ordering and the two extra levels).
// This is frontend-only logic: lib/api.ts and the backend are untouched.
import type { StudyLevel } from "@/lib/api";

export type LevelKind = "foundation" | "diploma" | "undergraduate" | "postgraduate" | "mba" | "pgdm" | "phd" | "other";

export function levelKindOf(level: { slug: string; name: string }): LevelKind {
  const s = `${level.slug} ${level.name}`.toLowerCase();
  if (/pgdm/.test(s)) return "pgdm";
  if (/\bmba\b/.test(s)) return "mba";
  if (/foundation/.test(s)) return "foundation";
  if (/bachelor|undergrad/.test(s)) return "undergraduate";
  if (/master|postgrad/.test(s)) return "postgraduate";
  if (/phd|doctor/.test(s)) return "phd";
  if (/diploma|certificate/.test(s)) return "diploma";
  return "other";
}

const RANK: Record<LevelKind, number> = {
  foundation: 0,
  diploma: 1,
  undergraduate: 2,
  postgraduate: 3,
  mba: 4,
  pgdm: 5,
  phd: 6,
  other: 7,
};

// Bachelor's -> Undergraduate, Master's -> Postgraduate (applies to names coming from the API too).
function displayName(name: string): string {
  const n = name.trim();
  if (/^bachelor/i.test(n)) return "Undergraduate";
  if (/^master/i.test(n)) return "Postgraduate";
  return name;
}

// MBA and PGDM are added to every subject. If the API already returns a level with the same
// slug (or the same kind), the API version is used and nothing is duplicated.
// Wording/durations here are placeholders: edit them in Directus later by adding real rows.
const EXTRA_LEVELS: StudyLevel[] = [
  {
    id: "extra-mba",
    name: "MBA",
    slug: "mba",
    description: "A business-focused postgraduate degree, often for people with some work experience.",
    duration: "1–2 years",
  },
  {
    id: "extra-pgdm",
    name: "PGDM",
    slug: "pgdm",
    description: "A postgraduate diploma in management — an industry-focused alternative to an MBA.",
    duration: "2 years",
  },
];

export function getLevels(levels: StudyLevel[]): StudyLevel[] {
  const all = levels.map((l) => ({ ...l, name: displayName(l.name) }));
  for (const extra of EXTRA_LEVELS) {
    if (!all.some((l) => l.slug === extra.slug || levelKindOf(l) === levelKindOf(extra))) all.push(extra);
  }
  return all
    .map((l, i) => ({ l, i }))
    .sort((a, b) => RANK[levelKindOf(a.l)] - RANK[levelKindOf(b.l)] || a.i - b.i)
    .map((x) => x.l);
}

// Level name inside a sentence: "Undergraduate" -> "undergraduate", but "MBA" and "PhD" stay as they are.
export function inlineLevel(name: string): string {
  return /^(?:[A-Z]{2,}|PhD)/.test(name) ? name : name.charAt(0).toLowerCase() + name.slice(1);
}
