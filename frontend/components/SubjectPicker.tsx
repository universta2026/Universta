"use client";

import { useEffect, useRef, useState } from "react";
import { Check, ChevronDown, ChevronRight, Search } from "lucide-react";

export type SubjectGroup = { name: string; specializations: string[] };

// Dropdown listing every subject; the small arrow beside a subject opens its specializations.
// `defaultValue` is a subject or specialization name and pre-selects it (and opens its subject).
export default function SubjectPicker({
  id,
  groups,
  defaultValue = "",
  name = "subject",
}: {
  id: string;
  groups: SubjectGroup[];
  defaultValue?: string;
  name?: string;
}) {
  const [value, setValue] = useState(defaultValue);
  const [open, setOpen] = useState(false);
  const [expanded, setExpanded] = useState<string | null>(
    () => groups.find((g) => g.specializations.includes(defaultValue))?.name ?? null,
  );
  const [query, setQuery] = useState("");
  const root = useRef<HTMLDivElement>(null);
  const searchRef = useRef<HTMLInputElement>(null);

  // While searching, keep a subject if it or any of its specializations match; show only the matching specializations
  // (all of them when the subject name itself matches).
  const q = query.trim().toLowerCase();
  const visible = groups
    .map((g) => {
      const subjectHit = g.name.toLowerCase().includes(q);
      const specs = !q || subjectHit ? g.specializations : g.specializations.filter((s) => s.toLowerCase().includes(q));
      return { ...g, specializations: specs, show: !q || subjectHit || specs.length > 0 };
    })
    .filter((g) => g.show);

  useEffect(() => {
    if (open) searchRef.current?.focus();
    else setQuery("");
  }, [open]);

  useEffect(() => {
    if (!open) return;
    const away = (e: MouseEvent) => {
      if (!root.current?.contains(e.target as Node)) setOpen(false);
    };
    const esc = (e: KeyboardEvent) => e.key === "Escape" && setOpen(false);
    document.addEventListener("mousedown", away);
    document.addEventListener("keydown", esc);
    return () => {
      document.removeEventListener("mousedown", away);
      document.removeEventListener("keydown", esc);
    };
  }, [open]);

  const pick = (v: string) => {
    setValue(v);
    setOpen(false);
  };

  return (
    <div className="subject-picker" ref={root}>
      <input type="hidden" name={name} value={value} />
      <button
        id={id}
        type="button"
        className="select subject-picker-btn"
        aria-haspopup="listbox"
        aria-expanded={open}
        onClick={() => setOpen((o) => !o)}
      >
        {value || "Select subject and specialization"}
      </button>
      {open && (
        <div className="subject-picker-panel">
          <div className="sp-search">
            <Search className="ico" aria-hidden />
            <input
              ref={searchRef}
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && e.preventDefault()}
              placeholder="Search subject or specialization"
              aria-label="Search subject or specialization"
              autoComplete="off"
            />
          </div>
        <ul className="subject-picker-list" role="listbox" aria-labelledby={id}>
          {visible.length === 0 && <li className="sp-empty">No matches found</li>}
          {visible.map((g) => {
            const isOpen = !!q || expanded === g.name;
            const hasSpecs = g.specializations.length > 0;
            return (
              <li key={g.name}>
                <div className="sp-row">
                  <button
                    type="button"
                    role="option"
                    aria-selected={value === g.name}
                    className="sp-item"
                    onClick={() => pick(g.name)}
                  >
                    {g.name}
                    {value === g.name && <Check className="ico" aria-hidden />}
                  </button>
                  {hasSpecs && (
                    <button
                      type="button"
                      className="sp-toggle"
                      aria-label={`${isOpen ? "Hide" : "Show"} ${g.name} specializations`}
                      aria-expanded={isOpen}
                      onClick={() => setExpanded(isOpen ? null : g.name)}
                    >
                      {isOpen ? <ChevronDown className="ico" aria-hidden /> : <ChevronRight className="ico" aria-hidden />}
                    </button>
                  )}
                </div>
                {hasSpecs && isOpen && (
                  <ul className="sp-sub">
                    {g.specializations.map((s) => (
                      <li key={s}>
                        <button
                          type="button"
                          role="option"
                          aria-selected={value === s}
                          className="sp-item"
                          onClick={() => pick(s)}
                        >
                          {s}
                          {value === s && <Check className="ico" aria-hidden />}
                        </button>
                      </li>
                    ))}
                  </ul>
                )}
              </li>
            );
          })}
        </ul>
        </div>
      )}
    </div>
  );
}
