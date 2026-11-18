import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { ArrowRight, BookOpen, Globe, Layers } from "lucide-react";
import ContinentCards from "@/components/ContinentCards";
import HomeCountryPicker from "@/components/HomeCountryPicker";
import PopularCountries from "@/components/PopularCountries";
import SaveButton from "@/components/SaveButton";
import SubjectIcon from "@/components/SubjectIcon";
import { AdBlock, CtaBlock } from "@/components/SubjectBlocks";
import { AsideLead, DetailHero, DetailLayout, Note, Section, withHighlight } from "@/components/ui";
import { getCountries, getPageContent, getSubject, getSubjects, text } from "@/lib/api";
import type { SectionItem } from "@/lib/api";
import { groupByContinent } from "@/lib/continents";
import { fill, internationalHref } from "@/lib/eligibility";
import { getLevels } from "@/lib/levels";

// "Pick your home country" page. One component for all four URL shapes:
//   /subjects/engineering/international-student
//   /subjects/engineering/civil-engineering/international-student      (a specialization)
//   /subjects/engineering/bachelors/international-student             (a study level)
//   /subjects/engineering/civil-engineering/bachelors/international-student
// Picking a country opens the matching ".../international-student/<country>" page for the same subject / spec / level.
export type InternationalLandingProps = {
  slug: string; // subject
  segment?: string; // a specialization OR a study level (decided by looking it up in the subject)
  level?: string; // set only with a specialization segment
};

// Subject, specialization and level are looked up in the subject's own API data. null = unknown URL (404).
async function load({ slug, segment, level: levelSlug }: InternationalLandingProps) {
  const subject = await getSubject(slug);
  if (!subject) return null;
  const levels = getLevels(subject.study_levels);

  let spec = undefined;
  let level = undefined;
  if (segment && levelSlug) {
    spec = subject.specializations.find((s) => s.slug === segment);
    level = levels.find((l) => l.slug === levelSlug);
    if (!spec || !level) return null;
  } else if (segment) {
    spec = subject.specializations.find((s) => s.slug === segment); // a specialization wins over a level with the same slug
    if (!spec) level = levels.find((l) => l.slug === segment);
    if (!spec && !level) return null;
  }
  return { subject, spec, level };
}

export async function internationalLandingMetadata(p: InternationalLandingProps): Promise<Metadata> {
  const d = await load(p);
  if (!d) return { title: "Page not found | Universta" };
  const focus = d.spec?.name ?? d.subject.name;
  return { title: `Study ${d.level ? `${focus} (${d.level.name})` : focus} abroad as an international student | Universta` };
}

