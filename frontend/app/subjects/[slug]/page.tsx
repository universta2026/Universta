import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { ArrowRight, BookOpen, ChevronRight, FileCheck, Globe, Landmark, Layers, MessageCircle, GraduationCap, Award } from "lucide-react";
import SaveButton from "@/components/SaveButton";
import SubNav from "@/components/SubNav";
import SubjectIcon from "@/components/SubjectIcon";
import RichText from "@/components/RichText";
import { AdBlock, CtaBlock, SectionCards } from "@/components/SubjectBlocks";
import {
  AsideLead,
  CareersTable,
  CostTable,
  DetailHero,
  DetailLayout,
  Faq,
  fieldFaq,
  hrefFor,
  Note,
  NextStepsBand,
  Ph,
  Section,
  StatCards,
} from "@/components/ui";
import { getPageContent, getSubject, getSubjects, text } from "@/lib/api";
import { getLevels } from "@/lib/levels";

type Props = { params: Promise<{ slug: string }> };

// "Computer Science & IT" -> "Computer Science" in running text
const shortName = (name: string) => name.replace(" & IT", "").replace(" & Management", "");

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const subject = await getSubject(slug);
  return { title: subject ? `${subject.name} | Universta` : "Subject not found | Universta" };
}

export default async function SubjectDetailPage({ params }: Props) {
  const { slug } = await params;
  const [subject, content, allSubjects] = await Promise.all([
    getSubject(slug),
    getPageContent("subject-detail"), // editable headings, rows in Directus: page_key = "subject-detail"
    getSubjects().catch(() => []), // only used for the "Other subjects" links
  ]);
  if (!subject) notFound();

  const short = shortName(subject.name);
  const copy = {
    overviewTitle: text(content, "overview", "title", "Overview"),
    specsTitle: text(content, "specializations", "title", "Specializations"),
    specsIntro: text(
      content,
      "specializations",
      "intro",
      "Narrow your focus. Each specialization has its own modules, universities and career paths.",
    ),
    levelsTitle: text(content, "study_levels", "title", "Study levels"),
    levelsIntro: text(
      content,
      "study_levels",
      "intro",
      "Choose a level to see entry requirements, programmes and costs.",
    ),
    unisTitle: text(content, "universities", "title", "Universities and programmes"),
    unisIntro: text(
      content,
      "universities",
      "intro",
      "A sample of programmes listed on Universta. Use filters on the courses page to see them all.",
    ),
    destTitle: text(content, "destinations", "title", `Where to study ${short}`),
    destIntro: text(
      content,
      "destinations",
      "intro",
      "Costs are typical yearly ranges. Check each university for exact fees.",
    ),
    careersTitle: text(content, "careers", "title", "Careers and salaries"),
    careersIntro: text(
      content,
      "careers",
      "intro",
      "Roles graduates commonly move into. Salaries vary a lot by country and experience.",
    ),
    faqTitle: text(content, "faq", "title", "Questions students ask"),
    industriesTitle: text(content, "industries", "title", "Industries and sectors"),
    industriesIntro: text(content, "industries", "intro", `Where ${short} skills are used.`),
    companiesTitle: text(content, "companies", "title", "Companies and employers"),
    companiesIntro: text(content, "companies", "intro", `Organisations connected with ${short}.`),
    coursesTitle: text(content, "courses", "title", "Popular courses"),
    coursesIntro: text(content, "courses", "intro", `Courses you can explore in ${short}.`),
  };

  const levels = getLevels(subject.study_levels); // Undergraduate / Postgraduate naming + MBA and PGDM
  const hasSpecs = subject.specializations.length > 0;
  const hasLevels = levels.length > 0;
  const about = subject.about?.body ? subject.about : null;
  const why = subject.why?.body ? subject.why : null;
  const ad = subject.advertisement ?? null;
  const cta = subject.cta ?? null;
  const industries = subject.industries ?? [];
  const companies = subject.companies ?? [];
  const courses = subject.courses ?? [];
  const universities = subject.universities ?? [];
  const destinations = subject.destinations ?? [];
  const lead = { subjects: allSubjects.map((s) => s.name), subject: subject.name };

  const tabs = [
    { id: "overview", label: copy.overviewTitle, show: true },
    { id: "specializations", label: copy.specsTitle, show: hasSpecs },
    { id: "why", label: "Why study", show: !!why },
    { id: "industries", label: "Industries", show: industries.length > 0 },
    { id: "companies", label: "Companies", show: companies.length > 0 },
    { id: "study-levels", label: copy.levelsTitle, show: hasLevels },
    { id: "courses", label: "Courses", show: courses.length > 0 },
    { id: "universities", label: "Universities", show: true },
    { id: "destinations", label: "Where to study", show: true },
    { id: "careers", label: "Careers", show: true },
    { id: "faq", label: "FAQ", show: true },
  ].filter((t) => t.show);

  return (
    <main>
      <DetailHero
        crumbs={[
          { label: "Home", href: "/" },
          { label: "Subjects", href: "/subjects" },
          { label: subject.name },
        ]}
        tile={<SubjectIcon name={subject.icon_key} size="lg" />}
        title={
          <>
            Study <span className="hl">{subject.name}</span> abroad
          </>
        }
        lead={subject.description}
        actions={
          <>
            <SaveButton />
            <a className="btn btn-dark" href="#advice">
              Talk to an expert
            </a>
          </>
        }
        facts={[
          { icon: Layers, label: "Levels", value: `${levels.length} levels` },
          { icon: BookOpen, label: "Specializations", value: subject.specializations.length },
          { icon: Landmark, label: "Universities", value: <Ph>NUMBER</Ph> },
          { icon: GraduationCap, label: "Courses", value: <Ph>NUMBER</Ph> },
        ]}
      />
      <SubNav items={tabs.map((t) => ({ id: t.id, label: t.label }))} />

      <DetailLayout
        main={
          <>
            <Section id="overview" title={about?.title ?? copy.overviewTitle}>
              <div className="body-copy">
                {about ? (
                  <RichText html={about.body} />
                ) : (
                  <>
                    <p>{subject.description ?? `Explore studying ${subject.name} abroad.`}</p>
                    <p className="muted">
                      Studying {short} abroad gives you access to specialist teaching, industry links and a global network. Below
                      you’ll find the levels you can study, the universities that offer it, what it costs in each country, and where
                      it can take your career.
                    </p>
                  </>
                )}
              </div>
              <StatCards />
            </Section>

            {hasSpecs && (
              <Section id="specializations" title={copy.specsTitle} intro={copy.specsIntro}>
                <div className="grid g-2">
                  {subject.specializations.map((sp) => (
                    <Link className="card" href={`/subjects/${subject.slug}/${sp.slug}`} key={sp.id}>
                      <div className="row between">
                        <h3 className="card-title">{sp.name}</h3>
                        <ChevronRight className="ico" aria-hidden />
                      </div>
                      {sp.description && <p className="muted small mt-2">{sp.description}</p>}
                    </Link>
                  ))}
                </div>
              </Section>
            )}

            {why && (
              <Section id="why" title={why.title}>
                <div className="body-copy">
                  <RichText html={why.body} />
                </div>
              </Section>
            )}

            {industries.length > 0 && (
              <Section id="industries" title={copy.industriesTitle} intro={copy.industriesIntro}>
                <SectionCards items={industries} />
              </Section>
            )}

            {companies.length > 0 && (
              <Section id="companies" title={copy.companiesTitle} intro={copy.companiesIntro}>
                <SectionCards items={companies} />
              </Section>
            )}

            {hasLevels && (
              <Section id="study-levels" title={copy.levelsTitle} intro={copy.levelsIntro}>
                <div className="grid g-3">
                  {levels.map((lvl) => (
                    <Link className="card" href={`/subjects/${subject.slug}/${lvl.slug}`} key={lvl.id}>
                      {lvl.duration && <span className="tag">{lvl.duration}</span>}
                      <h3 className="card-title mt-4">
                        {lvl.name} in {short}
                      </h3>
                      {lvl.description && <p className="muted small mt-2">{lvl.description}</p>}
                      <span className="link-arrow mt-4">
                        See {lvl.name} options
                        <ArrowRight className="ico" aria-hidden />
                      </span>
                    </Link>
                  ))}
                </div>
              </Section>
            )}

            {ad && <AdBlock item={ad} />}
            {cta && <CtaBlock item={cta} />}

            {courses.length > 0 && (
              <Section id="courses" title={copy.coursesTitle} intro={copy.coursesIntro}>
                <SectionCards items={courses} linkLabel="View course" />
              </Section>
            )}

            <Section id="universities" title={copy.unisTitle} intro={copy.unisIntro}>
              {universities.length > 0 ? (
                <SectionCards items={universities} linkLabel="Visit university" />
              ) : (
                <Note>No programmes listed yet for this field.</Note>
              )}
              <div className="mt-6">
                <a className="btn btn-outline" href={hrefFor("universities")}>
                  Browse all universities
                </a>
              </div>
            </Section>

            <Section id="destinations" title={copy.destTitle} intro={copy.destIntro}>
              {destinations.length > 0 && (
                <div style={{ marginBottom: 24 }}>
                  <SectionCards items={destinations} linkLabel="Learn more" />
                </div>
              )}
              <CostTable lastCol="post-study" />
            </Section>

            <Section id="careers" title={copy.careersTitle} intro={copy.careersIntro}>
              <CareersTable />
            </Section>

            <Section id="faq" title={copy.faqTitle}>
              <Faq items={fieldFaq(short)} />
            </Section>
          </>
        }
        aside={<AsideLead about={short} lead={lead} />}
      />

      <NextStepsBand
        items={[
          { icon: Award, title: "Scholarships", desc: `Funding for ${short} students`, key: "scholarships" },
          { icon: FileCheck, title: "Pick your test", desc: "IELTS, TOEFL, PTE, GRE", key: "exams" },
          { icon: Globe, title: "Compare countries", desc: "Costs, intakes, work rights", key: "destinations" },
          { icon: MessageCircle, title: "Find a consultant", desc: "Verified, reviewed advisers", key: "consultants" },
        ]}
      />
    </main>
  );
}
