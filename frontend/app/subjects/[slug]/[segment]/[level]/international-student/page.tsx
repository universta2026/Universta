import InternationalLandingView, { internationalLandingMetadata } from "@/components/InternationalLandingView";

type Props = { params: Promise<{ slug: string; segment: string; level: string }> };

// /subjects/engineering/civil-engineering/bachelors/international-student
export const generateMetadata = async ({ params }: Props) => internationalLandingMetadata(await params);
export default async function Page({ params }: Props) {
  return <InternationalLandingView {...(await params)} />;
}
