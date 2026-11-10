import { notFound, redirect } from "next/navigation";
import { getSpecialization } from "@/lib/api";

// Old address /specializations/<slug>: forwards to /subjects/<subject>/<specialization>.
export default async function OldSpecializationRoute({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const spec = await getSpecialization(slug);
  if (!spec) notFound();
  redirect(`/subjects/${spec.subject_slug}/${spec.slug}`);
}
