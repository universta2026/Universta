import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { ChevronRight } from "lucide-react";
import RichText from "@/components/RichText";
import SubjectIcon from "@/components/SubjectIcon";
import { getPageContent, getSubject, text } from "@/lib/api";
import { stripHtml } from "@/lib/html";
import { ArrowRight, BookOpen, ChevronRight, FileCheck, Globe, Landmark, Layers, MessageCircle, Wallet, Award } from "lucide-react";
import SaveButton from "@/components/SaveButton";
import SubNav from "@/components/SubNav";
import SubjectIcon from "@/components/SubjectIcon";
import {
  AsideCard,
  AsideLead,
  AsideLinks,
  CareersTable,
  CostTable,
  DetailHero,
  DetailLayout,
  Faq,
  fieldFaq,
  hrefFor,
  Kv,
  Note,
  NextStepsBand,
  Ph,
  Section,
  StatCards,
} from "@/components/ui";
import { getPageContent, getSubject, getSubjects, text } from "@/lib/api";

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
  };

  const lead = stripHtml(subject.description); // plain-text summary for the header
  const hasSpecs = subject.specializations.length > 0;
  const hasLevels = subject.study_levels.length > 0;
  const others = allSubjects.filter((s) => s.id !== subject.id).slice(0, 5);

  const tabs = [
    { id: "overview", label: copy.overviewTitle, show: true },
    { id: "specializations", label: copy.specsTitle, show: hasSpecs },
    { id: "study-levels", label: copy.levelsTitle, show: hasLevels },
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
        eyebrow="Subject"
        tile={<SubjectIcon name={subject.icon_key} size="lg" />}
        title={subject.name}
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
          { icon: Layers, label: "Levels", value: `${subject.study_levels.length} levels` },
          { icon: BookOpen, label: "Specializations", value: subject.specializations.length },
          { icon: Landmark, label: "Universities", value: <Ph>NUMBER</Ph> },
          {
            icon: Wallet,
            label: "Tuition from",
            value: (
              <>
                <Ph>FEE</Ph> / yr
              </>
            ),
          },
        ]}
      />
      <SubNav items={tabs.map((t) => ({ id: t.id, label: t.label }))} />

      <DetailLayout
        main={
          <>
            <Section id="overview" title={copy.overviewTitle}>
              <div className="body-copy">
                <p>{subject.description ?? `Explore studying ${subject.name} abroad.`}</p>
                <p className="muted">
                  Studying {short} abroad gives you access to specialist teaching, industry links and a global network. Below
                  you’ll find the levels you can study, the universities that offer it, what it costs in each country, and where
                  it can take your career.
                </p>
              </div>
              <StatCards />
            </Section>

            {hasSpecs && (
              <Section id="specializations" title={copy.specsTitle} intro={copy.specsIntro}>
                <div className="grid g-2">
                  {subject.specializations.map((sp) => (
                    <Link className="card" href={`/specializations/${sp.slug}`} key={sp.id}>
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

            {hasLevels && (
              <Section id="study-levels" title={copy.levelsTitle} intro={copy.levelsIntro}>
                <div className="grid g-3">
                  {subject.study_levels.map((lvl) => (
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

            <Section id="universities" title={copy.unisTitle} intro={copy.unisIntro}>
              <Note>No programmes listed yet for this field.</Note>
              <div className="mt-6">
                <a className="btn btn-outline" href={hrefFor("universities")}>
                  Browse all universities
                </a>
              </div>
            </Section>

            <Section id="destinations" title={copy.destTitle} intro={copy.destIntro}>
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
        aside={
          <>
            <AsideLead about={short} />
            <AsideCard title="At a glance">
              <Kv
                rows={[
                  ["Levels", hasLevels ? subject.study_levels.map((l) => l.name).join(", ") : <Ph key="l">LEVELS</Ph>],
                  ["Typical duration", "1–4 years"],
                  ["English test", "IELTS / TOEFL / PTE"],
                  ["Intakes", "Sep · Jan · Feb"],
                ]}
              />
            </AsideCard>
            {others.length > 0 && (
              <AsideLinks title="Other subjects" links={others.map((s) => ({ label: s.name, href: `/subjects/${s.slug}` }))} />
            )}
          </>
        }
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
