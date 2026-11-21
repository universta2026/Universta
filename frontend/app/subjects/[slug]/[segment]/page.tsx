import type { Metadata } from "next";
import { notFound } from "next/navigation";
import LevelPageView from "@/components/LevelPageView";
import SpecializationView from "@/components/SpecializationView";
import { getLevelSections, getSpecializationSections, getSubject, getSubjects } from "@/lib/api";
import { getPlace, withFrom, type SearchParams } from "@/lib/place";
import { getLevels } from "@/lib/levels";

type Props = { params: Promise<{ slug: string; segment: string }>; searchParams: SearchParams };

// /subjects/engineering/civil-engineering   -> a specialization of that subject
// /subjects/engineering/bachelors           -> a study level of that subject
// Both have the same URL shape, so the last part is looked up in the subject's own data.
// If a specialization and a level ever share a slug, the specialization wins.
async function load(slug: string, segment: string) {
  const subject = await getSubject(slug);
  if (!subject) return null;
  const levels = getLevels(subject.study_levels);
  const spec = subject.specializations.find((s) => s.slug === segment);
  const level = spec ? undefined : levels.find((l) => l.slug === segment);
  if (!spec && !level) return null;
  return { subject, levels, spec, level };
}

export async function generateMetadata({ params, searchParams }: Props): Promise<Metadata> {
  const { slug, segment } = await params;
  const [data, place] = await Promise.all([load(slug, segment), getPlace(searchParams)]);
  if (!data) return { title: "Page not found | Universta" };
  const where = place ? `in ${place.name}` : "abroad";
  if (data.spec) return { title: `Study ${data.spec.name} ${where} | Universta` };
  return { title: `Study ${data.level!.name} in ${data.subject.name} ${where} | Universta` };
}

export default async function SubjectSegmentPage({ params, searchParams }: Props) {
  const { slug, segment } = await params;
  // ?from=<country-slug> is set by links on a country page; the text then says "in <country>" instead of "abroad".
  const place = await getPlace(searchParams);
  const data = await load(slug, segment);
  if (!data) notFound();
  const { subject, levels, spec, level } = data;
  const subjectNames = (await getSubjects().catch(() => [])).map((s) => ({ name: s.name, specializations: s.specializations.map((x) => x.name) })); // for the form dropdown

  if (spec) {
    // CMS blocks for this specialization (rows of subject_sections that have a specialization)
    const specSections = await getSpecializationSections(subject.slug, spec.slug);
    return (
      <SpecializationView
        sections={specSections}
        subject={subject}
        spec={spec}
        place={place}
        levels={levels}
        lead={{ subjects: subjectNames, subject: subject.name, specialization: spec.name }}
      />
    );
  }

  // CMS blocks for this subject + level (rows of subject_sections that have a study level)
  const sections = await getLevelSections(subject.slug, level!.slug);

  return (
    <LevelPageView
      sections={sections}
      specializations={subject.specializations}
      subjectSlug={subject.slug}
      crumbs={[
        { label: "Home", href: "/" },
        { label: "Subjects", href: "/subjects" },
        { label: subject.name, href: withFrom(`/subjects/${subject.slug}`, place?.slug) },
        { label: level!.name },
      ]}
      place={place}
      fieldName={subject.name}
      level={level!}
      iconKey={subject.icon_key}
      lead={{ subjects: subjectNames, subject: subject.name, level: level!.name }}
    />
  );
}
