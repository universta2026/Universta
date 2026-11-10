// Renders HTML written in the Directus rich-text editor (WYSIWYG) safely.
// The HTML is sanitized on the server first: only the tags, attributes and CSS properties
// below survive. Scripts, event handlers, unknown link types and any other inline CSS are removed.
// Never use dangerouslySetInnerHTML with CMS content anywhere else without going through this component.
import sanitizeHtml from "sanitize-html";

// Editors may set text and background colours: allow only hex and rgb()/rgba() values.
const COLOR = [
  /^#[0-9a-f]{3,8}$/i,
  /^rgba?\(\s*\d{1,3}\s*,\s*\d{1,3}\s*,\s*\d{1,3}\s*(,\s*[\d.]+\s*)?\)$/i,
];

const OPTIONS: sanitizeHtml.IOptions = {
  allowedTags: [
    "p", "br", "span",
    "strong", "b", "em", "i", "u", "s", "sub", "sup",
    "ul", "ol", "li",
    "h2", "h3", "h4", "h5", "h6",
    "a", "blockquote", "hr",
    "table", "thead", "tbody", "tr", "th", "td",
  ],
  allowedAttributes: {
    a: ["href", "title", "target", "rel", "style"],
    td: ["colspan", "rowspan", "style"],
    th: ["colspan", "rowspan", "style"],
    "*": ["style"],
  },
  // Inline styles written by the editor (font, size, colour, alignment).
  // Only these properties with these value patterns are kept.
  allowedStyles: {
    "*": {
      "font-size": [/^\d+(\.\d+)?(px|rem|em|pt|%)$/],
      "font-family": [/^[\w\s,'"-]+$/],
      color: COLOR,
      "background-color": COLOR,
      "text-align": [/^(left|right|center|justify)$/],
      "text-decoration": [/^(underline|line-through|none)$/],
    },
  },
  allowedSchemes: ["http", "https", "mailto", "tel"],
  allowProtocolRelative: false,
  transformTags: {
    // The page hero already uses <h1> and each page section uses <h2>,
    // so every editor heading is shown one level lower (h1 -> h2, h2 -> h3 ... h5 -> h6).
    h1: "h2",
    h2: "h3",
    h3: "h4",
    h4: "h5",
    h5: "h6",
    // h6 stays h6 (there is no lower level).
    a: sanitizeHtml.simpleTransform("a", { rel: "noopener noreferrer", target: "_blank" }),
  },
};

export default function RichText({ html }: { html: string | null | undefined }) {
  if (!html) return null;
  const clean = sanitizeHtml(html, OPTIONS).trim();
  if (!clean) return null;
  return <div className="rich-text" dangerouslySetInnerHTML={{ __html: clean }} />;
}