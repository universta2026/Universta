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

type Props = { params: Promise<{ slug: string }> };

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const subject = await getSubject(slug);
  return { title: subject ? `Study ${subject.name} abroad as an international student | Universta` : "Subject not found | Universta" };
}

// /subjects/engineering/international-student : pick your home country for this subject.
// Countries come from the countries table (GET /countries); text from page_content with fallbacks.
export default async function InternationalStudentPage({ params }: Props) {
  const { slug } = await params;
  const [subject, countries, content, allSubjects] = await Promise.all([
    getSubject(slug),
    getCountries(),
    getPageContent("international-student"),
    getSubjects().catch(() => []),
  ]);
  if (!subject) notFound();

  const v = { subject: subject.name };
  const copy = {
    title: fill(text(content, "landing", "title", "Study {subject} abroad as an international student"), { subject: `{${subject.name}}` }),
    intro: text(content, "landing", "intro", "Tell us where you are from. We’ll show the countries, fields and entry requirements open to you."),
    placeholder: text(content, "landing", "search_placeholder", "Search your home country to study {focus} abroad"),
    popularTitle: fill(text(content, "landing", "popular_title", "Popular countries"), v),
    allTitle: fill(text(content, "landing", "all_title", "Study {subject} from your country"), v),
    allIntro: text(content, "landing", "all_intro", "Open a continent and pick your country."),
  };
  // Countries flagged popular in the countries table (is_popular). Hidden while none are flagged.
  const popular = countries
    .filter((c) => c.is_popular)
    .map((c) => ({ name: c.name, slug: c.slug, href: internationalHref({ subject: subject.slug, from: c.slug }) }));
  const continents = groupByContinent(countries).map((g) => ({
    name: g.name,
    countries: g.countries.map((c) => ({ name: c.name, slug: c.slug, href: internationalHref({ subject: subject.slug, from: c.slug }) })),
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
  const lead = { subjects: allSubjects.map((s) => ({ name: s.name, specializations: s.specializations.map((x) => x.name) })), subject: subject.name };

  return (
    <main>
      <DetailHero
        crumbs={[
          { label: "Home", href: "/" },
          { label: "Subjects", href: "/subjects" },
          { label: subject.name, href: `/subjects/${subject.slug}` },
          { label: "International students" },
        ]}
        tile={<SubjectIcon name={subject.icon_key} size="lg" />}
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
              placeholder={copy.placeholder}
              focus={subject.name}
              countries={countries.map((c) => ({ name: c.name, slug: c.slug }))}
            />
            {/* The heading always shows; the cards appear once countries are flagged popular in the backend. */}
            <div className="mt-8">
              <Section id="popular" title={copy.popularTitle}>
                {popular.length > 0 && <PopularCountries countries={popular} />}
              </Section>
            </div>

            <div className="mt-8">
              <Section id="countries" title={copy.allTitle} intro={copy.allIntro}>
                {continents.length === 0 ? <Note>No countries are available yet.</Note> : <ContinentCards continents={continents} panelTitle={text(content, "landing", "panel_title", "Study abroad: pick your country in {continent}")} />}
                <Link className="link-arrow mt-8" href={`/subjects/${subject.slug}`}>
                  Back to {subject.name}
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
        aside={<AsideLead about={subject.name} lead={lead} />}
      />
    </main>
  );
}
