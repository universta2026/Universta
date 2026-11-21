import Link from "next/link";
import { ArrowRight, Award, FileCheck, Globe, MessageCircle, Plane } from "lucide-react";
import PopularCountries from "@/components/PopularCountries";
import RichText from "@/components/RichText";
import SaveButton from "@/components/SaveButton";
import SubNav from "@/components/SubNav";
import { AsideLead, DetailHero, DetailLayout, Faq, NextStepsBand, Section, withHighlight } from "@/components/ui";
import type { Country, CountrySections, PageSections, SectionItem, Subject } from "@/lib/api";
import { text } from "@/lib/api";
import { continentSlug, groupByContinent } from "@/lib/continents";
import { fill } from "@/lib/eligibility";
import { plainText } from "@/lib/plain-text";

// The page blocks requested by the owner, in page order. `id` is the anchor and the page_content
// section_key; `field` is the key in the /countries/{slug}/sections response (country_sections rows).
// Only the order and the keys are in code: titles, tab names and all items come from page_content / Directus.
const BLOCKS: { id: keyof CountrySections; title: string; nav: string }[] = [
  { id: "why", title: "Why study in {country}", nav: "Why study" },
  { id: "subjects", title: "Top subjects to study in {country}", nav: "Subjects" },
  { id: "courses", title: "Top courses to study in {country}", nav: "Courses" },
  { id: "universities", title: "Top universities to study in {country}", nav: "Universities" },
  { id: "exams", title: "Exam requirements to study in {country}", nav: "Exams" },
  { id: "scholarships", title: "Scholarships to study in {country}", nav: "Scholarships" },
  { id: "visa", title: "Student visa requirements for {country}", nav: "Visa" },
  { id: "applications", title: "Application requirements to study in {country}", nav: "Application" },
  { id: "intakes", title: "Intakes in {country}", nav: "Intakes" },
  { id: "costs", title: "Cost of studying in {country}", nav: "Cost" },
  { id: "eligibility", title: "Eligibility criteria to study in {country}", nav: "Eligibility" },
];

// One block. A single item with text is shown as plain text (visa rules, eligibility...);
// several items, or items without text, are shown as cards (universities, courses, scholarships...).
function Items({ items, sponsored, from }: { items: SectionItem[]; sponsored: string; from: string }) {
  // Internal links (subject and specialization pages) carry ?from=<country> so the target page can say "in <country>".
  const withFrom = (url: string) => (url.includes("?") ? url : `${url}?from=${encodeURIComponent(from)}`);
  if (items.length === 1 && items[0].body) {
    return <RichText html={items[0].body} />;
  }
  return (
    <div className="grid g-2">
      {items.map((it) => (
        <div className="card" key={it.id}>
          {it.is_sponsored && <span className="tag tag-cloud">{sponsored}</span>}
          <h3 className="card-title">
            {it.url ? (
              it.url.startsWith("http") ? (
                <a className="stretched" href={it.url} target="_blank" rel="noopener noreferrer sponsored" style={{ color: "inherit" }}>
                  {it.title}
                </a>
              ) : (
                <Link className="stretched" href={withFrom(it.url)} style={{ color: "inherit" }}>
                  {it.title}
                </Link>
              )
            ) : (
              it.title
            )}
          </h3>
          {it.subtitle && <p className="caption">{it.subtitle}</p>}
          {it.body && (
            <div className="mt-4">
              <RichText html={it.body} />
            </div>
          )}
        </div>
      ))}
    </div>
  );
}

