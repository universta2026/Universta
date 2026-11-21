import StudyAbroadView, { studyAbroadMetadata } from "@/components/StudyAbroadView";

type Props = { params: Promise<{ slug: string }> };

// /study-abroad/europe  (a continent)   and   /study-abroad/germany  (a country)
export const generateMetadata = async ({ params }: Props) => studyAbroadMetadata((await params).slug);
export default async function Page({ params }: Props) {
  return <StudyAbroadView slug={(await params).slug} />;
}
