// One study-level page (e.g. "Postgraduate in Data Science"), shared by
// /subjects/[slug]/[level] and /subjects/[slug]/[specialization]/[level].
import type { ReactNode } from "react";
import { ArrowRight, Briefcase, Calendar, Clock, FileCheck, GraduationCap, Landmark, Plane, Presentation, Wallet } from "lucide-react";
import Link from "next/link";
import RichText from "@/components/RichText";
import { plainText } from "@/lib/plain-text";
import type { LevelPageSections, Specialization, StudyLevel } from "@/lib/api";
import { AdBlock, CtaBlock, SectionCards } from "./SubjectBlocks";
import { inlineLevel, levelKindOf, type LevelKind } from "@/lib/levels";
import type { LeadContext } from "./LeadForm";
import SaveButton from "./SaveButton";
import SubjectIcon from "./SubjectIcon";
import SubNav from "./SubNav";
import { AsideLead, CostTable, DetailHero, DetailLayout, Faq, hrefFor, Note, NextStepsBand, Ph, Section, Ticks } from "./ui";

const entryLabel: Record<LevelKind, ReactNode> = {
  foundation: "School",
  diploma: "School",
  undergraduate: "School",
  postgraduate: "Undergraduate degree",
  mba: "Undergraduate degree",
  pgdm: "Undergraduate degree",
  phd: "Postgraduate degree",
  other: <Ph>ENTRY</Ph>,
};

function requirements(kind: LevelKind): ReactNode[] {
  const ielts = (
    <>
      English test - IELTS <Ph>SCORE</Ph> or equivalent
    </>
  );
  if (kind === "undergraduate" || kind === "foundation" || kind === "diploma")
    return ["Secondary school certificate with the required grades", ielts, "Personal statement", "Reference letter from a teacher", "SAT/ACT for some US universities"];
  if (kind === "postgraduate")
    return [
      "Undergraduate degree in a related subject (some programmes accept career changers)",
      <>
        Minimum grade - usually <Ph>GRADE</Ph> or equivalent
      </>,
      ielts,
      "Statement of purpose (SOP) and CV",
      "Two references; GRE/GMAT for some programmes",
    ];
  if (kind === "mba")
    return [
      "Undergraduate degree in any subject",
      "Work experience - most programmes expect a few years (some accept less)",
      "GMAT or GRE score for many programmes (some waive it)",
      ielts,
      "Essays, CV, references and often an interview",
    ];
  if (kind === "pgdm")
    return [
      "Undergraduate degree in any subject",
      "Entrance test such as CAT, XAT or GMAT - varies by institute",
      "Group discussion and personal interview at many institutes",
      ielts,
      "Statement of purpose and CV",
    ];
  if (kind === "phd")
    return [
      "Postgraduate degree (or an outstanding undergraduate degree in some countries)",
      "Research proposal",
      "A supervisor who agrees to take you on",
      ielts,
      "Academic references and writing sample",
    ];
  return ["Previous qualification at the right level", ielts, "Personal statement"];
}

