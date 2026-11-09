-- Directus presentation settings for the subject_sections table.
-- Run AFTER "alembic upgrade head" (the table must exist).
-- This only writes Directus metadata (directus_collections / fields / relations).
-- It never creates or alters the application table.
-- Safe to run more than once. Afterwards: docker compose restart directus

BEGIN;

-- 1) Collection ---------------------------------------------------------------
INSERT INTO directus_collections (collection, icon, note, display_template, hidden, singleton, sort_field, accountability)
VALUES (
    'subject_sections',
    'view_agenda',
    'Extra content blocks shown on the Subject page (why study, industries, companies, courses, destinations, universities).',
    '{{section}} - {{title}}',
    false,
    false,
    'display_order',
    'all'
)
ON CONFLICT (collection) DO UPDATE SET
    icon = EXCLUDED.icon,
    note = EXCLUDED.note,
    display_template = EXCLUDED.display_template,
    hidden = EXCLUDED.hidden,
    singleton = EXCLUDED.singleton,
    sort_field = EXCLUDED.sort_field;

-- 2) Fields of subject_sections (re-created each run) ----------------------------
DELETE FROM directus_fields WHERE collection = 'subject_sections';

INSERT INTO directus_fields
    (collection, field, special, interface, options, display, display_options, readonly, hidden, sort, width, note, required)
VALUES
('subject_sections', 'id', 'uuid', 'input', NULL, NULL, NULL, true, true, 1, 'full', NULL, false),

('subject_sections', 'section', NULL, 'select-dropdown',
 '{"choices":[
    {"text":"About (level pages)","value":"about"},
    {"text":"Why study this subject / level","value":"why"},
    {"text":"Industry","value":"industry"},
    {"text":"Company","value":"company"},
    {"text":"Advertisement (level pages)","value":"advertisement"},
    {"text":"CTA - call to action (level pages)","value":"cta"},
    {"text":"Course","value":"course"},
    {"text":"Destination (country)","value":"destination"},
    {"text":"University","value":"university"}]}'::json,
 'labels', NULL, false, false, 2, 'half',
 'Where this item appears. For About, Why study, Advertisement and CTA publish only ONE item per page.', true),

('subject_sections', 'status', NULL, 'select-dropdown',
 '{"choices":[
    {"text":"Draft","value":"draft"},
    {"text":"Pending review","value":"pending_review"},
    {"text":"Published","value":"published"},
    {"text":"Archived","value":"archived"}]}'::json,
 'labels', NULL, false, false, 3, 'half',
 'Only "Published" items appear on the website.', true),

('subject_sections', 'title', NULL, 'input', NULL, NULL, NULL, false, false, 4, 'full',
 'Name of the item, e.g. "Aerospace", "Rolls-Royce", "University of Leeds".', true),

('subject_sections', 'subtitle', NULL, 'input', NULL, NULL, NULL, false, false, 5, 'full',
 'Optional short line, e.g. the city of a university.', false),

('subject_sections', 'body', NULL, 'input-rich-text-html',
 '{"toolbar":["bold","italic","underline","h2","h3","bullist","numlist","link"]}'::json,
 NULL, NULL, false, false, 6, 'full',
 'Description text.', false),

('subject_sections', 'url', NULL, 'input', NULL, NULL, NULL, false, false, 7, 'full',
 'Optional link. Must start with https:// (other links are ignored by the website).', false),

('subject_sections', 'is_sponsored', 'cast-boolean', 'boolean',
 '{"label":"This item is sponsored"}'::json, NULL, NULL, false, false, 8, 'half',
 'Shows a "Sponsored" tag on the website.', false),

('subject_sections', 'display_order', NULL, 'input', NULL, NULL, NULL, false, false, 9, 'half',
 'Lower numbers appear first. You can also drag rows to reorder them.', false),

('subject_sections', 'subject_id', 'm2o', 'select-dropdown-m2o',
 '{"template":"{{name}}"}'::json, 'related-values', '{"template":"{{name}}"}'::json,
 false, false, 10, 'full', 'The subject this item belongs to.', true),

('subject_sections', 'study_level_id', 'm2o', 'select-dropdown-m2o',
 '{"template":"{{name}}"}'::json, 'related-values', '{"template":"{{name}}"}'::json,
 false, false, 11, 'full',
 'Leave EMPTY to show this item on the subject page. Choose a level (e.g. Bachelors) to show it only on that level page of the subject.', false),

('subject_sections', 'specialization_id', 'm2o', 'select-dropdown-m2o',
 '{"template":"{{name}}"}'::json, 'related-values', '{"template":"{{name}}"}'::json,
 false, false, 12, 'full',
 'Leave EMPTY unless this item is only for one specialization page (e.g. Civil Engineering). It must belong to the subject chosen above.', false),

('subject_sections', 'created_at', 'date-created', 'datetime', NULL, 'datetime', NULL, true, true, 13, 'half', NULL, false),
('subject_sections', 'updated_at', 'date-updated', 'datetime', NULL, 'datetime', NULL, true, true, 14, 'half', NULL, false);

-- 3) Relation subject_sections.subject_id -> subjects.sections --------------------
-- "delete" means: removing an item from the subject screen deletes the row
-- (subject_id is NOT NULL, so "nullify" would fail).
DELETE FROM directus_relations
WHERE many_collection = 'subject_sections' AND many_field = 'subject_id';

INSERT INTO directus_relations (many_collection, many_field, one_collection, one_field, sort_field, one_deselect_action)
VALUES ('subject_sections', 'subject_id', 'subjects', 'sections', 'display_order', 'delete');

DELETE FROM directus_relations
WHERE many_collection = 'subject_sections' AND many_field = 'study_level_id';

INSERT INTO directus_relations (many_collection, many_field, one_collection, one_field, one_deselect_action)
VALUES ('subject_sections', 'study_level_id', 'study_levels', NULL, 'nullify');

DELETE FROM directus_relations
WHERE many_collection = 'subject_sections' AND many_field = 'specialization_id';

INSERT INTO directus_relations (many_collection, many_field, one_collection, one_field, one_deselect_action)
VALUES ('subject_sections', 'specialization_id', 'specializations', NULL, 'nullify');

-- 4) "Page sections" list on the subject screen (alias field, not a real column) ------
DELETE FROM directus_fields WHERE collection = 'subjects' AND field = 'sections';

INSERT INTO directus_fields
    (collection, field, special, interface, options, display, display_options, readonly, hidden, sort, width, note, required)
VALUES
('subjects', 'sections', 'o2m', 'list-o2m',
 '{"template":"{{section}} - {{title}} ({{status}})","enableCreate":true,"enableSelect":false}'::json,
 'related-values', '{"template":"{{section}} - {{title}}"}'::json,
 false, false, NULL, 'full',
 'Extra content for the subject page. Click "Create New", choose the type, fill in the title, set status to Published.',
 false);

COMMIT;
