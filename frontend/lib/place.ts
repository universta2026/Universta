import { getCountries } from "@/lib/api";

// Links on a country page add ?from=<country-slug>. Subject, specialization and level pages read it so
// their text says "in <country>" instead of "abroad", and they pass it on to their own links.
export type SearchParams = Promise<{ from?: string | string[] }>;
export type Place = { slug: string; name: string };

// Only a slug that matches a real country is accepted; anything else gives null (text stays "abroad").
export async function getPlace(searchParams: SearchParams): Promise<Place | null> {
  const raw = (await searchParams).from;
  const slug = Array.isArray(raw) ? raw[0] : raw;
  if (!slug) return null;
  const country = (await getCountries()).find((c) => c.slug === slug);
  return country ? { slug: country.slug, name: country.name } : null;
}

// "/subjects/x" -> "/subjects/x?from=india" (unchanged when there is no country)
export const withFrom = (href: string, from?: string | null) =>
  from && !href.includes("?") ? `${href}?from=${encodeURIComponent(from)}` : href;