export default function LevelPageView({
  crumbs,
  fieldName,
  level,
  iconKey,
  lead,
  sections = {},
  specializations = [],
  subjectSlug,
  specSlug,
  allLevels = [],
}: {
  crumbs: { label: string; href?: string }[]; // full trail, ending with the level
  fieldName: string; // e.g. "Data Science"
  level: StudyLevel;
  iconKey: string | null; // the subject's icon, shown next to the title
  lead: LeadContext;
  sections?: LevelPageSections; // CMS blocks (subject_sections rows for this subject + level)
  specializations?: Specialization[]; // subject-level page only: linked as "<specialization> + this level"
  subjectSlug?: string;
  specSlug?: string; // specialization-level page only: enables the "levels to study" block
  allLevels?: StudyLevel[]; // the subject's levels, linked as "<this specialization> + that level"
}) {
  const kind = levelKindOf(level);
  const duration = level.duration ?? undefined;
  const lvl = inlineLevel(level.name);

  const about = sections.about?.body ? sections.about : null;
  const why = sections.why?.body ? sections.why : null;
  const industries = sections.industries ?? [];
  const companies = sections.companies ?? [];
  const courses = sections.courses ?? [];
  const destinations = sections.destinations ?? [];
  const universities = sections.universities ?? [];
  const ad = sections.advertisement ?? null;
  const cta = sections.cta ?? null;
  const hasSpecs = !!subjectSlug && specializations.length > 0;
  const otherLevels = specSlug ? allLevels.filter((l) => l.slug !== level.slug) : [];
  const hasProgrammes = courses.length > 0 || universities.length > 0;

  return (
    <main>
      <DetailHero
        crumbs={crumbs}
        tile={<SubjectIcon name={iconKey} size="lg" />}
        title={
          <>
            Study {level.name} in <span className="hl">{fieldName}</span> abroad
          </>
        }
        lead={`Compare ${level.name} programmes in ${fieldName} across countries - entry requirements, costs, intakes and scholarships in one place.`}
        actions={
          <>
            <SaveButton />
            <a className="btn btn-dark" href="#advice">
              Talk to an expert
            </a>
          </>
        }
        facts={[
          { icon: Clock, label: "Duration", value: duration ?? <Ph>DURATION</Ph> },
          { icon: GraduationCap, label: "Entry", value: entryLabel[kind] },
          {
            icon: FileCheck,
            label: "English test",
            value: (
              <>
                IELTS <Ph>SCORE</Ph>+
              </>
            ),
          },
          {
            icon: Wallet,
            label: "Universities",
            value: (
              <>
                <Ph>NUMBER</Ph>
              </>
            ),
          },
          { icon: Calendar, label: "Main intakes", value: "Sep · Jan" },
        ]}
      />
      <SubNav
        items={[
          { id: "overview", label: "Overview", show: true },
          { id: "specializations", label: "Specializations", show: hasSpecs },
          { id: "why", label: "Why this level", show: !!why },
          { id: "industries", label: "Industries", show: industries.length > 0 },
          { id: "companies", label: "Companies", show: companies.length > 0 },
          { id: "levels", label: "Other levels", show: otherLevels.length > 0 },
          { id: "courses", label: "Courses", show: courses.length > 0 },
          { id: "destinations", label: "Where to study", show: destinations.length > 0 },
          { id: "universities", label: "Universities", show: universities.length > 0 },
          { id: "programmes", label: "Programmes", show: !hasProgrammes },
          { id: "requirements", label: "Entry requirements", show: true },
          { id: "costs", label: "Costs", show: true },
          { id: "scholarships", label: "Scholarships", show: true },
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
                    <p>
                      {level.name} study in {fieldName}
                      {duration ? ` usually takes ${duration}.` : "."} {plainText(level.description)}
                    </p>
                    <p className="muted">
                      Below are programmes listed on Universta, what you need to apply, what it costs in each country and the
                      scholarships open to {lvl} students.
                    </p>
                  </>
                )}
              </div>
            </Section>

            {hasSpecs && (
              <Section id="specializations" title={`${level.name} specializations`} intro={`Pick a specialization to see ${lvl} options for it.`}>
                <div className="grid g-2">
                  {specializations.map((sp) => (
                    <Link className="card" href={`/subjects/${subjectSlug}/${sp.slug}/${level.slug}`} key={sp.id}>
                      <div className="row between">
                        <h3 className="card-title">
                          {sp.name} <span className="muted">· {level.name}</span>
                        </h3>
                        <ArrowRight className="ico" aria-hidden />
                      </div>
                      {sp.description && <p className="muted small mt-2">{plainText(sp.description)}</p>}
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
              <Section id="industries" title={`Popular industries for ${lvl} in ${fieldName}`}>
                <SectionCards items={industries} />
              </Section>
            )}

            {companies.length > 0 && (
              <Section id="companies" title={`Popular companies for ${lvl} in ${fieldName}`}>
                <SectionCards items={companies} />
              </Section>
            )}

            {otherLevels.length > 0 && (
              <Section id="levels" title={`Other levels to study ${fieldName}`} intro="Compare this with the other study levels.">
                <div className="grid g-3">
                  {otherLevels.map((l) => (
                    <Link className="card" href={`/subjects/${subjectSlug}/${specSlug}/${l.slug}`} key={l.id}>
                      {l.duration && <span className="tag">{l.duration}</span>}
                      <h3 className="card-title mt-4">
                        {l.name} in {fieldName}
                      </h3>
                      {l.description && <p className="muted small mt-2">{plainText(l.description)}</p>}
                      <span className="link-arrow mt-4">
                        See {l.name} options
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
              <Section id="courses" title={`Recommended ${lvl} courses in ${fieldName}`}>
                <SectionCards items={courses} linkLabel="View course" />
              </Section>
            )}

            {destinations.length > 0 && (
              <Section id="destinations" title={`Recommended destinations to study ${lvl} ${fieldName}`}>
                <SectionCards items={destinations} linkLabel="Learn more" />
              </Section>
            )}

            {universities.length > 0 && (
              <Section id="universities" title={`Recommended universities for ${lvl} in ${fieldName}`}>
                <SectionCards items={universities} linkLabel="Visit university" />
              </Section>
            )}

            {!hasProgrammes && (
              <Section id="programmes" title={`${level.name} programmes`} intro="Programmes listed on Universta appear here. Fees are per year unless stated.">
                <Note>No programmes listed yet for this field.</Note>
                <div className="mt-6">
                  <a className="btn btn-outline" href={hrefFor("courses")}>
                    See all {fieldName} programmes
                  </a>
                </div>
              </Section>
            )}

            <Section id="requirements" title="Entry requirements" intro="Typical requirements. Every university sets its own - always check the course page.">
              <Ticks items={requirements(kind)} />
              <div className="mt-6">
                <Note>
                  Explaining jargon: an <strong>SOP</strong> (statement of purpose) is a short essay on why you want this course.
                  Your SOP is your story, not a CV.
                </Note>
              </div>
            </Section>

            <Section id="costs" title="Costs by country" intro={`Yearly tuition and living costs for ${lvl} study in ${fieldName}.`}>
              <CostTable lastCol="duration" />
            </Section>

            <Section id="scholarships" title={`Scholarships for ${lvl} students`}>
              <Note>Scholarships for this level will appear here.</Note>
            </Section>

            <Section id="careers" title="Where it can take you">
              <div className="tags">
                {[1, 2, 3, 4].map((n) => (
                  <span key={n} className="tag tag-cloud" style={{ height: 34, fontSize: 14 }}>
                    <Briefcase className="ico ico-sm" aria-hidden />
                    <Ph>ROLE</Ph>
                  </span>
                ))}
              </div>
            </Section>

            <Section id="faq" title="Frequently asked questions">
              <Faq
                items={[
                  {
                    q: `How long does ${lvl} study in ${fieldName} take?`,
                    a: duration
                      ? `Usually ${duration}. Length can differ by country - in the UK many postgraduate degrees take one year; in the US and Canada they often take two.`
                      : "Length differs by country and university - check each programme page.",
                  },
                  {
                    q: "When should I apply?",
                    a: "Applications for the September intake usually open 9–12 months ahead. Start with a shortlist of five universities.",
                  },
                  {
                    q: "Can I get a scholarship?",
                    a: `Yes - government, university and private scholarships exist for ${lvl} students. Many close 6–12 months before the course starts.`,
                  },
                ]}
              />
            </Section>
          </>
        }
        aside={<AsideLead about={`${level.name} in ${fieldName}`} lead={lead} />}
      />
      <NextStepsBand
        items={[
          { icon: Landmark, title: "Compare universities", desc: "Fees, rankings, intakes", key: "universities" },
          { icon: FileCheck, title: "Book your test", desc: "Find the score you need", key: "exams" },
          { icon: Plane, title: "Student visa", desc: "Step-by-step guides", key: "student-visa" },
          { icon: Presentation, title: "Coaching", desc: "Prep for IELTS, GRE, GMAT", key: "coaching" },
        ]}
      />
    </main>
  );
}
