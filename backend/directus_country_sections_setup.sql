-- Directus presentation settings for the country_sections table (Study Abroad country pages).
-- Run AFTER "alembic upgrade head" (the table must exist).
-- This only writes Directus metadata (directus_collections / fields / relations).
-- It never creates or alters the application table.
-- Safe to run more than once. Afterwards: docker compose restart directus

BEGIN;

-- 1) Collection ---------------------------------------------------------------
INSERT INTO directus_collections (collection, icon, note, display_template, hidden, singleton, sort_field, accountability)
VALUES (
    'country_sections',
    'public',
    'Content blocks shown on a Study Abroad country page (why study, subjects, courses, universities, exams, scholarships, visa, application, intakes, cost, eligibility).',
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

-- 2) Fields of country_sections (re-created each run) -----------------------------
DELETE FROM directus_fields WHERE collection = 'country_sections';

INSERT INTO directus_fields
    (collection, field, special, interface, options, display, display_options, readonly, hidden, sort, width, note, required)
VALUES
('country_sections', 'id', 'uuid', 'input', NULL, NULL, NULL, true, true, 1, 'full', NULL, false),

('country_sections', 'section', NULL, 'select-dropdown',
 '{"choices":[
    {"text":"Why study here","value":"why"},
    {"text":"Top subject","value":"subject"},
    {"text":"Top course","value":"course"},
    {"text":"Top university","value":"university"},
    {"text":"Exam requirement","value":"exam"},
    {"text":"Scholarship","value":"scholarship"},
    {"text":"Student visa requirement","value":"visa"},
    {"text":"Application requirement","value":"application"},
    {"text":"Intake","value":"intake"},
    {"text":"Cost of studying","value":"cost"},
    {"text":"Eligibility criteria","value":"eligibility"}]}'::json,
 'labels', NULL, false, false, 2, 'half',
 'Which block of the country page this item appears in.', true),

('country_sections', 'status', NULL, 'select-dropdown',
 '{"choices":[
    {"text":"Draft","value":"draft"},
    {"text":"Pending review","value":"pending_review"},
    {"text":"Published","value":"published"},
    {"text":"Archived","value":"archived"}]}'::json,
 'labels', NULL, false, false, 3, 'half',
 'Only "Published" items appear on the website.', true),

('country_sections', 'title', NULL, 'input', NULL, NULL, NULL, false, false, 4, 'full',
 'Name of the item, e.g. "University of Oxford", "IELTS", "September intake".', true),

('country_sections', 'subtitle', NULL, 'input', NULL, NULL, NULL, false, false, 5, 'full',
 'Optional short line, e.g. the city of a university or a fee range.', false),

('country_sections', 'body', NULL, 'input-rich-text-html',
 '{"toolbar":["bold","italic","underline","h2","h3","bullist","numlist","link"]}'::json,
 NULL, NULL, false, false, 6, 'full',
 'Description text. For text blocks (visa, eligibility...) write the whole text here.', false),

('country_sections', 'url', NULL, 'input', NULL, NULL, NULL, false, false, 7, 'full',
 'Optional link. Must start with https:// (other links are ignored by the website).', false),

('country_sections', 'is_sponsored', 'cast-boolean', 'boolean',
 '{"label":"This item is sponsored"}'::json, NULL, NULL, false, false, 8, 'half',
 'Shows a "Sponsored" tag on the website.', false),

('country_sections', 'display_order', NULL, 'input', NULL, NULL, NULL, false, false, 9, 'half',
 'Lower numbers appear first. You can also drag rows to reorder them.', false),

('country_sections', 'country_id', 'm2o', 'select-dropdown-m2o',
 '{"template":"{{name}}"}'::json, 'related-values', '{"template":"{{name}}"}'::json,
 false, false, 10, 'full', 'The country this item belongs to.', true),

('country_sections', 'created_at', 'date-created', 'datetime', NULL, 'datetime', NULL, true, true, 11, 'half', NULL, false),
('country_sections', 'updated_at', 'date-updated', 'datetime', NULL, 'datetime', NULL, true, true, 12, 'half', NULL, false);

-- 3) Relation country_sections.country_id -> countries.sections ---------------------
DELETE FROM directus_relations
WHERE many_collection = 'country_sections' AND many_field = 'country_id';

INSERT INTO directus_relations (many_collection, many_field, one_collection, one_field, sort_field, one_deselect_action)
VALUES ('country_sections', 'country_id', 'countries', 'sections', 'display_order', 'delete');

-- 4) "Page sections" list on the country screen (alias field, not a real column) ------
DELETE FROM directus_fields WHERE collection = 'countries' AND field = 'sections';

INSERT INTO directus_fields
    (collection, field, special, interface, options, display, display_options, readonly, hidden, sort, width, note, required)
VALUES
('countries', 'sections', 'o2m', 'list-o2m',
 '{"template":"{{section}} - {{title}} ({{status}})","enableCreate":true,"enableSelect":false}'::json,
 'related-values', '{"template":"{{section}} - {{title}}"}'::json,
 false, false, NULL, 'full',
 'Content of the Study Abroad page of this country. Click "Create New", choose the type, fill in the title, set status to Published.',
 false);

COMMIT;
