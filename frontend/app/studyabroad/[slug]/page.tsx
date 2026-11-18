import StudyAbroadView, { studyAbroadMetadata } from "@/components/StudyAbroadView";

type Props = { params: Promise<{ slug: string }> };

// /studyabroad/europe  (a continent)   and   /studyabroad/germany  (a country)
export const generateMetadata = async ({ params }: Props) => studyAbroadMetadata((await params).slug);
export default async function Page({ params }: Props) {
  return <StudyAbroadView slug={(await params).slug} />;
}
