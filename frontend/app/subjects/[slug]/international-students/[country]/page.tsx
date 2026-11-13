import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { ArrowRight, Award, FileCheck, Globe, Layers, MessageCircle, Plane, ShieldCheck } from "lucide-react";
import ContinentCards from "@/components/ContinentCards";
import HomeCountryPicker from "@/components/HomeCountryPicker";
import SaveButton from "@/components/SaveButton";
import SubNav from "@/components/SubNav";
import SubjectIcon from "@/components/SubjectIcon";
import { AsideLead, DetailHero, DetailLayout, Faq, NextStepsBand, Note, Section, withHighlight } from "@/components/ui";
import { getCountries, getPageContent, getSubject, getSubjects, text } from "@/lib/api";
import { groupByContinent } from "@/lib/continents";
import { fill, internationalHref } from "@/lib/eligibility";

type Props = { params: Promise<{ slug: string; country: string }>; searchParams: Promise<{ spec?: string; level?: string }> };

// Subject, countries (countries table) and text (page_content, with fallbacks) all come from the API.
async function load(slug: string, country: string) {
  const [subject, countries, allSubjects, content] = await Promise.all([
    getSubject(slug),
    getCountries(),
    getSubjects().catch(() => []),
    getPageContent("international-student"),
  ]);
  const home = countries.find((c) => c.slug === country);
  return subject && home ? { subject, home, countries, allSubjects, content } : null;
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug, country } = await params;
  const d = await load(slug, country);
  return { title: d ? `Study ${d.subject.name} abroad from ${d.home.name} | Universta` : "Page not found | Universta" };
}

