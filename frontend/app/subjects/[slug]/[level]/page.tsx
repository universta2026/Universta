import type { Metadata } from "next";
import { notFound } from "next/navigation";
import LevelPageView from "@/components/LevelPageView";
import { getSubject } from "@/lib/api";

type Props = { params: Promise<{ slug: string; level: string }> };

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug, level } = await params;
  const subject = await getSubject(slug);
  const lvl = subject?.study_levels.find((l) => l.slug === level);
  return { title: subject && lvl ? `${lvl.name} in ${subject.name} | Universta` : "Page not found | Universta" };
}

// Study-level page for a subject, e.g. /subjects/computer-science/masters.
// Uses only the existing getSubject() data (study_levels), no new API calls.
export default async function SubjectLevelPage({ params }: Props) {
  const { slug, level } = await params;
  const subject = await getSubject(slug);
  const lvl = subject?.study_levels.find((l) => l.slug === level);
  if (!subject || !lvl) notFound();

  return (
    <LevelPageView
      crumbs={[
        { label: "Home", href: "/" },
        { label: "Subjects", href: "/subjects" },
        { label: subject.name, href: `/subjects/${subject.slug}` },
        { label: lvl.name },
      ]}
      fieldName={subject.name}
      level={lvl}
      otherLevels={subject.study_levels
        .filter((l) => l.id !== lvl.id)
        .map((l) => ({ label: `${l.name} in ${subject.name}`, href: `/subjects/${subject.slug}/${l.slug}` }))}
      overview={{ label: `${subject.name} overview`, href: `/subjects/${subject.slug}` }}
    />
  );
}
