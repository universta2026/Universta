import type { Metadata } from "next";
import ContinentCards from "@/components/ContinentCards";
import PopularCountries from "@/components/PopularCountries";
import { Crumbs, CtaBand, Note, SecHead, withHighlight } from "@/components/ui";
import { getCountries, getStudyAbroadContent, getSubjects, text } from "@/lib/api";
import { continentSlug, groupByContinent } from "@/lib/continents";

export async function generateMetadata(): Promise<Metadata> {
  const content = await getStudyAbroadContent();
  return { title: text(content, "meta", "index_title", "Study abroad | Universta") };
}

// /studyabroad : pick a continent or a country. Countries come from the countries table,
// text from page_content (page_key = "study-abroad", section "index").
export default async function StudyAbroadIndexPage() {
  const [countries, subjects, content] = await Promise.all([getCountries(), getSubjects().catch(() => []), getStudyAbroadContent()]);

  const continents = groupByContinent(countries).map((g) => ({
    name: g.name,
    href: `/studyabroad/${continentSlug(g.name)}`,
    linkLabel: text(content, "index", "continent_link", "View all in {continent}"),
    countries: g.countries.map((c) => ({ name: c.name, slug: c.slug, code: c.country_code, href: `/studyabroad/${c.slug}` })),
  }));
  const popular = countries.filter((c) => c.is_popular).map((c) => ({ name: c.name, slug: c.slug, code: c.country_code, href: `/studyabroad/${c.slug}` }));

  return (
    <main>
      <section className="page-hero">
        <div className="shell">
          <Crumbs items={[{ label: text(content, "crumbs", "home", "Home"), href: "/" }, { label: text(content, "crumbs", "study_abroad", "Study abroad") }]} />
          <h1 className="t-h1 mt-6">{withHighlight(text(content, "index", "title", "Where do you want to {study}?"))}</h1>
          <p className="lead">{text(content, "index", "intro", "Choose a continent or a country to see what it offers international students.")}</p>
        </div>
      </section>

      {popular.length > 0 && (
        <section className="section">
          <div className="shell">
            <SecHead
              eyebrow={text(content, "index", "popular_eyebrow", "Popular")}
              title={text(content, "index", "popular_title", "Popular study destinations")}
              intro={text(content, "index", "popular_intro", "") || undefined}
            />
            <PopularCountries countries={popular} />
          </div>
        </section>
      )}

      <section className="section">
        <div className="shell">
          <SecHead
            eyebrow={text(content, "index", "continents_eyebrow", "Browse")}
            title={text(content, "index", "continents_title", "Browse by continent")}
            intro={text(content, "index", "continents_intro", "") || undefined}
          />
          {continents.length === 0 ? (
            <Note>{text(content, "index", "empty_message", "No destinations are listed yet.")}</Note>
          ) : (
            <ContinentCards continents={continents} panelTitle={text(content, "index", "panel_title", "Study in {continent}")} />
          )}
        </div>
      </section>

      <CtaBand
        title={withHighlight(text(content, "index", "cta_title", "Not sure where to go? {Ask an expert.}"))}
        text={text(content, "index", "cta_text", "Tell us your field and your budget. We’ll suggest where to apply.")}
        lead={{ subjects: subjects.map((s) => ({ name: s.name, specializations: s.specializations.map((x) => x.name) })) }}
      />
    </main>
  );
}