// /subjects/engineering/international-students/india
export default async function InternationalStudentsCountryPage({ params, searchParams }: Props) {
  const { slug, country } = await params;
  const { spec: specSlug, level: levelSlug } = await searchParams;
  const d = await load(slug, country);
  if (!d) notFound();
  const { subject, home, countries, allSubjects, content } = d;

  const spec = subject.specializations.find((s) => s.slug === specSlug);
  const level = subject.study_levels.find((l) => l.slug === levelSlug);
  const focus = spec?.name ?? subject.name;
  const v = { subject: subject.name, country: home.name, focus: level ? `${focus} (${level.name})` : focus };
  const t = (section: string, key: string, fallback: string) => fill(text(content, section, key, fallback), v);

  // Destinations = every published country except the home country, grouped by continent.
  const destinations = countries.filter((c) => c.slug !== home.slug);
  const continents = groupByContinent(destinations).map((g) => ({
    name: g.name,
    countries: g.countries.map((c) => ({ name: c.name, slug: c.slug })),
  }));

  // The subject being viewed comes first, then the rest A-Z.
  const subjects = [...allSubjects].sort(
    (a, b) => Number(b.slug === subject.slug) - Number(a.slug === subject.slug) || a.name.localeCompare(b.name),
  );
  const lead = { subjects: allSubjects.map((s) => ({ name: s.name, specializations: s.specializations.map((x) => x.name) })), subject: subject.name, ...(spec ? { specialization: spec.name } : {}), ...(level ? { level: level.name } : {}) };
  const faq = [1, 2, 3]
    .map((n) => ({ q: t("faq", `q${n}`, ""), a: t("faq", `a${n}`, "") }))
    .filter((f) => f.q && f.a);

  return (
    <main>
      <DetailHero
        crumbs={[
          { label: "Home", href: "/" },
          { label: "Subjects", href: "/subjects" },
          { label: subject.name, href: `/subjects/${subject.slug}` },
          { label: "International students", href: internationalHref({ subject: subject.slug }) },
          { label: home.name },
        ]}
        tile={<SubjectIcon name={subject.icon_key} size="lg" />}
        title={withHighlight(fill(text(content, "country", "title", "Study {focus} abroad from {country}"), { ...v, focus: `{${v.focus}}` }))}
        lead={t("country", "intro", "Everything open to a student from {country}: where you can study {focus}, and which other fields you can apply for.")}
        actions={
          <>
            <SaveButton />
            <a className="btn btn-dark" href="#advice">
              Talk to an expert
            </a>
          </>
        }
        facts={[
          { icon: ShieldCheck, label: "Home country", value: home.name },
          { icon: Globe, label: "Destinations", value: `${destinations.length} countries` },
          { icon: Layers, label: "Continents", value: `${continents.length}` },
          { icon: Award, label: "Fields", value: `${subjects.length} subjects` },
        ]}
      />
      <SubNav
        items={[
          { id: "destinations", label: "Where to study", show: true },
          { id: "fields", label: "Fields", show: subjects.length > 0 },
          { id: "levels", label: "Study levels", show: subject.study_levels.length > 0 },
          { id: "faq", label: "FAQ", show: faq.length > 0 },
        ].filter((i) => i.show)}
      />

      <DetailLayout
        main={
          <>
            <HomeCountryPicker
              subject={subject.slug}
              placeholder={text(content, "landing", "search_placeholder", "Search your home country to study {focus} abroad")}
              focus={focus}
              countries={countries.map((c) => ({ name: c.name, slug: c.slug }))}
              current={home.slug}
              spec={spec?.slug}
              level={level?.slug}
            />

            <div className="mt-8">
              <Section
                id="destinations"
                title={t("destinations", "title", "Countries open to students from {country}")}
                intro={t("destinations", "intro", "Open a continent to see its countries.")}
              >
                {continents.length === 0 ? <Note>No destinations are listed yet.</Note> : <ContinentCards continents={continents} panelTitle={text(content, "destinations", "panel_title", "Study abroad countries in {continent} you are eligible for")} />}
                <div className="mt-6">
                  <Note>{t("destinations", "disclaimer", "Entry rules change. Confirm with the university and the embassy before you apply.")}</Note>
                </div>
              </Section>
            </div>

            <Section
              id="fields"
              title={t("fields", "title", "Fields open to students from {country}")}
              intro={t("fields", "intro", "The field you are viewing is first.")}
            >
              <div className="grid g-2">
                {subjects.map((s) => (
                  <div className="card" key={s.id}>
                    <h3 className="card-title">
                      <Link className="stretched" href={internationalHref({ subject: s.slug, from: home.slug })} style={{ color: "inherit" }}>
                        {s.name}
                      </Link>
                    </h3>
                    {s.specializations.length > 0 && (
                      <div className="tags mt-4 above">
                        {s.specializations.slice(0, 6).map((sp) => (
                          <Link key={sp.id} className="tag tag-link" href={`/subjects/${s.slug}/${sp.slug}`}>
                            {sp.name}
                          </Link>
                        ))}
                      </div>
                    )}
                  </div>
                ))}
              </div>
            </Section>

            {subject.study_levels.length > 0 && (
              <Section id="levels" title={t("levels", "title", "{subject} levels you can apply for")}>
                <div className="grid g-3">
                  {subject.study_levels.map((l) => (
                    <Link className="card" href={`/subjects/${subject.slug}/${l.slug}`} key={l.id}>
                      {l.duration && <span className="tag">{l.duration}</span>}
                      <h3 className="card-title mt-4">{l.name}</h3>
                      <span className="link-arrow mt-4">
                        See options
                        <ArrowRight className="ico" aria-hidden />
                      </span>
                    </Link>
                  ))}
                </div>
              </Section>
            )}

            {faq.length > 0 && (
              <Section id="faq" title={t("faq", "title", "Studying abroad from {country}")}>
                <Faq items={faq} />
              </Section>
            )}
          </>
        }
        aside={<AsideLead about={focus} lead={lead} />}
      />

      <NextStepsBand
        items={[
          { icon: Award, title: "Scholarships", desc: `Funding for ${subject.name} students`, key: "scholarships" },
          { icon: FileCheck, title: "Pick your test", desc: "IELTS, TOEFL, PTE, GRE", key: "exams" },
          { icon: Plane, title: "Student visa", desc: "Step-by-step guides", key: "student-visa" },
          { icon: MessageCircle, title: "Find a consultant", desc: "Verified, reviewed advisers", key: "consultants" },
        ]}
      />
    </main>
  );
}
