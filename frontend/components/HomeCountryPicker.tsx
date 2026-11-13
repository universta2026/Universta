"use client";

import { useId, useMemo, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { Search } from "lucide-react";
import { HOME_STORAGE_KEY, fill, internationalHref } from "@/lib/eligibility";

// "Search your home country to study {focus} abroad". Type to filter the countries, pick one to open that
// country's page for this subject. The choice is remembered in this browser (so subject pages can say "from India").
export default function HomeCountryPicker({
  subject,
  countries,
  current,
  spec,
  level,
  focus,
  placeholder,
}: {
  placeholder: string; // template, e.g. "Search your home country to study {focus} abroad"
  focus: string; // subject or specialization name shown in the placeholder
  subject: string;
  countries: { name: string; slug: string }[];
  current?: string;
  spec?: string;
  level?: string;
}) {
  const router = useRouter();
  const listId = useId();
  const box = useRef<HTMLDivElement>(null);
  const [query, setQuery] = useState("");
  const [open, setOpen] = useState(false);
  const [active, setActive] = useState(0);

  const matches = useMemo(() => {
    const q = query.trim().toLowerCase();
    const list = q ? countries.filter((c) => c.name.toLowerCase().includes(q)) : countries;
    // names that start with the query first
    return q ? [...list].sort((a, b) => Number(b.name.toLowerCase().startsWith(q)) - Number(a.name.toLowerCase().startsWith(q))) : list;
  }, [countries, query]);

  function choose(slug: string) {
    const c = countries.find((x) => x.slug === slug);
    if (!c) return;
    try {
      localStorage.setItem(HOME_STORAGE_KEY, JSON.stringify({ slug: c.slug, name: c.name }));
    } catch {
      /* storage blocked: the page still works */
    }
    setOpen(false);
    setQuery("");
    router.push(internationalHref({ subject, from: c.slug, spec, level }));
  }

  function onKeyDown(e: React.KeyboardEvent) {
    if (e.key === "ArrowDown") {
      e.preventDefault();
      setOpen(true);
      setActive((i) => Math.min(i + 1, matches.length - 1));
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      setActive((i) => Math.max(i - 1, 0));
    } else if (e.key === "Enter" && open && matches[active]) {
      e.preventDefault();
      choose(matches[active].slug);
    } else if (e.key === "Escape") {
      setOpen(false);
    }
  }

  const currentName = countries.find((c) => c.slug === current)?.name;

  return (
    <div
      ref={box}
      style={{ position: "relative" }}
      onBlur={(e) => {
        if (!box.current?.contains(e.relatedTarget as Node)) setOpen(false);
      }}
    >
      <div className="searchbar" role="search">
        <div className="input-icon">
          <Search className="ico" aria-hidden />
          <input
            className="input"
            type="search"
            autoComplete="off"
            role="combobox"
            aria-expanded={open}
            aria-controls={listId}
            aria-autocomplete="list"
            aria-label="Search your home country"
            placeholder={currentName ?? fill(placeholder, { focus })}
            value={query}
            onFocus={() => setOpen(true)}
            onChange={(e) => {
              setQuery(e.target.value);
              setActive(0);
              setOpen(true);
            }}
            onKeyDown={onKeyDown}
          />
        </div>
      </div>

      {open && (
        <ul
          id={listId}
          role="listbox"
          style={{
            position: "absolute",
            zIndex: 20,
            left: 0,
            right: 0,
            top: "calc(100% + 6px)",
            maxHeight: 280,
            overflowY: "auto",
            margin: 0,
            padding: 6,
            listStyle: "none",
            background: "var(--white)",
            border: "1px solid var(--line)",
            borderRadius: 12,
            boxShadow: "var(--shadow-md)",
          }}
        >
          {matches.length === 0 ? (
            <li className="muted small" style={{ padding: "10px 12px" }}>
              No country matches “{query}”.
            </li>
          ) : (
            matches.map((c, i) => (
              <li
                key={c.slug}
                role="option"
                aria-selected={c.slug === current}
                tabIndex={-1}
                onMouseDown={(e) => e.preventDefault()} // keep focus so the click lands before blur closes the list
                onMouseEnter={() => setActive(i)}
                onClick={() => choose(c.slug)}
                style={{
                  padding: "10px 12px",
                  borderRadius: 8,
                  cursor: "pointer",
                  fontWeight: c.slug === current ? 700 : 500,
                  background: i === active ? "var(--cloud)" : undefined,
                }}
              >
                {c.name}
              </li>
            ))
          )}
        </ul>
      )}
    </div>
  );
}
