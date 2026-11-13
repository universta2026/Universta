import { redirect } from "next/navigation";

// /subjects/engineering/international-students (no country) -> the page where the visitor picks a country.
export default async function InternationalStudentsIndex({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  redirect(`/subjects/${slug}/international-student`);
}
