-- Directus presentation for the Study Abroad text blocks on the COUNTRY screen
-- (why / visa / application / cost / eligibility), same pattern as the subject page blocks.
-- Run AFTER "alembic upgrade head" (migration d5f2b8a9c1e3) and directus_country_sections_setup.sql.
-- Writes only Directus metadata. Safe to run more than once. Afterwards: docker compose restart directus
--
-- Editing model:
--   * Text blocks      -> open the country, use the collapsible groups.
--   * Lists (subjects, courses, universities, exams, scholarships, intakes)
--                      -> open the country, "Page sections" list.

BEGIN;

DELETE FROM directus_fields WHERE collection = 'countries'
  AND (field ~ '^grp_(why|visa|application|cost|eligibility)$'
    OR field ~ '^(why|visa|application|cost|eligibility)_(title|body)$');

INSERT INTO directus_fields
    (collection, field, special, interface, options, display, display_options, readonly, hidden, sort, width, note, "group", required)
VALUES
('countries', 'grp_why', 'alias,no-data,group', 'group-detail', '{"start":"closed","headerIcon":"article"}'::json, NULL, NULL, false, false, 100, 'full', 'Why study here. Leave the heading empty to hide this block on the website.', NULL, false),
('countries', 'why_title', NULL, 'input', NULL, NULL, NULL, false, false, 101, 'full', 'Heading. Leave EMPTY to hide this block on the website.', 'grp_why', false),
('countries', 'why_body', NULL, 'input-rich-text-html', '{"toolbar":["undo","redo","bold","italic","underline","strikethrough","h1","h2","h3","h4","h5","h6","numlist","bullist","blockquote","hr","customLink","unlink","removeformat","cut","copy","paste","fullscreen"]}'::json, NULL, NULL, false, false, 102, 'full', 'Text of the block.', 'grp_why', false),
('countries', 'grp_visa', 'alias,no-data,group', 'group-detail', '{"start":"closed","headerIcon":"article"}'::json, NULL, NULL, false, false, 103, 'full', 'Student visa requirements. Leave the heading empty to hide this block on the website.', NULL, false),
('countries', 'visa_title', NULL, 'input', NULL, NULL, NULL, false, false, 104, 'full', 'Heading. Leave EMPTY to hide this block on the website.', 'grp_visa', false),
('countries', 'visa_body', NULL, 'input-rich-text-html', '{"toolbar":["undo","redo","bold","italic","underline","strikethrough","h1","h2","h3","h4","h5","h6","numlist","bullist","blockquote","hr","customLink","unlink","removeformat","cut","copy","paste","fullscreen"]}'::json, NULL, NULL, false, false, 105, 'full', 'Text of the block.', 'grp_visa', false),
('countries', 'grp_application', 'alias,no-data,group', 'group-detail', '{"start":"closed","headerIcon":"article"}'::json, NULL, NULL, false, false, 106, 'full', 'Application requirements. Leave the heading empty to hide this block on the website.', NULL, false),
('countries', 'application_title', NULL, 'input', NULL, NULL, NULL, false, false, 107, 'full', 'Heading. Leave EMPTY to hide this block on the website.', 'grp_application', false),
('countries', 'application_body', NULL, 'input-rich-text-html', '{"toolbar":["undo","redo","bold","italic","underline","strikethrough","h1","h2","h3","h4","h5","h6","numlist","bullist","blockquote","hr","customLink","unlink","removeformat","cut","copy","paste","fullscreen"]}'::json, NULL, NULL, false, false, 108, 'full', 'Text of the block.', 'grp_application', false),
('countries', 'grp_cost', 'alias,no-data,group', 'group-detail', '{"start":"closed","headerIcon":"article"}'::json, NULL, NULL, false, false, 109, 'full', 'Cost of studying. Leave the heading empty to hide this block on the website.', NULL, false),
('countries', 'cost_title', NULL, 'input', NULL, NULL, NULL, false, false, 110, 'full', 'Heading. Leave EMPTY to hide this block on the website.', 'grp_cost', false),
('countries', 'cost_body', NULL, 'input-rich-text-html', '{"toolbar":["undo","redo","bold","italic","underline","strikethrough","h1","h2","h3","h4","h5","h6","numlist","bullist","blockquote","hr","customLink","unlink","removeformat","cut","copy","paste","fullscreen"]}'::json, NULL, NULL, false, false, 111, 'full', 'Text of the block.', 'grp_cost', false),
('countries', 'grp_eligibility', 'alias,no-data,group', 'group-detail', '{"start":"closed","headerIcon":"article"}'::json, NULL, NULL, false, false, 112, 'full', 'Eligibility criteria. Leave the heading empty to hide this block on the website.', NULL, false),
('countries', 'eligibility_title', NULL, 'input', NULL, NULL, NULL, false, false, 113, 'full', 'Heading. Leave EMPTY to hide this block on the website.', 'grp_eligibility', false),
('countries', 'eligibility_body', NULL, 'input-rich-text-html', '{"toolbar":["undo","redo","bold","italic","underline","strikethrough","h1","h2","h3","h4","h5","h6","numlist","bullist","blockquote","hr","customLink","unlink","removeformat","cut","copy","paste","fullscreen"]}'::json, NULL, NULL, false, false, 114, 'full', 'Text of the block.', 'grp_eligibility', false);

-- The list collection now only offers the multi-item block types.
UPDATE directus_fields SET options = '{"choices":[
    {"text":"Top subject","value":"subject"},
    {"text":"Top course","value":"course"},
    {"text":"Top university","value":"university"},
    {"text":"Exam requirement","value":"exam"},
    {"text":"Scholarship","value":"scholarship"},
    {"text":"Intake","value":"intake"}]}'::json
WHERE collection = 'country_sections' AND field = 'section';

UPDATE directus_fields SET sort = 200, note = 'Lists of the Study Abroad page: top subjects, courses, universities, exams, scholarships, intakes. Click "Create New", choose the type, fill in the title, set status to Published.'
WHERE collection = 'countries' AND field = 'sections';

COMMIT;