// /studyabroad/germany
// Everything shown comes from the API: the country row (name, code, description), its country_sections
// rows, and page_content rows (page_key "study-abroad" for defaults, "study-abroad:germany" for this country).
// A block with no rows is not rendered.
export default function StudyAbroadCountryView({
  country,
  countries,
  subjects,
  sections,
  content,
}: {
  country: Country;
  countries: Country[];
  subjects: Subject[];
  sections: Partial<CountrySections>;
  content: PageSections;
}) {
  const continent = groupByContinent(countries).find((g) => g.countries.some((c) => c.slug === country.slug));
  const v = { country: country.name, continent: continent?.name ?? "" };
  const t = (section: string, key: string, fallback: string) => fill(text(content, section, key, fallback), v);

  const lead = t("hero", "intro", "") || plainText(country.description);
  const blocks = BLOCKS.filter((b) => (sections[b.id]?.length ?? 0) > 0);

  const nearby = (continent?.countries ?? []).filter((c) => c.slug !== country.slug);
  const faq = [1, 2, 3, 4, 5, 6]
    .map((n) => ({ q: t("faq", `q${n}`, ""), a: t("faq", `a${n}`, "") }))
    .filter((f) => f.q && f.a);

  const nav = [
    ...blocks.map((b) => ({ id: b.id, label: t("nav", b.id, b.nav) })),
    ...(nearby.length > 0 ? [{ id: "nearby", label: t("nav", "nearby", "Nearby countries") }] : []),
    ...(faq.length > 0 ? [{ id: "faq", label: t("nav", "faq", "FAQ") }] : []),
  ];

  return (
    <main>
      <DetailHero
        crumbs={[
          { label: t("crumbs", "home", "Home"), href: "/" },
          { label: t("crumbs", "study_abroad", "Study abroad"), href: "/studyabroad" },
          ...(continent ? [{ label: continent.name, href: `/studyabroad/${continentSlug(continent.name)}` }] : []),
          { label: country.name },
        ]}
        tile={
          <span className="ico-tile">
            <Globe className="ico" aria-hidden />
          </span>
        }
        title={withHighlight(fill(text(content, "hero", "title", "Study in {country}"), { ...v, country: `{${country.name}}` }))}
        lead={lead || undefined}
        actions={
          <>
            <SaveButton />
            <a className="btn btn-dark" href="#advice">
              {t("hero", "cta", "Talk to an expert")}
            </a>
          </>
        }
      />
      {nav.length > 0 && <SubNav items={nav} />}

      <DetailLayout
        main={
          <>
            {blocks.map((b) => (
              <Section key={b.id} id={b.id} title={t(b.id, "title", b.title)} intro={t(b.id, "intro", "")}>
                <Items items={sections[b.id] ?? []} sponsored={t("labels", "sponsored", "Sponsored")} from={country.slug} />
              </Section>
            ))}

            {nearby.length > 0 && continent && (
              <Section id="nearby" title={t("nearby", "title", "More countries in {continent}")} intro={t("nearby", "intro", "")}>
                <PopularCountries countries={nearby.map((c) => ({ name: c.name, slug: c.slug, code: c.country_code, href: `/studyabroad/${c.slug}` }))} />
                <Link className="link-arrow mt-6" href={`/studyabroad/${continentSlug(continent.name)}`}>
                  {t("nearby", "link", "View all in {continent}")}
                  <ArrowRight className="ico" aria-hidden />
                </Link>
              </Section>
            )}

            {faq.length > 0 && (
              <Section id="faq" title={t("faq", "title", "Studying in {country}")}>
                <Faq items={faq} />
              </Section>
            )}
          </>
        }
        aside={<AsideLead about={country.name} lead={{ subjects: subjects.map((s) => ({ name: s.name, specializations: s.specializations.map((x) => x.name) })) }} />}
      />

      <NextStepsBand
        title={t("next_steps", "title", "Your next step")}
        items={[
          { icon: Award, title: t("next_steps", "scholarships_title", "Scholarships"), desc: t("next_steps", "scholarships_desc", "Funding for {country}"), key: "scholarships" },
          { icon: FileCheck, title: t("next_steps", "exams_title", "Pick your test"), desc: t("next_steps", "exams_desc", "IELTS, TOEFL, PTE, GRE"), key: "exams" },
          { icon: Plane, title: t("next_steps", "visa_title", "Student visa"), desc: t("next_steps", "visa_desc", "Step-by-step guides"), key: "student-visa" },
          { icon: MessageCircle, title: t("next_steps", "consultants_title", "Find a consultant"), desc: t("next_steps", "consultants_desc", "Verified, reviewed advisers"), key: "consultants" },
        ]}
      />
    </main>
  );
}
