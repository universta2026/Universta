"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { ArrowRight, Globe } from "lucide-react";
import { fill, HOME_STORAGE_KEY, internationalHref } from "@/lib/eligibility";
import { withHighlight } from "./ui";

export type HomeCardCopy = {
  title: string; // "Study {field} from {country}"
  titleGeneric: string; // "Study {field} as an international student"
  text: string; // "... {country} ..."
  textGeneric: string;
  link: string;
};

// "Study engineering from India" block above the enquiry form on subject, specialization and level pages.
// The home country is the one the visitor chose on the international-student page (kept in this browser only).
// Until they choose, it links to the generic "international student" page. All text and countries come from the API.
export default function HomeCountryCard({
  copy,
  field,
  subject,
  spec,
  level,
  countries,
}: {
  copy: HomeCardCopy;
  field: string; // e.g. "Engineering"
  subject: string; // subject slug
  spec?: string;
  level?: string;
  countries: { name: string; slug: string }[]; // published countries from the API
}) {
  const [home, setHome] = useState<{ slug: string; name: string } | null>(null);

  useEffect(() => {
    try {
      const v = JSON.parse(localStorage.getItem(HOME_STORAGE_KEY) ?? "null");
      const match = countries.find((c) => c.slug === v?.slug); // only trust a country the API still knows
      if (match) setHome({ slug: match.slug, name: match.name });
    } catch {
      /* storage blocked: show the generic version */
    }
  }, [countries]);

  const title = home ? fill(copy.title, { field, country: `{${home.name}}` }) : fill(copy.titleGeneric, { field });
  const text = home ? fill(copy.text, { field, country: home.name }) : fill(copy.textGeneric, { field });

  return (
    <div className="card home-card">
      <span className="ico-tile">
        <Globe className="ico" aria-hidden />
      </span>
      <h3 className="t-h4 mt-4">{withHighlight(title)}</h3>
      <p className="muted small mt-2">{text}</p>
      <Link className="link-arrow mt-4" href={internationalHref({ subject, from: home?.slug, spec, level })}>
        {copy.link}
        <ArrowRight className="ico" aria-hidden />
      </Link>
    </div>
  );
}
