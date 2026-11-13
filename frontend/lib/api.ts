// All calls to FastAPI live here. Pages and components never use fetch directly.
const API_URL = process.env.API_URL ?? "http://127.0.0.1:8000/api";

export type Specialization = {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  is_featured: boolean;
};

export type Subject = {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  icon_key: string | null;
  specializations: Specialization[];
};

// { section_key: { content_key: value } }, built from the page_content table
export type PageSections = Record<string, Record<string, unknown>>;

async function get(path: string) {
  // revalidate: 30 -> changes published in Directus appear within ~30 seconds
  return fetch(`${API_URL}${path}`, { next: { revalidate: 30 } });
}

export async function getSubjects(): Promise<Subject[]> {
  const res = await get("/subjects");
  if (!res.ok) throw new Error(`GET /subjects failed with status ${res.status}`);
  return res.json();
}

export async function getPageContent(pageKey: string): Promise<PageSections> {
  const res = await get(`/pages/${pageKey}`);
  if (res.status === 404) return {}; // no rows yet: the page falls back to default text
  if (!res.ok) throw new Error(`GET /pages/${pageKey} failed with status ${res.status}`);
  const data = await res.json();
  return data.sections as PageSections;
}

// Read one text value from page content, or use the fallback if it is missing.
export function text(
  sections: PageSections,
  section: string,
  key: string,
  fallback: string,
): string {
  const value = sections[section]?.[key];
  return typeof value === "string" && value.trim() !== "" ? value : fallback;
}

// ---------- Detail pages ----------

export type StudyLevel = {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  duration: string | null;
};

// One item of the extra content on the subject page (rows of subject_sections in Directus).
// `body` is rich text HTML: render it with <RichText>, never as plain text.
export type SectionItem = {
  id: string;
  title: string;
  subtitle: string | null;
  body: string | null;
  url: string | null;
  is_sponsored: boolean;
};

export type SubjectDetail = Omit<Subject, "specializations"> & {
  specializations: Specialization[];
  study_levels: StudyLevel[];
  // Optional in the type so the page still works if the API is an older version.
  about?: SectionItem | null;
  why?: SectionItem | null;
  advertisement?: SectionItem | null;
  cta?: SectionItem | null;
  industries?: SectionItem[];
  companies?: SectionItem[];
  courses?: SectionItem[];
  destinations?: SectionItem[];
  universities?: SectionItem[];
};

// Extra content of one Subject + Study Level page (/subjects/engineering/bachelors).
export type LevelPageSections = {
  about?: SectionItem | null;
  why?: SectionItem | null;
  industries?: SectionItem[];
  companies?: SectionItem[];
  advertisement?: SectionItem | null;
  cta?: SectionItem | null;
  courses?: SectionItem[];
  destinations?: SectionItem[];
  universities?: SectionItem[];
};

export type SpecializationDetail = Specialization & {
  subject_name: string;
  subject_slug: string;
};

// Returns null when the API says 404 (unknown or unpublished), so the page can show "not found".
export async function getSubject(slug: string): Promise<SubjectDetail | null> {
  const res = await get(`/subjects/${encodeURIComponent(slug)}`);
  if (res.status === 404) return null;
  if (!res.ok) throw new Error(`GET /subjects/${slug} failed with status ${res.status}`);
  return res.json();
}

export async function getSpecialization(slug: string): Promise<SpecializationDetail | null> {
  const res = await get(`/specializations/${encodeURIComponent(slug)}`);
  if (res.status === 404) return null;
  if (!res.ok) throw new Error(`GET /specializations/${slug} failed with status ${res.status}`);
  return res.json();
}

// Never throws: if the API is down or older, the level page still shows its default content.
export async function getLevelSections(subjectSlug: string, levelSlug: string): Promise<LevelPageSections> {
  try {
    const res = await get(`/subjects/${encodeURIComponent(subjectSlug)}/levels/${encodeURIComponent(levelSlug)}`);
    if (!res.ok) return {};
    return await res.json();
  } catch {
    return {};
  }
}

// Extra content of one Specialization page (/subjects/engineering/civil-engineering). Never throws.
export async function getSpecializationSections(subjectSlug: string, specSlug: string): Promise<LevelPageSections> {
  try {
    const res = await get(
      `/subjects/${encodeURIComponent(subjectSlug)}/specializations/${encodeURIComponent(specSlug)}/sections`,
    );
    if (!res.ok) return {};
    return await res.json();
  } catch {
    return {};
  }
}

// Extra content of one Specialization + Study Level page
// (/subjects/engineering/civil-engineering/bachelors). Never throws.
export async function getSpecializationLevelSections(
  subjectSlug: string,
  specSlug: string,
  levelSlug: string,
): Promise<LevelPageSections> {
  try {
    const res = await get(
      `/subjects/${encodeURIComponent(subjectSlug)}/specializations/${encodeURIComponent(specSlug)}/levels/${encodeURIComponent(levelSlug)}/sections`,
    );
    if (!res.ok) return {};
    return await res.json();
  } catch {
    return {};
  }
}

// ---------- Countries (home country + destinations on the international-student pages) ----------

export type Country = {
  id: string;
  name: string;
  slug: string;
  country_code: string | null;
  description: string | null;
  // Backend column on the countries table. Optional so the frontend works before it is merged:
  // missing or false = not popular. Rename here if the backend names it differently.
  is_popular?: boolean;
};

// Never throws: if the API is down the page shows its empty state.
export async function getCountries(): Promise<Country[]> {
  try {
    const res = await get("/countries");
    if (!res.ok) return [];
    return await res.json();
  } catch {
    return [];
  }
}
