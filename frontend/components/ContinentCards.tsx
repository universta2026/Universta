"use client";

import { useState } from "react";
import Link from "next/link";
import { ArrowRight, ChevronDown, Globe } from "lucide-react";
import { fill } from "@/lib/eligibility";

export type ContinentCard = {
  name: string;
  countries: { name: string; slug: string; href?: string }[]; // href set = the row is a link
};

export const ROW_STYLE: React.CSSProperties = {
  display: "flex",
  alignItems: "center",
  justifyContent: "space-between",
  gap: 12,
  height: "100%",
  padding: "12px 16px",
  color: "inherit",
};

export function CountryRow({ name, arrow }: { name: string; arrow?: boolean }) {
  return (
    <>
      <span className="row" style={{ gap: 12, minWidth: 0 }}>
        {/* flag goes here, e.g. <span style={{ fontSize: 22, lineHeight: 1 }}>🇮🇳</span> */}
        <span style={{ fontWeight: 600, overflowWrap: "anywhere" }}>{name}</span>
      </span>
      {arrow && <ArrowRight className="ico" aria-hidden style={{ flexShrink: 0 }} />}
    </>
  );
}

// One card per continent (name, "N countries", arrow). Clicking a card opens a panel UNDER the
// cards with the heading and the countries as full-width rows. One continent is open at a time.
export default function ContinentCards({
  continents,
  panelTitle, // e.g. "Study abroad countries in {continent} you are eligible for"
}: {
  continents: ContinentCard[];
  panelTitle: string;
}) {
  const [open, setOpen] = useState<string | null>(null);
  const active = continents.find((c) => c.name === open);

  return (
    <div>
      <div className="grid g-3">
        {continents.map((c) => {
          const isOpen = open === c.name;
          return (
            <button
              type="button"
              key={c.name}
              className="card"
              style={{
                textAlign: "left",
                cursor: "pointer",
                width: "100%",
                borderColor: isOpen ? "var(--blue)" : undefined,
                boxShadow: isOpen ? "var(--shadow-md)" : undefined,
              }}
              aria-expanded={isOpen}
              aria-controls="continent-panel"
              onClick={() => setOpen(isOpen ? null : c.name)}
            >
              <span className="row between" style={{ gap: 16 }}>
                <span className="row" style={{ gap: 16 }}>
                  <span className="ico-tile">
                    <Globe className="ico" aria-hidden />
                  </span>
                  <span>
                    <span className="card-title" style={{ display: "block" }}>
                      {c.name}
                    </span>
                    <span className="caption">
                      {c.countries.length} {c.countries.length === 1 ? "country" : "countries"}
                    </span>
                  </span>
                </span>
                <ChevronDown
                  className="ico"
                  aria-hidden
                  style={{ transition: "transform .2s", transform: isOpen ? "rotate(180deg)" : undefined }}
                />
              </span>
            </button>
          );
        })}
      </div>

      {active && (
        <div className="panel mt-6" id="continent-panel" role="region" aria-label={active.name}>
          <h3 className="t-h3">{fill(panelTitle, { continent: active.name })}</h3>
          {/* 3 countries per row (1 on phones). Each row is [flag slot][name]...[arrow]; the flag goes in the
              first <span> of CountryRow once it is added. */}
          <ul className="grid g-3 mt-4" style={{ gap: 10 }}>
            {active.countries.map((k) => (
              <li key={k.slug} style={{ minWidth: 0 }}>
                {k.href ? (
                  <Link className="card card-flat" href={k.href} style={ROW_STYLE}>
                    <CountryRow name={k.name} arrow />
                  </Link>
                ) : (
                  <div className="card card-flat" style={ROW_STYLE}>
                    <CountryRow name={k.name} />
                  </div>
                )}
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}
