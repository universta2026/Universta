import type { Metadata } from "next";
import { notFound } from "next/navigation";
import StudyAbroadContinentView from "@/components/StudyAbroadContinentView";
import StudyAbroadCountryView from "@/components/StudyAbroadCountryView";
import { getCountries, getCountrySections, getStudyAbroadContent, getSubjects, text } from "@/lib/api";
import { findContinent, groupByContinent } from "@/lib/continents";
import { fill } from "@/lib/eligibility";

// /study-abroad/<slug> is either a continent (/study-abroad/europe) or a country (/study-abroad/germany).
// Both live under the same dynamic segment because Next.js allows only one per level.
// Continents are checked first; if a continent and a country ever shared a slug, the continent wins.
async function resolve(slug: string) {
  const countries = await getCountries();
  const continents = groupByContinent(countries);
  const continent = findContinent(continents, slug);
  if (continent) return { kind: "continent" as const, continent, continents, countries };
  const country = countries.find((c) => c.slug === slug);
  return country ? { kind: "country" as const, country, countries } : null;
}

export async function studyAbroadMetadata(slug: string): Promise<Metadata> {
  const d = await resolve(slug);
  if (!d) return { title: "Page not found | Universta" };
  const content = await getStudyAbroadContent(slug);
  const name = d.kind === "continent" ? d.continent.name : d.country.name;
  const fallback = d.kind === "continent" ? "Study in {continent} | Universta" : "Study in {country} | Universta";
  return { title: fill(text(content, "meta", "title", fallback), { continent: name, country: name }) };
}

export default async function StudyAbroadView({ slug }: { slug: string }) {
  const d = await resolve(slug);
  if (!d) notFound();
  const [content, subjects] = await Promise.all([getStudyAbroadContent(slug), getSubjects().catch(() => [])]);

  if (d.kind === "continent") {
    return <StudyAbroadContinentView continent={d.continent} allContinents={d.continents} subjects={subjects} content={content} />;
  }
  const sections = await getCountrySections(d.country.slug);
  return <StudyAbroadCountryView country={d.country} countries={d.countries} subjects={subjects} sections={sections} content={content} />;
}
