"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import { Search } from "lucide-react";
import type { Subject } from "@/lib/api";
import { stripHtml } from "@/lib/html";
import SubjectIcon from "./SubjectIcon";
import { Crumbs, SecHead, withHighlight } from "./ui";
import { LEVEL_OPTIONS } from "./site-config";

export type SubjectsCopy = {
  eyebrow: string;
  title: string; // may contain {word} -> blue highlight block
  intro: string;
  searchPlaceholder: string;
  searchButton: string;
  emptyMessage: string;
  allEyebrow: string;
  allTitle: string; // {subjects} and {specializations} are replaced with the totals
  allIntro: string;
};

export type QuickLink = { name: string; slug: string };

// Subjects page: hero with search + the "All subjects" grid.
// Search filtering is the same as before (subject name, description or specialization name).
export default function SubjectsExplorer({
  subjects,
  copy,
  quickLinks,
}: {
  subjects: Subject[];
  copy: SubjectsCopy;
  quickLinks: QuickLink[];
}) {
  const [query, setQuery] = useState("");

  const visible = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return subjects;
    return subjects.filter(
      (s) =>
        s.name.toLowerCase().includes(q) ||
        (s.description ?? "").toLowerCase().includes(q) ||
        s.specializations.some((sp) => sp.name.toLowerCase().includes(q)),
    );
  }, [subjects, query]);

  const specCount = subjects.reduce((n, s) => n + s.specializations.length, 0);
  const allTitle = copy.allTitle
    .replace("{subjects}", String(subjects.length))
    .replace("{specializations}", String(specCount));

  return (
    <>
      {/* Hero */}
      <section className="page-hero">
        <div className="shell">
          <Crumbs items={[{ label: "Home", href: "/" }, { label: "Subjects" }]} />
          <div className="mt-8">
            <span className="eyebrow">{copy.eyebrow}</span>
          </div>
          <h1 className="t-h1 mt-2">{withHighlight(copy.title)}</h1>
          <p className="lead">{copy.intro}</p>

          <form className="searchbar" role="search" onSubmit={(e) => e.preventDefault()}>
            <div className="input-icon">
              <Search className="ico" aria-hidden />
              <input
                className="input"
                type="search"
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder={copy.searchPlaceholder}
                aria-label="Search"
              />
            </div>
            <span className="divider" />
            {/* Visual only for now: the subjects list API does not return study levels. */}
            <select className="select" aria-label="Level" defaultValue={LEVEL_OPTIONS[0]}>
              {LEVEL_OPTIONS.map((l) => (
                <option key={l}>{l}</option>
              ))}
            </select>
            <button className="btn btn-primary" type="submit">
              {copy.searchButton}
            </button>
          </form>

          {quickLinks.length > 0 && (
            <div className="quick-links">
              <span>Popular:</span>
              {quickLinks.map((q) => (
                <Link key={q.slug} href={`/specializations/${q.slug}`}>
                  {q.name}
                </Link>
              ))}
            </div>
          )}
        </div>
      </section>

      {/* All subjects */}
      <section className="section">
        <div className="shell">
          <SecHead eyebrow={copy.allEyebrow} title={allTitle} intro={copy.allIntro} />

          {visible.length === 0 ? (
            <div className="empty" style={{ display: "block" }}>
              {copy.emptyMessage}
            </div>
          ) : (
            <div className="grid g-2">
              {visible.map((s) => {
                const shown = s.specializations.slice(0, 6);
                const rest = s.specializations.length - shown.length;
                return (
                  <div className="card" key={s.id}>
                    <div className="row" style={{ alignItems: "flex-start", gap: 16 }}>
                      <SubjectIcon name={s.icon_key} />
                      <div style={{ flex: 1, minWidth: 0 }}>
                        <h3 className="card-title">
                          <Link className="stretched" href={`/subjects/${s.slug}`} style={{ color: "inherit" }}>
                            {s.name}
                          </Link>
                        </h3>
                        {s.description && <p className="muted small mt-2">{s.description}</p>}
                        {shown.length > 0 && (
                          <div className="tags mt-4 above">
                            {shown.map((sp) => (
                              <Link key={sp.id} className="tag tag-link" href={`/specializations/${sp.slug}`}>
                                {sp.name}
                              </Link>
                            ))}
                            {rest > 0 && <span className="tag tag-cloud">+{rest} more</span>}
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </section>
    </>
  );
}
