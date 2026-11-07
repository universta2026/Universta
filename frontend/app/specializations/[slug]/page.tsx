import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
<<<<<<< HEAD
<<<<<<< HEAD
import RichText from "@/components/RichText";
import { getSpecialization } from "@/lib/api";
import { stripHtml } from "@/lib/html";
=======
=======
import RichText from "@/components/RichText";
import { getSpecialization } from "@/lib/api";
import { stripHtml } from "@/lib/html";
>>>>>>> f68f3c9edb917d636d8b39bcce28650d83c63881
import { ArrowRight, Award, BookOpen, FileCheck, Globe, Landmark, Layers, MessageCircle, Wallet } from "lucide-react";
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
import { getSpecialization, getSubject } from "@/lib/api";
<<<<<<< HEAD
>>>>>>> b52474e6ff028c1a093a3a6d1612d705d8f57320
=======
>>>>>>> f68f3c9edb917d636d8b39bcce28650d83c63881

type Props = { params: Promise<{ slug: string }> };

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const spec = await getSpecialization(slug);
  return { title: spec ? `${spec.name} | Universta` : "Specialization not found | Universta" };
}

export default async function SpecializationPage({ params }: Props) {
  const { slug } = await params;
  const spec = await getSpecialization(slug);
  if (!spec) notFound();

  // The parent subject supplies the study levels, the icon and the "related specializations" links.
  const subject = await getSubject(spec.subject_slug).catch(() => null);
  const levels = subject?.study_levels ?? [];
  const related = (subject?.specializations ?? []).filter((s) => s.id !== spec.id).slice(0, 5);
  const intro =
    spec.description ??
    `A focused path within ${spec.subject_name}. See what you’ll study, where to study it and the careers it leads to.`;

  return (
    <main className="mx-auto max-w-4xl px-4 py-8">
      <nav className="text-xs text-slate-500">
        <Link href="/" className="hover:text-slate-900">Home</Link>
        <span className="mx-2">›</span>
        <Link href="/subjects" className="hover:text-slate-900">Subjects</Link>
        <span className="mx-2">›</span>
        <Link href={`/subjects/${spec.subject_slug}`} className="hover:text-slate-900">
          {spec.subject_name}
        </Link>
        <span className="mx-2">›</span>
        <span className="text-slate-900">{spec.name}</span>
      </nav>

      <p className="mt-6 text-xs font-semibold tracking-widest text-blue-600">SPECIALIZATION</p>
      <h1 className="mt-2 text-3xl font-bold text-slate-900">{spec.name}</h1>
      {stripHtml(spec.description) && (
        <RichText html={spec.description ?? ""} className="mt-3 max-w-2xl" />
      )}

      <Link
        href={`/subjects/${spec.subject_slug}`}
        className="mt-8 inline-block rounded-lg border border-slate-300 px-4 py-2 text-sm font-medium hover:border-blue-400"
      >
        ← Back to {spec.subject_name}
      </Link>
    <main>
      <DetailHero
        crumbs={[
          { label: "Home", href: "/" },
          { label: "Subjects", href: "/subjects" },
          { label: spec.subject_name, href: `/subjects/${spec.subject_slug}` },
          { label: spec.name },
        ]}
        eyebrow={`Specialization · ${spec.subject_name}`}
        tile={<SubjectIcon name={subject?.icon_key ?? null} size="lg" />}
        title={spec.name}
        lead={intro}
        actions={
          <>
            <SaveButton />
            <a className="btn btn-dark" href="#advice">
              Talk to an expert
            </a>
          </>
        }
        facts={[
          { icon: Layers, label: "Levels", value: levels.length > 0 ? `${levels.length} levels` : <Ph>N</Ph> },
          { icon: BookOpen, label: "Subject", value: spec.subject_name },
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
      <SubNav
        items={[
          { id: "overview", label: "Overview" },
          { id: "learn", label: "What you’ll study" },
          ...(levels.length > 0 ? [{ id: "levels", label: "Study levels" }] : []),
          { id: "universities", label: "Universities" },
          { id: "destinations", label: "Where to study" },
          { id: "careers", label: "Careers" },
          { id: "faq", label: "FAQ" },
        ]}
      />

<<<<<<< HEAD
<<<<<<< HEAD
      <p className="mt-6 text-xs font-semibold tracking-widest text-blue-600">SPECIALIZATION</p>
      <h1 className="mt-2 text-3xl font-bold text-slate-900">{spec.name}</h1>
      {stripHtml(spec.description) && (
        <RichText html={spec.description ?? ""} className="mt-3 max-w-2xl" />
      )}
=======
=======
>>>>>>> f68f3c9edb917d636d8b39bcce28650d83c63881
      <DetailLayout
        main={
          <>
            <Section id="overview" title="Overview">
              <div className="body-copy">
                <p>{intro}</p>
                <p className="muted">
                  Studying {spec.name} abroad gives you access to specialist teaching, industry links and a global network. Below
                  you’ll find the levels you can study, the universities that offer it, what it costs in each country, and where
                  it can take your career.
                </p>
              </div>
              <StatCards />
            </Section>
<<<<<<< HEAD
>>>>>>> b52474e6ff028c1a093a3a6d1612d705d8f57320
=======
>>>>>>> f68f3c9edb917d636d8b39bcce28650d83c63881

            <Section
              id="learn"
              title="What you’ll study"
              intro="Typical modules. Exact content varies by university — check each course page."
            >
              <div className="grid g-2">
                {[1, 2, 3, 4].map((n) => (
                  <div className="card card-flat row" style={{ padding: "16px 20px" }} key={n}>
                    <span className="tag tag-blue">0{n}</span>
                    <span style={{ fontWeight: 600 }}>
                      <Ph>MODULE</Ph>
                    </span>
                  </div>
                ))}
              </div>
            </Section>

            {levels.length > 0 && (
              <Section id="levels" title="Study levels" intro="Choose a level to see entry requirements, programmes and costs.">
                <div className="grid g-3">
                  {levels.map((lvl) => (
                    <Link className="card" href={`/specializations/${spec.slug}/${lvl.slug}`} key={lvl.id}>
                      {lvl.duration && <span className="tag">{lvl.duration}</span>}
                      <h3 className="card-title mt-4">
                        {lvl.name} in {spec.name}
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

            <Section
              id="universities"
              title="Universities and programmes"
              intro="A sample of programmes listed on Universta. Use filters on the courses page to see them all."
            >
              <Note>No programmes listed yet for this field.</Note>
              <div className="mt-6">
                <a className="btn btn-outline" href={hrefFor("universities")}>
                  Browse all universities
                </a>
              </div>
            </Section>

            <Section
              id="destinations"
              title={`Where to study ${spec.name}`}
              intro="Costs are typical yearly ranges. Check each university for exact fees."
            >
              <CostTable lastCol="post-study" />
            </Section>

            <Section
              id="careers"
              title="Careers and salaries"
              intro="Roles graduates commonly move into. Salaries vary a lot by country and experience."
            >
              <CareersTable />
            </Section>

            <Section id="faq" title="Questions students ask">
              <Faq items={fieldFaq(spec.name)} />
            </Section>
          </>
        }
        aside={
          <>
            <AsideLead about={spec.name} />
            <AsideCard title="At a glance">
              <Kv
                rows={[
                  ["Levels", levels.length > 0 ? levels.map((l) => l.name).join(", ") : <Ph key="l">LEVELS</Ph>],
                  ["Typical duration", "1–4 years"],
                  ["English test", "IELTS / TOEFL / PTE"],
                  ["Intakes", "Sep · Jan · Feb"],
                ]}
              />
            </AsideCard>
            {related.length > 0 && (
              <AsideLinks
                title="Related specializations"
                links={related.map((s) => ({ label: s.name, href: `/specializations/${s.slug}` }))}
              />
            )}
          </>
        }
      />

      <NextStepsBand
        items={[
          { icon: Award, title: "Scholarships", desc: `Funding for ${spec.name} students`, key: "scholarships" },
          { icon: FileCheck, title: "Pick your test", desc: "IELTS, TOEFL, PTE, GRE", key: "exams" },
          { icon: Globe, title: "Compare countries", desc: "Costs, intakes, work rights", key: "destinations" },
          { icon: MessageCircle, title: "Find a consultant", desc: "Verified, reviewed advisers", key: "consultants" },
        ]}
      />
    </main>
  );
}
