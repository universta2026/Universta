import { notFound } from "next/navigation";
import InternationalCountryView, { internationalCountryMetadata } from "@/components/InternationalCountryView";
import { getSubject } from "@/lib/api";
import { getLevels } from "@/lib/levels";

type Props = { params: Promise<{ slug: string; segment: string; country: string }> };

// /subjects/engineering/civil-engineering/international-student/india  (a specialization)
// /subjects/engineering/bachelors/international-student/india          (a study level)
async function resolve({ slug, segment, country }: { slug: string; segment: string; country: string }) {
  const subject = await getSubject(slug);
  if (!subject) return null;
  if (subject.specializations.some((s) => s.slug === segment)) return { slug, country, spec: segment };
  if (getLevels(subject.study_levels).some((l) => l.slug === segment)) return { slug, country, level: segment };
  return null;
}

export const generateMetadata = async ({ params }: Props) => {
  const r = await resolve(await params);
  return internationalCountryMetadata(r ?? { ...(await params) });
};
export default async function Page({ params }: Props) {
  const r = await resolve(await params);
  if (!r) notFound();
  return <InternationalCountryView {...r} />;
}
