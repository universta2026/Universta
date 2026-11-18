import InternationalLandingView, { internationalLandingMetadata } from "@/components/InternationalLandingView";

type Props = { params: Promise<{ slug: string; segment: string }> };

// /subjects/engineering/civil-engineering/international-student  (a specialization)
// /subjects/engineering/bachelors/international-student          (a study level)
export const generateMetadata = async ({ params }: Props) => internationalLandingMetadata(await params);
export default async function Page({ params }: Props) {
  return <InternationalLandingView {...(await params)} />;
}
