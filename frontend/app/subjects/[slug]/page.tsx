import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { ChevronRight } from "lucide-react";
import SubjectIcon from "@/components/SubjectIcon";
import { getPageContent, getSubject, text } from "@/lib/api";

type Props = { params: Promise<{ slug: string }> };

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const subject = await getSubject(slug);
  return { title: subject ? `${subject.name} | Universta` : "Subject not found | Universta" };
}

export default async function SubjectDetailPage({ params }: Props) {
  const { slug } = await params;
  const [subject, content] = await Promise.all([
    getSubject(slug),
    getPageContent("subject-detail"), // editable headings, rows in Directus: page_key = "subject-detail"
  ]);
  if (!subject) notFound();

  const copy = {
    overviewTitle: text(content, "overview", "title", "Overview"),
    specsTitle: text(content, "specializations", "title", "Specializations"),
    specsIntro: text(
      content,
      "specializations",
      "intro",
      "Narrow your focus. Each specialization has its own modules, universities and career paths.",
    ),
    levelsTitle: text(content, "study_levels", "title", "Study levels"),
    levelsIntro: text(
      content,
      "study_levels",
      "intro",
      "Choose a level to see entry requirements, programmes and costs.",
    ),
  };

  const hasSpecs = subject.specializations.length > 0;
  const hasLevels = subject.study_levels.length > 0;

  const tabs = [
    { id: "overview", label: copy.overviewTitle, show: true },
    { id: "specializations", label: copy.specsTitle, show: hasSpecs },
    { id: "study-levels", label: copy.levelsTitle, show: hasLevels },
  ].filter((t) => t.show);

  return (
    <main>
      {/* Header */}
      <header className="mx-auto max-w-4xl px-4 pt-8">
        <nav className="text-xs text-slate-500">
          <Link href="/" className="hover:text-slate-900">Home</Link>
          <span className="mx-2">›</span>
          <Link href="/subjects" className="hover:text-slate-900">Subjects</Link>
          <span className="mx-2">›</span>
          <span className="text-slate-900">{subject.name}</span>
        </nav>

        <p className="mt-6 text-xs font-semibold tracking-widest text-blue-600">SUBJECT</p>
        <div className="mt-3 flex items-center gap-4">
          <SubjectIcon name={subject.icon_key} />
          <h1 className="text-3xl font-bold text-slate-900">{subject.name}</h1>
        </div>
        {subject.description && <p className="mt-3 text-slate-600">{subject.description}</p>}

        <div className="mt-6 grid grid-cols-2 gap-3 sm:max-w-md">
          <div className="rounded-xl border border-slate-200 p-4">
            <p className="text-xs text-slate-500">Levels</p>
            <p className="mt-1 text-sm font-semibold">{subject.study_levels.length} levels</p>
          </div>
          <div className="rounded-xl border border-slate-200 p-4">
            <p className="text-xs text-slate-500">Specializations</p>
            <p className="mt-1 text-sm font-semibold">{subject.specializations.length}</p>
          </div>
        </div>
      </header>

      {/* Section tabs (jump links) */}
      <nav className="sticky top-0 z-10 mt-8 border-b border-slate-200 bg-white/95 backdrop-blur">
        <ul className="mx-auto flex max-w-4xl gap-6 overflow-x-auto px-4 text-sm">
          {tabs.map((t) => (
            <li key={t.id}>
              <a
                href={`#${t.id}`}
                className="block whitespace-nowrap border-b-2 border-transparent py-3 text-slate-600 hover:border-blue-600 hover:text-slate-900"
              >
                {t.label}
              </a>
            </li>
          ))}
        </ul>
      </nav>

      <div className="mx-auto max-w-4xl space-y-12 px-4 py-10">
        {/* Overview */}
        <section id="overview" className="scroll-mt-16">
          <h2 className="text-xl font-bold">{copy.overviewTitle}</h2>
          <p className="mt-3 text-slate-700">
            {subject.description ?? `Explore studying ${subject.name} abroad.`}
          </p>
        </section>

        {/* Specializations */}
        {hasSpecs && (
          <section id="specializations" className="scroll-mt-16 border-t border-slate-200 pt-10">
            <h2 className="text-xl font-bold">{copy.specsTitle}</h2>
            <p className="mt-2 text-sm text-slate-600">{copy.specsIntro}</p>
            <ul className="mt-5 grid gap-4 sm:grid-cols-2">
              {subject.specializations.map((sp) => (
                <li key={sp.id}>
                  <Link
                    href={`/specializations/${sp.slug}`}
                    className="flex h-full items-start justify-between gap-3 rounded-xl border border-slate-200 p-4 transition hover:border-blue-300"
                  >
                    <div>
                      <h3 className="font-semibold text-slate-900">{sp.name}</h3>
                      {sp.description && (
                        <p className="mt-1 text-sm text-slate-600">{sp.description}</p>
                      )}
                    </div>
                    <ChevronRight size={18} className="mt-1 shrink-0 text-slate-400" />
                  </Link>
                </li>
              ))}
            </ul>
          </section>
        )}

        {/* Study levels */}
        {hasLevels && (
          <section id="study-levels" className="scroll-mt-16 border-t border-slate-200 pt-10">
            <h2 className="text-xl font-bold">{copy.levelsTitle}</h2>
            <p className="mt-2 text-sm text-slate-600">{copy.levelsIntro}</p>
            <ul className="mt-5 grid gap-4 sm:grid-cols-3">
              {subject.study_levels.map((lvl) => (
                <li key={lvl.id} className="rounded-xl border border-slate-200 p-4">
                  {lvl.duration && (
                    <p className="text-xs font-semibold text-amber-600">{lvl.duration}</p>
                  )}
                  <h3 className="mt-1 font-semibold text-slate-900">
                    {lvl.name} in {subject.name}
                  </h3>
                  {lvl.description && (
                    <p className="mt-2 text-sm text-slate-600">{lvl.description}</p>
                  )}
                </li>
              ))}
            </ul>
          </section>
        )}
      </div>
    </main>
  );
}
