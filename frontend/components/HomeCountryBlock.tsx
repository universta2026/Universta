// Server wrapper: loads the editable text and the country list from the API, then renders the card.
// Put it above <AsideLead/> on every subject / specialization / level page.
import { getCountries, getPageContent, text } from "@/lib/api";
import HomeCountryCard from "./HomeCountryCard";

export default async function HomeCountryBlock({
  field,
  subject,
  spec,
  level,
}: {
  field: string;
  subject: string;
  spec?: string;
  level?: string;
}) {
  const [content, countries] = await Promise.all([getPageContent("international-student"), getCountries()]);
  if (countries.length === 0) return null; // nothing to choose from yet

  const copy = {
    title: text(content, "card", "title", "Study {field} from {country}"),
    titleGeneric: text(content, "card", "title_generic", "Study {field} as an international student"),
    text: text(content, "card", "text", "See the countries and fields you can apply to as a student from {country}."),
    textGeneric: text(content, "card", "text_generic", "Tell us where you are from and see the countries and fields open to you."),
    link: text(content, "card", "link", "Check my eligibility"),
  };

  return (
    <HomeCountryCard
      copy={copy}
      field={field}
      subject={subject}
      spec={spec}
      level={level}
      countries={countries.map((c) => ({ name: c.name, slug: c.slug }))}
    />
  );
}
