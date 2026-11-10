import Link from "next/link";
import { Landmark } from "lucide-react";
import SubjectsExplorer from "@/components/SubjectsExplorer";
import { CtaBand, Ph, SecHead, withHighlight } from "@/components/ui";
import { LEVEL_GUIDE } from "@/components/site-config";
import { getPageContent, getSubjects, text } from "@/lib/api";

// Server component: runs on the Next.js server, calls FastAPI, sends ready HTML to the browser.
export default async function SubjectsPage() {
  const [subjects, content] = await Promise.all([
    getSubjects(),
    getPageContent("subjects"), // rows in Directus: page_key = "subjects"
  ]);

  // Every text comes from Directus (page_content). The last value is the fallback.
  // In a title, a word wrapped in { } becomes the blue highlight block.
  const copy = {
    title: text(content, "hero", "title", "Start with what you {love} to learn"),
    intro: text(
      content,
      "hero",
      "intro",
      "Pick a subject to see its specializations, study levels, top universities and the careers it leads to.",
    ).replace("{count}", String(subjects.length)),
    searchPlaceholder: text(content, "search", "placeholder", "Search a subject or specialization"),
    searchButton: text(content, "search", "button", "Search"),
    emptyMessage: text(
      content,
      "list",
      "empty_message",
      "No subjects match your search. Try a different word or clear the filters.",
    ),
    allEyebrow: text(content, "list", "eyebrow", "All subjects"),
    allTitle: text(content, "list", "title", "{subjects} subjects, {specializations} specializations"),
    allIntro: text(
      content,
      "list",
      "intro",
      "Each subject page shows study levels, universities, costs by country and careers.",
    ),
    popularEyebrow: text(content, "popular", "eyebrow", "Popular specializations"),
    popularTitle: text(content, "popular", "title", "What students are exploring"),
    levelsEyebrow: text(content, "levels", "eyebrow", "Study levels"),
    levelsTitle: text(content, "levels", "title", "Not sure which level fits?"),
    levelsIntro: text(
      content,
      "levels",
      "intro",
      "Every subject can be studied at several levels. Here is what each one means.",
    ),
    ctaTitle: text(content, "cta", "title", "Can’t decide on a subject? {Let’s talk.}"),
    ctaText: text(
      content,
      "cta",
      "text",
      "Tell us what you enjoy and where you want to go. We’ll suggest subjects and courses that fit — and explain the career paths.",
    ),
  };

  // "Popular" = specializations marked is_featured in Directus.
  const featured = subjects.flatMap((s) =>
    s.specializations.filter((sp) => sp.is_featured).map((sp) => ({ ...sp, subjectName: s.name, subjectSlug: s.slug })),
  );

  return (
    <main>
      <SubjectsExplorer
        subjects={subjects}
        copy={copy}
        quickLinks={featured.slice(0, 5).map((f) => ({ name: f.name, slug: f.slug, subjectSlug: f.subjectSlug }))}
      />

      {featured.length > 0 && (
        <section className="section bg-cloud">
          <div className="shell">
            <SecHead eyebrow={copy.popularEyebrow} title={copy.popularTitle} />
            <div className="grid g-4">
              {featured.slice(0, 8).map((f) => (
                <Link className="card" href={`/subjects/${f.subjectSlug}/${f.slug}`} key={f.id}>
                  <span className="caption">{f.subjectName}</span>
                  <h3 className="card-title mt-2">{f.name}</h3>
                  <div className="card-meta mt-4">
                    <span>
                      <Landmark className="ico" aria-hidden />
                      <Ph>N</Ph> universities
                    </span>
                  </div>
                </Link>
              ))}
            </div>
          </div>
        </section>
      )}

      <section className="section">
        <div className="shell">
          <SecHead eyebrow={copy.levelsEyebrow} title={copy.levelsTitle} intro={copy.levelsIntro} />
          <div className="grid g-4">
            {LEVEL_GUIDE.map((l) => (
              <div className="card" key={l.name}>
                <span className="tag">{l.duration}</span>
                <h3 className="card-title mt-4">{l.name}</h3>
                <p className="muted small mt-2">{l.blurb}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <CtaBand title={withHighlight(copy.ctaTitle)} text={copy.ctaText} lead={{ subjects: subjects.map((s) => s.name) }} />
    </main>
  );
}
