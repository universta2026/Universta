import { notFound, redirect } from "next/navigation";
import { getSpecialization } from "@/lib/api";

// Old address /specializations/<slug>: forwards to /subjects/<subject>/<specialization>.
export default async function OldSpecializationRoute({
  params,
  searchParams,
}: {
  params: Promise<{ slug: string }>;
  searchParams: Promise<{ from?: string | string[] }>;
}) {
  const { slug } = await params;
  const spec = await getSpecialization(slug);
  if (!spec) notFound();
  // Keep ?from=<country> so the new page can say "in <country>".
  const fromRaw = (await searchParams).from;
  const from = Array.isArray(fromRaw) ? fromRaw[0] : fromRaw;
  redirect(`/subjects/${spec.subject_slug}/${spec.slug}${from ? `?from=${encodeURIComponent(from)}` : ""}`);
}
