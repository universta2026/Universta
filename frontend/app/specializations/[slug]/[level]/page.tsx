import type { Metadata } from "next";
import { notFound } from "next/navigation";
import LevelPageView from "@/components/LevelPageView";
import { getSpecialization, getSubject } from "@/lib/api";

type Props = { params: Promise<{ slug: string; level: string }> };

async function load(slug: string, level: string) {
  const spec = await getSpecialization(slug);
  if (!spec) return null;
  // Study levels belong to the parent subject in the API, so a specialization shows its subject's levels.
  const subject = await getSubject(spec.subject_slug);
  const lvl = subject?.study_levels.find((l) => l.slug === level);
  if (!subject || !lvl) return null;
  return { spec, subject, lvl };
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug, level } = await params;
  const data = await load(slug, level);
  return { title: data ? `${data.lvl.name} in ${data.spec.name} | Universta` : "Page not found | Universta" };
}

// Study-level page for a specialization, e.g. /specializations/data-science/masters.
export default async function SpecializationLevelPage({ params }: Props) {
  const { slug, level } = await params;
  const data = await load(slug, level);
  if (!data) notFound();
  const { spec, subject, lvl } = data;

  return (
    <LevelPageView
      crumbs={[
        { label: "Home", href: "/" },
        { label: "Subjects", href: "/subjects" },
        { label: spec.subject_name, href: `/subjects/${spec.subject_slug}` },
        { label: spec.name, href: `/specializations/${spec.slug}` },
        { label: lvl.name },
      ]}
      fieldName={spec.name}
      level={lvl}
      otherLevels={subject.study_levels
        .filter((l) => l.id !== lvl.id)
        .map((l) => ({ label: `${l.name} in ${spec.name}`, href: `/specializations/${spec.slug}/${l.slug}` }))}
      overview={{ label: `${spec.name} overview`, href: `/specializations/${spec.slug}` }}
    />
  );
}
