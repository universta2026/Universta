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

export type SubjectDetail = Omit<Subject, "specializations"> & {
  specializations: Specialization[];
  study_levels: StudyLevel[];
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
