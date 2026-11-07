import sanitizeHtml from "sanitize-html";

// Shows HTML written in the Directus rich text editor.
// It is cleaned first, so scripts and unsafe tags can never reach the page.
const OPTIONS: sanitizeHtml.IOptions = {
  allowedTags: ["p", "br", "strong", "b", "em", "i", "u", "s", "ul", "ol", "li", "h2", "h3", "h4", "a", "blockquote", "hr"],
  allowedAttributes: { a: ["href", "target", "rel"] },
  allowedSchemes: ["http", "https", "mailto", "tel"],
  transformTags: {
    h1: "h2",
    a: sanitizeHtml.simpleTransform("a", { rel: "noopener noreferrer", target: "_blank" }),
  },
};

export default function RichText({ html, className = "" }: { html: string; className?: string }) {
  const clean = sanitizeHtml(html, OPTIONS);
  if (!clean.trim()) return null;
  return <div className={`rich-text ${className}`} dangerouslySetInnerHTML={{ __html: clean }} />;
}
