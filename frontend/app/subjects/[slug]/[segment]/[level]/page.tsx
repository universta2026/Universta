import type { Metadata } from "next";
import { notFound } from "next/navigation";
import LevelPageView from "@/components/LevelPageView";
import { getSpecializationLevelSections, getSubject, getSubjects } from "@/lib/api";
import { getLevels } from "@/lib/levels";
import { getPlace, withFrom, type SearchParams } from "@/lib/place";

type Props = { params: Promise<{ slug: string; segment: string; level: string }>; searchParams: SearchParams };

// /subjects/engineering/civil-engineering/masters -> a study level of one specialization.
// Study levels belong to the subject in the API, so a specialization shows its subject's levels.
async function load(slug: string, segment: string, levelSlug: string) {
  const subject = await getSubject(slug);
  if (!subject) return null;
  const spec = subject.specializations.find((s) => s.slug === segment);
  const level = getLevels(subject.study_levels).find((l) => l.slug === levelSlug);
  if (!spec || !level) return null;
  return { subject, spec, level, levels: getLevels(subject.study_levels) };
}

export async function generateMetadata({ params, searchParams }: Props): Promise<Metadata> {
  const { slug, segment, level } = await params;
  const [data, place] = await Promise.all([load(slug, segment, level), getPlace(searchParams)]);
  return { title: data ? `Study ${data.level.name} in ${data.spec.name} ${place ? `in ${place.name}` : "abroad"} | Universta` : "Page not found | Universta" };
}

export default async function SpecializationLevelPage({ params, searchParams }: Props) {
  const { slug, segment, level } = await params;
  const place = await getPlace(searchParams); // country the visitor came from, if any
  const data = await load(slug, segment, level);
  if (!data) notFound();
  const { subject, spec, level: lvl, levels } = data;
  const subjectNames = (await getSubjects().catch(() => [])).map((s) => ({ name: s.name, specializations: s.specializations.map((x) => x.name) })); // for the form dropdown

  const sections = await getSpecializationLevelSections(subject.slug, spec.slug, lvl.slug);

  return (
    <LevelPageView
      sections={sections}
      subjectSlug={subject.slug}
      specSlug={spec.slug}
      allLevels={levels}
      crumbs={[
        { label: "Home", href: "/" },
        { label: "Subjects", href: "/subjects" },
        { label: subject.name, href: withFrom(`/subjects/${subject.slug}`, place?.slug) },
        { label: spec.name, href: withFrom(`/subjects/${subject.slug}/${spec.slug}`, place?.slug) },
        { label: lvl.name },
      ]}
      place={place}
      fieldName={spec.name}
      level={lvl}
      iconKey={subject.icon_key}
      lead={{ subjects: subjectNames, subject: subject.name, specialization: spec.name, level: lvl.name }}
    />
  );
}
