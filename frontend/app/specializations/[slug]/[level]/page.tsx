import { notFound, redirect } from "next/navigation";
import { getSpecialization } from "@/lib/api";

// Old address /specializations/<slug>/<level>: forwards to /subjects/<subject>/<specialization>/<level>.
export default async function OldSpecializationLevelRoute({ params }: { params: Promise<{ slug: string; level: string }> }) {
  const { slug, level } = await params;
  const spec = await getSpecialization(slug);
  if (!spec) notFound();
  redirect(`/subjects/${spec.subject_slug}/${spec.slug}/${level}`);
}
