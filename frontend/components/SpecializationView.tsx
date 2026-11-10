// Specialization page body. Used by /subjects/[slug]/[specialization] (see that route).
import Link from "next/link";
import { ArrowRight, Award, BookOpen, FileCheck, Globe, Landmark, Layers, MessageCircle, GraduationCap } from "lucide-react";
import RichText from "@/components/RichText";
import { plainText } from "@/lib/plain-text";
import type { LevelPageSections, Specialization, StudyLevel, SubjectDetail } from "@/lib/api";
import type { LeadContext } from "./LeadForm";
import { AdBlock, CtaBlock, SectionCards } from "./SubjectBlocks";
import SaveButton from "./SaveButton";
import SubNav from "./SubNav";
import SubjectIcon from "./SubjectIcon";
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
} from "./ui";

export default function SpecializationView({
  subject,
  spec,
  levels,
  lead,
  sections = {},
}: {
  subject: SubjectDetail;
  spec: Specialization;
  levels: StudyLevel[];
  lead: LeadContext;
  sections?: LevelPageSections; // CMS blocks (subject_sections rows for this specialization)
}) {
  const about = sections.about?.body ? sections.about : null;
  const why = sections.why?.body ? sections.why : null;
  const industries = sections.industries ?? [];
  const companies = sections.companies ?? [];
  const courses = sections.courses ?? [];
  const destinations = sections.destinations ?? [];
  const universities = sections.universities ?? [];
  const ad = sections.advertisement ?? null;
  const cta = sections.cta ?? null;

  const intro =
    plainText(spec.description) ||
    `A focused path within ${subject.name}. See what you’ll study, where to study it and the careers it leads to.`;

  return (
    <main>
      <DetailHero
        crumbs={[
          { label: "Home", href: "/" },
          { label: "Subjects", href: "/subjects" },
          { label: subject.name, href: `/subjects/${subject.slug}` },
          { label: spec.name },
        ]}
        tile={<SubjectIcon name={subject.icon_key} size="lg" />}
        title={
          <>
            Study <span className="hl">{spec.name}</span> abroad
          </>
        }
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
          { icon: BookOpen, label: "Subject", value: <Link className="fact-link" href={`/subjects/${subject.slug}`}>{subject.name}</Link> },
          { icon: Landmark, label: "Universities", value: <Ph>NUMBER</Ph> },
          { icon: GraduationCap, label: "Courses", value: <Ph>NUMBER</Ph> },
        ]}
      />
      <SubNav
        items={[
          { id: "overview", label: "Overview", show: true },
          { id: "why", label: "Why study", show: !!why },
          { id: "industries", label: "Industries", show: industries.length > 0 },
          { id: "companies", label: "Companies", show: companies.length > 0 },
          { id: "levels", label: "Study levels", show: levels.length > 0 },
          { id: "courses", label: "Courses", show: courses.length > 0 },
          { id: "destinations", label: "Where to study", show: true },
          { id: "universities", label: "Universities", show: true },
          { id: "learn", label: "What you’ll study", show: true },
          { id: "careers", label: "Careers", show: true },
          { id: "faq", label: "FAQ", show: true },
        ].filter((t) => t.show)}
      />

      <DetailLayout
        main={
          <>
            <Section id="overview" title={about?.title ?? "Overview"}>
              <div className="body-copy">
                {about ? (
                  <RichText html={about.body} />
                ) : (
                  <>
                    <p>{intro}</p>
                    <p className="muted">
                      Studying {spec.name} abroad gives you access to specialist teaching, industry links and a global network.
                      Below you’ll find the levels you can study, the universities that offer it, what it costs in each country,
                      and where it can take your career.
                    </p>
                  </>
                )}
              </div>
              <StatCards />
            </Section>

            {why && (
              <Section id="why" title={why.title}>
                <div className="body-copy">
                  <RichText html={why.body} />
                </div>
              </Section>
            )}

            {industries.length > 0 && (
              <Section id="industries" title={`Popular industries for ${spec.name}`}>
                <SectionCards items={industries} />
              </Section>
            )}

            {companies.length > 0 && (
              <Section id="companies" title={`Popular companies for ${spec.name}`}>
                <SectionCards items={companies} />
              </Section>
            )}

            {levels.length > 0 && (
              <Section id="levels" title="Study levels" intro="Choose a level to see entry requirements, programmes and costs.">
                <div className="grid g-3">
                  {levels.map((lvl) => (
                    <Link className="card" href={`/subjects/${subject.slug}/${spec.slug}/${lvl.slug}`} key={lvl.id}>
                      {lvl.duration && <span className="tag">{lvl.duration}</span>}
                      <h3 className="card-title mt-4">
                        {lvl.name} in {spec.name}
                      </h3>
                      {lvl.description && <p className="muted small mt-2">{plainText(lvl.description)}</p>}
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
              <Section id="courses" title={`Recommended courses in ${spec.name}`}>
                <SectionCards items={courses} linkLabel="View course" />
              </Section>
            )}

            <Section
              id="destinations"
              title={`Recommended destinations to study ${spec.name}`}
              intro="Costs are typical yearly ranges. Check each university for exact fees."
            >
              {destinations.length > 0 && (
                <div style={{ marginBottom: 24 }}>
                  <SectionCards items={destinations} linkLabel="Learn more" />
                </div>
              )}
              <CostTable lastCol="post-study" />
            </Section>

            <Section
              id="universities"
              title={`Recommended universities for ${spec.name}`}
              intro="A sample of programmes listed on Universta. Use filters on the courses page to see them all."
            >
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

            <Section
              id="learn"
              title="What you’ll study"
              intro="Typical modules. Exact content varies by university - check each course page."
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

            <Section
              id="careers"
              title="Careers and salaries"
              intro="Roles graduates commonly move into. Salaries vary a lot by country and experience."
            >
              <CareersTable />
            </Section>

            <Section id="faq" title="Frequently asked questions">
              <Faq items={fieldFaq(spec.name)} />
            </Section>
          </>
        }
        aside={<AsideLead about={spec.name} lead={lead} />}
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
