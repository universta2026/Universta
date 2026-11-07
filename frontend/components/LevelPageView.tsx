// One study-level page (e.g. "Master’s in Data Science"), shared by
// /subjects/[slug]/[level] and /specializations/[slug]/[level].
import type { ReactNode } from "react";
import { Briefcase, Calendar, Clock, FileCheck, GraduationCap, Landmark, Plane, Presentation, Wallet } from "lucide-react";
import type { StudyLevel } from "@/lib/api";
import SaveButton from "./SaveButton";
import SubNav from "./SubNav";
import {
  AsideCard,
  AsideLead,
  AsideLinks,
  CostTable,
  DetailHero,
  DetailLayout,
  Faq,
  hrefFor,
  Kv,
  Note,
  NextStepsBand,
  Ph,
  Section,
  Ticks,
} from "./ui";

type Kind = "bachelor" | "master" | "phd" | "other";

function levelKind(level: StudyLevel): Kind {
  const s = `${level.slug} ${level.name}`.toLowerCase();
  if (/bachelor|undergrad/.test(s)) return "bachelor";
  if (/master|postgrad/.test(s)) return "master";
  if (/phd|doctor/.test(s)) return "phd";
  return "other";
}

const entryLabel: Record<Kind, ReactNode> = {
  bachelor: "School",
  master: "Bachelor’s",
  phd: "Master’s",
  other: <Ph>ENTRY</Ph>,
};

function requirements(kind: Kind): ReactNode[] {
  const ielts = (
    <>
      English test — IELTS <Ph>SCORE</Ph> or equivalent
    </>
  );
  if (kind === "bachelor")
    return ["Secondary school certificate with the required grades", ielts, "Personal statement", "Reference letter from a teacher", "SAT/ACT for some US universities"];
  if (kind === "master")
    return [
      "Bachelor’s degree in a related subject (some programmes accept career changers)",
      <>
        Minimum grade — usually <Ph>GRADE</Ph> or equivalent
      </>,
      ielts,
      "Statement of purpose (SOP) and CV",
      "Two references; GRE/GMAT for some programmes",
    ];
  if (kind === "phd")
    return [
      "Master’s degree (or an outstanding bachelor’s in some countries)",
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
  otherLevels,
  overview,
}: {
  crumbs: { label: string; href?: string }[]; // full trail, ending with the level
  fieldName: string; // e.g. "Data Science"
  level: StudyLevel;
  otherLevels: { label: string; href: string }[]; // links to the other levels + the overview page
  overview: { label: string; href: string };
}) {
  const kind = levelKind(level);
  const duration = level.duration ?? undefined;

  return (
    <main>
      <DetailHero
        crumbs={crumbs}
        eyebrow={`${level.name} · ${fieldName}`}
        title={
          <>
            {level.name} in <span className="hl">{fieldName}</span> abroad
          </>
        }
        lead={`Compare ${level.name} programmes in ${fieldName} across countries — entry requirements, costs, intakes and scholarships in one place.`}
        actions={<SaveButton />}
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
            label: "Tuition",
            value: (
              <>
                <Ph>FEE</Ph> / yr
              </>
            ),
          },
          { icon: Calendar, label: "Main intakes", value: "Sep · Jan" },
        ]}
      />
      <SubNav
        items={[
          { id: "overview", label: "Overview" },
          { id: "programmes", label: "Programmes" },
          { id: "requirements", label: "Entry requirements" },
          { id: "costs", label: "Costs" },
          { id: "scholarships", label: "Scholarships" },
          { id: "careers", label: "Careers" },
          { id: "faq", label: "FAQ" },
        ]}
      />
      <DetailLayout
        main={
          <>
            <Section id="overview" title="Overview">
              <div className="body-copy">
                <p>
                  {level.name} study in {fieldName}
                  {duration ? ` usually takes ${duration}.` : "."} {level.description ?? ""}
                </p>
                <p className="muted">
                  Below are programmes listed on Universta, what you need to apply, what it costs in each country and the
                  scholarships open to {level.name} students.
                </p>
              </div>
            </Section>

            <Section id="programmes" title={`${level.name} programmes`} intro="Programmes listed on Universta appear here. Fees are per year unless stated.">
              <Note>No programmes listed yet for this field.</Note>
              <div className="mt-6">
                <a className="btn btn-outline" href={hrefFor("courses")}>
                  See all {fieldName} programmes
                </a>
              </div>
            </Section>

            <Section id="requirements" title="Entry requirements" intro="Typical requirements. Every university sets its own — always check the course page.">
              <Ticks items={requirements(kind)} />
              <div className="mt-6">
                <Note>
                  Explaining jargon: an <strong>SOP</strong> (statement of purpose) is a short essay on why you want this course.
                  Your SOP is your story, not a CV.
                </Note>
              </div>
            </Section>

            <Section id="costs" title="Costs by country" intro={`Yearly tuition and living costs for a ${level.name} in ${fieldName}.`}>
              <CostTable lastCol="duration" />
            </Section>

            <Section id="scholarships" title={`Scholarships for ${level.name} students`}>
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

            <Section id="faq" title="Questions students ask">
              <Faq
                items={[
                  {
                    q: `How long is a ${level.name} in ${fieldName}?`,
                    a: duration
                      ? `Usually ${duration}. Length can differ by country — in the UK many master’s degrees take one year; in the US and Canada they often take two.`
                      : "Length differs by country and university — check each programme page.",
                  },
                  {
                    q: "When should I apply?",
                    a: "Applications for the September intake usually open 9–12 months ahead. Start with a shortlist of five universities.",
                  },
                  {
                    q: "Can I get a scholarship?",
                    a: `Yes — government, university and private scholarships exist for ${level.name} students. Many close 6–12 months before the course starts.`,
                  },
                ]}
              />
            </Section>
          </>
        }
        aside={
          <>
            <AsideLead about={`${level.name} in ${fieldName}`} />
            <AsideCard title="At a glance">
              <Kv
                rows={[
                  ["Duration", duration ?? <Ph key="d">DURATION</Ph>],
                  ["Entry", entryLabel[kind]],
                  [
                    "English",
                    <>
                      IELTS <Ph>SCORE</Ph>+
                    </>,
                  ],
                  [
                    "Tuition",
                    <>
                      <Ph>FEE</Ph> / yr
                    </>,
                  ],
                ]}
              />
            </AsideCard>
            <AsideLinks title="Other levels" links={[...otherLevels, overview]} />
          </>
        }
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
