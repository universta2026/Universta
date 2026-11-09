import type { Metadata } from "next";
import { notFound } from "next/navigation";
import LevelPageView from "@/components/LevelPageView";
import { getSubject, getSubjects } from "@/lib/api";
import { getLevels } from "@/lib/levels";

type Props = { params: Promise<{ slug: string; segment: string; level: string }> };

// /subjects/engineering/civil-engineering/masters -> a study level of one specialization.
// Study levels belong to the subject in the API, so a specialization shows its subject's levels.
async function load(slug: string, segment: string, levelSlug: string) {
  const subject = await getSubject(slug);
  if (!subject) return null;
  const spec = subject.specializations.find((s) => s.slug === segment);
  const level = getLevels(subject.study_levels).find((l) => l.slug === levelSlug);
  if (!spec || !level) return null;
  return { subject, spec, level };
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug, segment, level } = await params;
  const data = await load(slug, segment, level);
  return { title: data ? `${data.level.name} in ${data.spec.name} | Universta` : "Page not found | Universta" };
}

export default async function SpecializationLevelPage({ params }: Props) {
  const { slug, segment, level } = await params;
  const data = await load(slug, segment, level);
  if (!data) notFound();
  const { subject, spec, level: lvl } = data;
  const subjectNames = (await getSubjects().catch(() => [])).map((s) => s.name); // for the form dropdown

  return (
    <LevelPageView
      crumbs={[
        { label: "Home", href: "/" },
        { label: "Subjects", href: "/subjects" },
        { label: subject.name, href: `/subjects/${subject.slug}` },
        { label: spec.name, href: `/subjects/${subject.slug}/${spec.slug}` },
        { label: lvl.name },
      ]}
      fieldName={spec.name}
      level={lvl}
      iconKey={subject.icon_key}
      lead={{ subjects: subjectNames, subject: subject.name, specialization: spec.name, level: lvl.name }}
    />
  );
}
