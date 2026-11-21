import Link from "next/link";
import { ArrowRight, Award, FileCheck, Globe, GraduationCap, Landmark, MessageCircle, Plane } from "lucide-react";
import { ContinentTile } from "@/components/PlaceTile";
import Ph from "@/components/Ph";
import PopularCountries from "@/components/PopularCountries";
import RichText from "@/components/RichText";
import SaveButton from "@/components/SaveButton";
import { LeadBand, DetailHero, DetailLayout, Faq, NextStepsBand, Section, withHighlight } from "@/components/ui";
import type { Country, PageSections, Subject } from "@/lib/api";
import { text } from "@/lib/api";
import { continentSlug, type ContinentGroup } from "@/lib/continents";
import { fill } from "@/lib/eligibility";

// /study-abroad/europe
// Countries come from the countries table (grouped by ISO code in lib/continents.ts); all text comes from
// page_content: page_key "study-abroad" for defaults, "study-abroad:europe" for this continent.
export default function StudyAbroadContinentView({
  continent,
  allContinents,
  subjects,
  content,
}: {
  continent: ContinentGroup<Country>;
  allContinents: ContinentGroup<Country>[];
  subjects: Subject[];
  content: PageSections;
}) {
  // {country} is also set to the continent name: the shared default texts (page_key "study-abroad") are written for country pages.
  const v = { continent: continent.name, country: continent.name, count: String(continent.countries.length) };
  const t = (section: string, key: string, fallback: string) => fill(text(content, section, key, fallback), v);

  const overviewHtml = text(content, "overview", "body", "");
  const others = allContinents.filter((c) => c.name !== continent.name);
  const faq = [1, 2, 3, 4, 5, 6]
    .map((n) => ({ q: t("faq", `q${n}`, ""), a: t("faq", `a${n}`, "") }))
    .filter((f) => f.q && f.a);

  return (
    <main>
      <DetailHero
        crumbs={[
          { label: t("crumbs", "home", "Home"), href: "/" },
          { label: t("crumbs", "study_abroad", "Study abroad"), href: "/study-abroad" },
          { label: continent.name },
        ]}
        tile={<ContinentTile name={continent.name} />}
        title={withHighlight(fill(text(content, "hero", "title", "Study in {continent}"), { ...v, continent: `{${continent.name}}`, country: `{${continent.name}}` }))}
        lead={t("hero", "intro", "") || undefined}
        actions={
          <>
            <SaveButton />
            <a className="btn btn-dark" href="#advice">
              {t("hero", "cta", "Talk to an expert")}
            </a>
          </>
        }
        facts={[
          { icon: Globe, label: t("facts", "countries_label", "Countries"), value: String(continent.countries.length) },
          { icon: Landmark, label: t("facts", "universities_label", "Universities"), value: <Ph>NUMBER</Ph> },
          { icon: GraduationCap, label: t("facts", "courses_label", "Courses"), value: <Ph>NUMBER</Ph> },
          { icon: Award, label: t("facts", "scholarships_label", "Scholarships"), value: <Ph>NUMBER</Ph> },
        ]}
      />

      <DetailLayout
        main={
          <>
            <Section id="countries" title={t("countries", "title", "Countries in {continent}")} intro={t("countries", "intro", "")}>
              <PopularCountries countries={continent.countries.map((c) => ({ name: c.name, slug: c.slug, code: c.country_code, href: `/study-abroad/${c.slug}` }))} />
            </Section>

            {overviewHtml && (
              <Section id="overview" title={t("overview", "title", "Why study in {continent}")}>
                <RichText html={overviewHtml} />
              </Section>
            )}

            {others.length > 0 && (
              <Section id="others" title={t("others", "title", "Explore other continents")} intro={t("others", "intro", "")}>
                <div className="grid g-4">
                  {others.map((c) => (
                    <Link className="card" href={`/study-abroad/${continentSlug(c.name)}`} key={c.name}>
                      <h3 className="card-title">{c.name}</h3>
                      <span className="caption" style={{ display: "block", marginTop: 4 }}>
                        {c.countries.length} {c.countries.length === 1 ? t("others", "country_one", "country") : t("others", "country_many", "countries")}
                      </span>
                      <span className="link-arrow" style={{ marginTop: 20 }}>
                        {t("others", "link", "Explore")}
                        <ArrowRight className="ico" aria-hidden />
                      </span>
                    </Link>
                  ))}
                </div>
              </Section>
            )}

            {faq.length > 0 && (
              <Section id="faq" title={t("faq", "title", "Studying in {continent}")}>
                <Faq items={faq} />
              </Section>
            )}
          </>
        }
      />

      <NextStepsBand
        title={t("next_steps", "title", "Your next step")}
        items={[
          { icon: Award, title: t("next_steps", "scholarships_title", "Scholarships"), desc: t("next_steps", "scholarships_desc", "Funding for {continent}"), key: "scholarships" },
          { icon: FileCheck, title: t("next_steps", "exams_title", "Pick your test"), desc: t("next_steps", "exams_desc", "IELTS, TOEFL, PTE, GRE"), key: "exams" },
          { icon: Plane, title: t("next_steps", "visa_title", "Student visa"), desc: t("next_steps", "visa_desc", "Step-by-step guides"), key: "student-visa" },
          { icon: MessageCircle, title: t("next_steps", "consultants_title", "Find a consultant"), desc: t("next_steps", "consultants_desc", "Verified, reviewed advisers"), key: "consultants" },
        ]}
      />
      <LeadBand about={continent.name} lead={{ subjects: subjects.map((s) => ({ name: s.name, specializations: s.specializations.map((x) => x.name) })) }} />
    </main>
  );
}
