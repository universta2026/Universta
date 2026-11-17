import { redirect } from "next/navigation";
import { internationalHref } from "@/lib/eligibility";

// Old URL: /subjects/engineering/international-students/india[?spec=..&level=..]
export default async function Page({ params, searchParams }: { params: Promise<{ slug: string; country: string }>; searchParams: Promise<{ spec?: string; level?: string }> }) {
  const { slug, country } = await params;
  const { spec, level } = await searchParams;
  redirect(internationalHref({ subject: slug, from: country, spec, level }));
}
