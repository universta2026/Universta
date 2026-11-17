import InternationalCountryView, { internationalCountryMetadata } from "@/components/InternationalCountryView";

type Props = { params: Promise<{ slug: string; segment: string; level: string; country: string }> };

// /subjects/engineering/civil-engineering/bachelors/international-student/india
export const generateMetadata = async ({ params }: Props) => {
  const { segment, ...p } = await params;
  return internationalCountryMetadata({ ...p, spec: segment });
};
export default async function Page({ params }: Props) {
  const { segment, ...p } = await params;
  return <InternationalCountryView {...p} spec={segment} />;
}
