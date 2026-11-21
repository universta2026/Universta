import type { ReactNode } from "react";
import Link from "next/link";
import { ArrowRight, Award, FileCheck, Globe, GraduationCap, Landmark, MessageCircle, Plane } from "lucide-react";
import { CountryTile } from "@/components/PlaceTile";
import { AdSlot, BandSection, CtaStrip } from "@/components/CountryBlocks";
import Ph from "@/components/Ph";
import PopularCountries from "@/components/PopularCountries";
import RichText from "@/components/RichText";
import SaveButton from "@/components/SaveButton";
import SubNav from "@/components/SubNav";
import { Band, LeadBand, DetailHero, Faq, NextStepsBand, withHighlight } from "@/components/ui";
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
    return (
      <div className="rich-panel">
        <RichText html={items[0].body} />
      </div>
    );
  }
  return (
    <div className="grid g-3">
      {items.map((it, i) => (
        <div className={`card info-card${it.url ? " is-link" : ""}`} key={it.id}>
          <span className="info-no">{String(i + 1).padStart(2, "0")}</span>
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

// /study-abroad/germany
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

  // One entry per full-width band. Call-to-action strips and ads are slotted in between by position.
  const bands: { key: string; node: ReactNode }[] = [
    ...blocks.map((b) => ({
      key: b.id,
      node: (
        <BandSection id={b.id} title={t(b.id, "title", b.title)} intro={t(b.id, "intro", "")}>
          <Items items={sections[b.id] ?? []} sponsored={t("labels", "sponsored", "Sponsored")} from={country.slug} />
        </BandSection>
      ),
    })),
    ...(nearby.length > 0 && continent
      ? [
          {
            key: "nearby",
            node: (
              <BandSection id="nearby" title={t("nearby", "title", "More countries in {continent}")} intro={t("nearby", "intro", "")}>
                <PopularCountries countries={nearby.map((c) => ({ name: c.name, slug: c.slug, code: c.country_code, href: `/study-abroad/${c.slug}` }))} />
                <Link className="link-arrow mt-6" href={`/study-abroad/${continentSlug(continent.name)}`}>
                  {t("nearby", "link", "View all in {continent}")}
                  <ArrowRight className="ico" aria-hidden />
                </Link>
              </BandSection>
            ),
          },
        ]
      : []),
    ...(faq.length > 0
      ? [
          {
            key: "faq",
            node: (
              <BandSection id="faq" title={t("faq", "title", "Studying in {country}")}>
                <Faq items={faq} />
              </BandSection>
            ),
          },
        ]
      : []),
  ];

  const extras = (i: number): ReactNode => {
    if (i === 1)
      return (
        <CtaStrip
          title={t("cta", "shortlist_title", `Get your personal ${country.name} shortlist`)}
          text={t("cta", "shortlist_text", "Tell us your field and budget. We match you with universities, scholarships and intakes that fit.")}
          primary={t("cta", "shortlist_button", "Talk to an expert")}
          secondary={t("cta", "shortlist_secondary", "Get a free shortlist")}
        />
      );
    if (i === 2) return <AdSlot size="wide" />;
    if (i === 4)
      return (
        <CtaStrip
          title={t("cta", "apply_title", `Ready to apply to ${country.name}?`)}
          text={t("cta", "apply_text", "An adviser can check your eligibility, documents and deadlines, free of charge.")}
          primary={t("cta", "apply_button", "Start my application")}
        />
      );
    if (i === 5) return <AdSlot />;
    return null;
  };

  return (
    <main>
      <DetailHero
        crumbs={[
          { label: t("crumbs", "home", "Home"), href: "/" },
          { label: t("crumbs", "study_abroad", "Study abroad"), href: "/study-abroad" },
          ...(continent ? [{ label: continent.name, href: `/study-abroad/${continentSlug(continent.name)}` }] : []),
          { label: country.name },
        ]}
        tile={<CountryTile code={country.country_code} />}
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
        facts={[
          {
            icon: Globe,
            label: t("facts", "continent_label", "Continent"),
            value: continent ? (
              <Link className="fact-link" href={`/study-abroad/${continentSlug(continent.name)}`}>
                {continent.name}
              </Link>
            ) : (
              "-"
            ),
          },
          { icon: Landmark, label: t("facts", "universities_label", "Universities"), value: <Ph>NUMBER</Ph> },
          { icon: GraduationCap, label: t("facts", "courses_label", "Courses"), value: <Ph>NUMBER</Ph> },
          { icon: Award, label: t("facts", "scholarships_label", "Scholarships"), value: <Ph>NUMBER</Ph> },
        ]}
      />
      {nav.length > 0 && <SubNav items={nav} />}

      <div className="bands">
        {bands.map((b, i) => (
          <Band key={b.key}>
            {b.node}
            {extras(i)}
          </Band>
        ))}
      </div>

      <NextStepsBand
        title={t("next_steps", "title", "Your next step")}
        items={[
          { icon: Award, title: t("next_steps", "scholarships_title", "Scholarships"), desc: t("next_steps", "scholarships_desc", "Funding for {country}"), key: "scholarships" },
          { icon: FileCheck, title: t("next_steps", "exams_title", "Pick your test"), desc: t("next_steps", "exams_desc", "IELTS, TOEFL, PTE, GRE"), key: "exams" },
          { icon: Plane, title: t("next_steps", "visa_title", "Student visa"), desc: t("next_steps", "visa_desc", "Step-by-step guides"), key: "student-visa" },
          { icon: MessageCircle, title: t("next_steps", "consultants_title", "Find a consultant"), desc: t("next_steps", "consultants_desc", "Verified, reviewed advisers"), key: "consultants" },
        ]}
      />
      <LeadBand about={country.name} lead={{ subjects: subjects.map((s) => ({ name: s.name, specializations: s.specializations.map((x) => x.name) })) }} />
    </main>
  );
}
