"use client";

import Link from "next/link";
import { CountryRow, ROW_STYLE } from "@/components/ContinentCards";

// Countries marked popular in the countries table. Same compact rows as the continent panel:
// 3 per row (1 on phones), so the flag can be added in CountryRow for both at once.
export default function PopularCountries({ countries }: { countries: { name: string; slug: string; href: string }[] }) {
  return (
    <ul className="grid g-3" style={{ gap: 10 }}>
      {countries.map((c) => (
        <li key={c.slug} style={{ minWidth: 0 }}>
          <Link className="card card-flat" href={c.href} style={ROW_STYLE}>
            <CountryRow name={c.name} arrow />
          </Link>
        </li>
      ))}
    </ul>
  );
}
