-- Directus field settings (what editors see). Run once, then restart Directus.
-- Expected: first UPDATE -> up to 4 rows, second UPDATE -> 2 rows.

-- 1) Slug: not required in the form, typed text is cleaned live, hint shown under the field.
UPDATE directus_fields
SET required = false,
    note = 'Leave empty - it is created automatically from the name',
    options = '{"slug": true, "trim": true, "placeholder": "Created automatically from the name"}'
WHERE field = 'slug'
  AND collection IN ('subjects', 'specializations', 'countries', 'study_levels');

-- 2) Description: rich text editor (bold, headings, lists, links) instead of a plain text box.
UPDATE directus_fields
SET interface = 'input-rich-text-html',
    options = '{"toolbar": ["bold", "italic", "underline", "h2", "h3", "bullist", "numlist", "link", "removeformat", "undo", "redo"]}'
WHERE field = 'description'
  AND collection IN ('subjects', 'specializations');