export default async function InternationalLandingView(props: InternationalLandingProps) {
  const d = await load(props);
  if (!d) notFound();
  const { subject, spec, level } = d;

  const [countries, content, allSubjects] = await Promise.all([getCountries(), getPageContent("international-student"), getSubjects().catch(() => [])]);

  const focus = spec?.name ?? subject.name;
  const focusLabel = level ? `${focus} (${level.name})` : focus;
  const v = { subject: subject.name, focus: focusLabel };
  const scope = { subject: subject.slug, spec: spec?.slug, level: level?.slug };
  const countryHref = (from: string) => internationalHref({ ...scope, from });

  const copy = {
    title: fill(text(content, "landing", "title", "Study {focus} abroad as an international student"), { ...v, subject: `{${subject.name}}`, focus: `{${focusLabel}}` }),
    intro: fill(text(content, "landing", "intro", "Tell us where you are from. We’ll show the countries, fields and entry requirements open to you."), v),
    placeholder: text(content, "landing", "search_placeholder", "Search your home country to study {focus} abroad"),
    popularTitle: fill(text(content, "landing", "popular_title", "Popular countries"), v),
    allTitle: fill(text(content, "landing", "all_title", "Study {focus} from your country"), v),
    allIntro: fill(text(content, "landing", "all_intro", "Open a continent and pick your country."), v),
    back: fill(text(content, "landing", "back_link", "Back to {focus}"), v),
  };
  // Countries flagged popular in the countries table (is_popular). Hidden while none are flagged.
  const popular = countries
    .filter((c) => c.is_popular)
    .map((c) => ({ name: c.name, slug: c.slug, code: c.country_code, href: countryHref(c.slug) }));
  const continents = groupByContinent(countries).map((g) => ({
    name: g.name,
    countries: g.countries.map((c) => ({ name: c.name, slug: c.slug, code: c.country_code, href: countryHref(c.slug) })),
  }));

  // CTA and advertisement use the same blocks as the other pages (CtaBlock / AdBlock). This page has no
  // subject_sections rows, so they are built from the editable `landing` text (keys: cta_title, cta_body,
  // cta_button, cta_url, ad_title, ad_subtitle, ad_body, ad_url) and fall back to the defaults below.
  const plain = (s: string) => (s ? `<p>${s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")}</p>` : null);
  const cta: SectionItem = {
    id: "landing-cta",
    title: fill(text(content, "landing", "cta_title", "Not sure which country to pick for {subject}?"), v),
    subtitle: text(content, "landing", "cta_button", "Talk to an expert"),
    body: plain(fill(text(content, "landing", "cta_body", "Our advisers will help you compare countries, costs and entry requirements for your home country."), v)),
    url: text(content, "landing", "cta_url", "") || null, // empty = scrolls to the enquiry form
    is_sponsored: false,
  };
  const ad: SectionItem = {
    id: "landing-ad",
    title: text(content, "landing", "ad_title", "Advertisement space"),
    subtitle: text(content, "landing", "ad_subtitle", "") || null,
    body: plain(text(content, "landing", "ad_body", "Sponsored content will appear here.")),
    url: text(content, "landing", "ad_url", "") || null,
    is_sponsored: true,
  };
  const lead = {
    subjects: allSubjects.map((s) => ({ name: s.name, specializations: s.specializations.map((x) => x.name) })),
    subject: subject.name,
    ...(spec ? { specialization: spec.name } : {}),
    ...(level ? { level: level.name } : {}),
  };

  // Where "Back" goes: the page the visitor came from (subject, specialization, level or both).
  const backHref = `/subjects/${[subject.slug, spec?.slug, level?.slug].filter(Boolean).join("/")}`;

  return (
    <main>
      <DetailHero
        crumbs={[
          { label: "Home", href: "/" },
          { label: "Subjects", href: "/subjects" },
          { label: subject.name, href: `/subjects/${subject.slug}` },
          ...(spec ? [{ label: spec.name, href: `/subjects/${subject.slug}/${spec.slug}` }] : []),
          ...(level ? [{ label: level.name, href: backHref }] : []),
          { label: "International students" },
        ]}
        tile={<SubjectIcon name={subject.icon_key} slug={subject.slug} size="lg" />}
        title={withHighlight(copy.title)}
        lead={copy.intro}
        actions={
          <>
            <SaveButton />
            <a className="btn btn-dark" href="#advice">
              Talk to an expert
            </a>
          </>
        }
        facts={[
          { icon: Globe, label: "Home countries", value: `${countries.length} countries` },
          { icon: Layers, label: "Continents", value: `${continents.length}` },
          { icon: BookOpen, label: "Subject", value: <Link className="fact-link" href={`/subjects/${subject.slug}`}>{subject.name}</Link> },
        ]}
      />

      <DetailLayout
        main={
          <>
            <HomeCountryPicker
              subject={subject.slug}
              spec={spec?.slug}
              level={level?.slug}
              placeholder={copy.placeholder}
              focus={focusLabel}
              countries={countries.map((c) => ({ name: c.name, slug: c.slug }))}
            />
            {/* The whole section is hidden until at least one country is flagged popular in the backend. */}
            {popular.length > 0 && (
              <div className="mt-8">
                <Section id="popular" title={copy.popularTitle}>
                  <PopularCountries countries={popular} />
                </Section>
              </div>
            )}

            <div className="mt-8">
              <Section id="countries" title={copy.allTitle} intro={copy.allIntro}>
                {continents.length === 0 ? <Note>No countries are available yet.</Note> : <ContinentCards continents={continents} panelTitle={text(content, "landing", "panel_title", "Study abroad: pick your country in {continent}")} />}
                <Link className="link-arrow mt-8" href={backHref}>
                  {copy.back}
                  <ArrowRight className="ico" aria-hidden />
                </Link>
              </Section>
            </div>

            {/* CTA, then the advertisement slot: same blocks and layout as the other pages */}
            <div className="mt-8 stack-16">
              <CtaBlock item={cta} />
              <AdBlock item={ad} />
            </div>
          </>
        }
        aside={<AsideLead about={focus} lead={lead} />}
      />
    </main>
  );
}
