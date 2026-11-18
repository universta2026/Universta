import InternationalLandingView, { internationalLandingMetadata } from "@/components/InternationalLandingView";

type Props = { params: Promise<{ slug: string }> };

// /subjects/engineering/international-student : pick your home country for this subject.
export const generateMetadata = async ({ params }: Props) => internationalLandingMetadata(await params);
export default async function Page({ params }: Props) {
  return <InternationalLandingView {...(await params)} />;
}
