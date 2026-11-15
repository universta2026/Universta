-- Directus rich-text (WYSIWYG) toolbar, one standard toolbar for EVERY field that uses it.
-- Writes only directus_fields.options -> "toolbar" key (other option keys are kept).
-- Safe to run more than once. Re-run it whenever a new WYSIWYG field is added.
-- Afterwards: docker compose restart directus   (Directus caches the schema)
--
-- Toolbar: undo/redo, bold/italic/underline/strikethrough, headings H1-H6, lists,
--          blockquote, line, link/unlink, clear formatting, cut/copy/paste, full screen.
-- Left out on purpose: font family, font size, alignment, colours, image, media, table, code.

UPDATE directus_fields
SET options = (
    COALESCE(options::jsonb, '{}'::jsonb)
    || '{"toolbar": ["undo","redo","bold","italic","underline","strikethrough","h1","h2","h3","h4","h5","h6","numlist","bullist","blockquote","hr","customLink","unlink","removeformat","cut","copy","paste","fullscreen"]}'::jsonb
)::json
WHERE interface = 'input-rich-text-html';
