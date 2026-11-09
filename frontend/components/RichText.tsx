// Renders HTML written in the Directus rich-text editor (WYSIWYG) safely.
// The HTML is sanitized on the server first: only the tags below survive, scripts, styles,
// event handlers and unknown link types are removed. Never use dangerouslySetInnerHTML
// with CMS content anywhere else without going through this component.
import sanitizeHtml from "sanitize-html";

const OPTIONS: sanitizeHtml.IOptions = {
  allowedTags: ["p", "br", "strong", "b", "em", "i", "u", "s", "ul", "ol", "li", "h2", "h3", "h4", "a", "blockquote", "hr"],
  allowedAttributes: { a: ["href", "title", "target", "rel"] },
  allowedSchemes: ["http", "https", "mailto", "tel"],
  allowProtocolRelative: false,
  transformTags: {
    // The page section already uses <h2>, so editor headings are shown one level lower.
    h2: "h3",
    h3: "h4",
    a: sanitizeHtml.simpleTransform("a", { rel: "noopener noreferrer", target: "_blank" }),
  },
};

export default function RichText({ html }: { html: string | null | undefined }) {
  if (!html) return null;
  const clean = sanitizeHtml(html, OPTIONS).trim();
  if (!clean) return null;
  return <div className="rich-text" dangerouslySetInnerHTML={{ __html: clean }} />;
}
