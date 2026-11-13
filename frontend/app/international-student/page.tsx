import type { Metadata } from "next";
import Link from "next/link";
import { ArrowRight, Globe } from "lucide-react";
import SubjectIcon from "@/components/SubjectIcon";
import { Crumbs, CtaBand, Note, SecHead, withHighlight } from "@/components/ui";
import { getPageContent, getSubjects, text } from "@/lib/api";
import { internationalHref } from "@/lib/eligibility";

export const metadata: Metadata = { title: "Study abroad as an international student | Universta" };

// /international-student : choose a field first; each field page then asks for the home country.
export default async function InternationalStudentIndexPage() {
  const [subjects, content] = await Promise.all([getSubjects(), getPageContent("international-student")]);

  const copy = {
    title: text(content, "index", "title", "Study abroad as an {international student}"),
    intro: text(content, "index", "intro", "Choose a field, then tell us where you are from. We’ll show the countries and fields open to you."),
    eyebrow: text(content, "index", "eyebrow", "Choose a field"),
    listTitle: text(content, "index", "list_title", "What do you want to study?"),
    ctaTitle: text(content, "index", "cta_title", "Not sure where you qualify? {Ask an expert.}"),
    ctaText: text(content, "index", "cta_text", "Tell us your country and your grades. We’ll tell you where you can apply."),
  };

  return (
    <main>
      <section className="page-hero">
        <div className="shell">
          <Crumbs items={[{ label: "Home", href: "/" }, { label: "International students" }]} />
          <h1 className="t-h1 mt-6">{withHighlight(copy.title)}</h1>
          <p className="lead">{copy.intro}</p>
        </div>
      </section>

      <section className="section">
        <div className="shell">
          <SecHead eyebrow={copy.eyebrow} title={copy.listTitle} />
          {subjects.length === 0 ? (
            <Note>No subjects are available yet.</Note>
          ) : (
            <div className="grid g-3">
              {subjects.map((s) => (
                <div className="card" key={s.id}>
                  <SubjectIcon name={s.icon_key} />
                  <h3 className="card-title mt-4">
                    <Link className="stretched" href={internationalHref({ subject: s.slug })} style={{ color: "inherit" }}>
                      {s.name}
                    </Link>
                  </h3>
                  <span className="link-arrow mt-4">
                    <Globe className="ico" aria-hidden />
                    Study {s.name} from your country
                    <ArrowRight className="ico" aria-hidden />
                  </span>
                </div>
              ))}
            </div>
          )}
        </div>
      </section>

      <CtaBand
        title={withHighlight(copy.ctaTitle)}
        text={copy.ctaText}
        lead={{ subjects: subjects.map((s) => ({ name: s.name, specializations: s.specializations.map((x) => x.name) })) }}
      />
    </main>
  );
}
