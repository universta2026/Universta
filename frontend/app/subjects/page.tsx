import SubjectsExplorer from "@/components/SubjectsExplorer";
import { getPageContent, getSubjects, text } from "@/lib/api";

// Server component: runs on the Next.js server, calls FastAPI, sends ready HTML to the browser.
export default async function SubjectsPage() {
  const [subjects, content] = await Promise.all([
    getSubjects(),
    getPageContent("subjects"), // rows in Directus: page_key = "subjects"
  ]);

  // Every text comes from Directus (page_content). The second value is the fallback.
  const copy = {
    eyebrow: text(content, "hero", "eyebrow", "SUBJECTS & SPECIALIZATIONS"),
    title: text(content, "hero", "title", "Find the field that fits you"),
    intro: text(
      content,
      "hero",
      "intro",
      "Explore {count} major fields and dozens of specializations. Every subject guide shows careers, typical modules, top universities and how degrees differ by study level.",
    ).replace("{count}", String(subjects.length)),
    searchPlaceholder: text(content, "search", "placeholder", "Search subjects or specializations..."),
    searchButton: text(content, "search", "button", "Search"),
    filtersTitle: text(content, "filters", "title", "Filters"),
    emptyMessage: text(
      content,
      "list",
      "empty_message",
      "No subjects match your search. Try a different word or clear the filters.",
    ),
  };

  return <SubjectsExplorer subjects={subjects} copy={copy} />;
}
