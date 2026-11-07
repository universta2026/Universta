"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import { Search } from "lucide-react";
import type { Subject } from "@/lib/api";
import { stripHtml } from "@/lib/html";
import SubjectIcon from "./SubjectIcon";

type Sort = "relevant" | "az" | "specs";

export type SubjectsCopy = {
  eyebrow: string;
  title: string;
  intro: string;
  searchPlaceholder: string;
  searchButton: string;
  filtersTitle: string;
  emptyMessage: string;
};

export default function SubjectsExplorer({
  subjects,
  copy,
}: {
  subjects: Subject[];
  copy: SubjectsCopy;
}) {
  const [query, setQuery] = useState("");
  const [selected, setSelected] = useState<string[]>([]);
  const [sort, setSort] = useState<Sort>("relevant");

  const visible = useMemo(() => {
    const q = query.trim().toLowerCase();

    const list = subjects.filter((s) => {
      if (selected.length > 0 && !selected.includes(s.id)) return false;
      if (!q) return true;
      return (
        s.name.toLowerCase().includes(q) ||
        stripHtml(s.description).toLowerCase().includes(q) ||
        s.specializations.some((sp) => sp.name.toLowerCase().includes(q))
      );
    });

    if (sort === "az") return [...list].sort((a, b) => a.name.localeCompare(b.name));
    if (sort === "specs")
      return [...list].sort((a, b) => b.specializations.length - a.specializations.length);
    return list; // "relevant" = the display_order set in Directus
  }, [subjects, query, selected, sort]);

  const toggle = (id: string) =>
    setSelected((prev) => (prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]));

  return (
    <>
      {/* Hero */}
      <section className="border-b border-slate-200 bg-slate-50">
        <div className="mx-auto max-w-6xl px-4 pb-14 pt-8">
          <nav className="text-xs text-slate-500">
            <Link href="/" className="hover:text-slate-900">Home</Link>
            <span className="mx-2">›</span>
            <span className="text-slate-900">Subjects</span>
          </nav>

          <p className="mt-10 text-xs font-semibold tracking-widest text-blue-600">{copy.eyebrow}</p>
          <h1 className="mt-3 text-4xl font-bold text-slate-900">{copy.title}</h1>
          <p className="mt-3 max-w-xl text-slate-600">{copy.intro}</p>

          <form
            onSubmit={(e) => e.preventDefault()}
            className="mt-8 flex max-w-3xl items-center rounded-xl border border-slate-200 bg-white p-2 shadow-sm"
          >
            <Search size={16} className="mx-3 shrink-0 text-slate-400" />
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder={copy.searchPlaceholder}
              className="min-w-0 flex-1 bg-transparent py-2 text-sm outline-none"
            />
            <button
              type="submit"
              className="ml-2 rounded-lg bg-blue-600 px-5 py-2 text-sm font-semibold text-white hover:bg-blue-700"
            >
              {copy.searchButton}
            </button>
          </form>
        </div>
      </section>

      {/* Filters + list */}
      <section className="mx-auto grid max-w-6xl gap-8 px-4 py-10 lg:grid-cols-[220px_1fr]">
        <aside className="h-fit rounded-xl border border-slate-200 bg-white">
          <div className="flex items-center justify-between border-b border-slate-200 px-4 py-3">
            <span className="text-sm font-semibold">{copy.filtersTitle}</span>
            <button onClick={() => setSelected([])} className="text-xs font-medium text-blue-600">
              Clear all
            </button>
          </div>
          <div className="px-4 py-4">
            <p className="mb-3 text-xs font-semibold text-slate-700">Field of study</p>
            <ul className="space-y-3">
              {subjects.map((s) => (
                <li key={s.id}>
                  <label className="flex cursor-pointer items-start gap-2 text-sm text-slate-700">
                    <input
                      type="checkbox"
                      checked={selected.includes(s.id)}
                      onChange={() => toggle(s.id)}
                      className="mt-0.5 h-4 w-4 rounded border-slate-300"
                    />
                    <span className="flex-1">{s.name}</span>
                    <span className="text-xs text-slate-400">{s.specializations.length}</span>
                  </label>
                </li>
              ))}
            </ul>
          </div>
        </aside>

        <div>
          <div className="mb-4 flex items-center justify-between">
            <p className="text-sm">
              <span className="font-semibold">{visible.length}</span> subjects
            </p>
            <select
              value={sort}
              onChange={(e) => setSort(e.target.value as Sort)}
              className="rounded-lg border border-slate-200 bg-white px-3 py-2 text-sm"
            >
              <option value="relevant">Sort: Most relevant</option>
              <option value="az">Sort: A to Z</option>
              <option value="specs">Sort: Most specializations</option>
            </select>
          </div>

          {visible.length === 0 ? (
            <div className="rounded-xl border border-dashed border-slate-300 p-10 text-center text-sm text-slate-500">
              {copy.emptyMessage}
            </div>
          ) : (
            <ul className="space-y-4">
              {visible.map((s) => (
                <li key={s.id}>
                  <Link
                    href={`/subjects/${s.slug}`}
                    className="flex gap-4 rounded-xl border border-slate-200 bg-white p-5 transition hover:border-blue-300"
                  >
                    <SubjectIcon name={s.icon_key} />
                    <div className="min-w-0">
                      <h2 className="font-semibold text-slate-900">{s.name}</h2>
                      {stripHtml(s.description) && (
                        <p className="mt-1 line-clamp-2 text-sm text-slate-600">
                          {stripHtml(s.description)}
                        </p>
                      )}
                      {s.specializations.length > 0 && (
                        <div className="mt-3 flex flex-wrap gap-2">
                          {s.specializations.slice(0, 4).map((sp) => (
                            <span
                              key={sp.id}
                              className="rounded-md bg-blue-50 px-2.5 py-1 text-xs font-medium text-blue-900"
                            >
                              {sp.name}
                            </span>
                          ))}
                          {s.specializations.length > 4 && (
                            <span className="px-1 py-1 text-xs text-slate-500">
                              +{s.specializations.length - 4} more
                            </span>
                          )}
                        </div>
                      )}
                    </div>
                  </Link>
                </li>
              ))}
            </ul>
          )}
        </div>
      </section>
    </>
  );
}
