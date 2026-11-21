import type { Metadata } from "next";
import ContinentCards from "@/components/ContinentCards";
import PopularCountries from "@/components/PopularCountries";
import { Award, Globe, GraduationCap, Landmark } from "lucide-react";
import Ph from "@/components/Ph";
import { WorldTile } from "@/components/PlaceTile";
import SaveButton from "@/components/SaveButton";
import { DetailHero, LeadBand, Note, SecHead, withHighlight } from "@/components/ui";
import { getCountries, getStudyAbroadContent, getSubjects, text } from "@/lib/api";
import { continentSlug, groupByContinent, popularCountries } from "@/lib/continents";

export async function generateMetadata(): Promise<Metadata> {
  const content = await getStudyAbroadContent();
  return { title: text(content, "meta", "index_title", "Study abroad | Universta") };
}

// /study-abroad : pick a continent or a country. Countries come from the countries table,
// text from page_content (page_key = "study-abroad", section "index").
export default async function StudyAbroadIndexPage() {
  const [countries, subjects, content] = await Promise.all([getCountries(), getSubjects().catch(() => []), getStudyAbroadContent()]);

  const continents = groupByContinent(countries).map((g) => ({
    name: g.name,
    href: `/study-abroad/${continentSlug(g.name)}`,
    linkLabel: text(content, "index", "continent_link", "View all in {continent}"),
    countries: g.countries.map((c) => ({ name: c.name, slug: c.slug, code: c.country_code, href: `/study-abroad/${c.slug}` })),
  }));
  const popular = popularCountries(countries, 8).map((c) => ({ name: c.name, slug: c.slug, code: c.country_code, href: `/study-abroad/${c.slug}` }));

  return (
    <main>
      <DetailHero
        crumbs={[{ label: text(content, "crumbs", "home", "Home"), href: "/" }, { label: text(content, "crumbs", "study_abroad", "Study abroad") }]}
        tile={<WorldTile />}
        title={withHighlight(text(content, "index", "title", "Where do you want to {study}?"))}
        lead={text(content, "index", "intro", "Choose a continent or a country to see what it offers international students.")}
        actions={
          <>
            <SaveButton />
            <a className="btn btn-dark" href="#advice">
              {text(content, "hero", "cta", "Talk to an expert")}
            </a>
          </>
        }
        facts={[
          { icon: Globe, label: text(content, "facts", "countries_label", "Countries"), value: countries.length > 0 ? String(countries.length) : <Ph>NUMBER</Ph> },
          { icon: Landmark, label: text(content, "facts", "universities_label", "Universities"), value: <Ph>NUMBER</Ph> },
          { icon: GraduationCap, label: text(content, "facts", "courses_label", "Courses"), value: <Ph>NUMBER</Ph> },
          { icon: Award, label: text(content, "facts", "scholarships_label", "Scholarships"), value: <Ph>NUMBER</Ph> },
        ]}
      />

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

      <LeadBand about="studying" lead={{ subjects: subjects.map((s) => ({ name: s.name, specializations: s.specializations.map((x) => x.name) })) }} />
    </main>
  );
}
