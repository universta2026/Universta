import InternationalCountryView, { internationalCountryMetadata } from "@/components/InternationalCountryView";

type Props = { params: Promise<{ slug: string; country: string }> };

// /subjects/engineering/international-student/india
export const generateMetadata = async ({ params }: Props) => internationalCountryMetadata(await params);
export default async function Page({ params }: Props) {
  return <InternationalCountryView {...(await params)} />;
}
