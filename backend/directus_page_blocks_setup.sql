-- Directus presentation for the page blocks (about / why / advertisement / cta).
-- Run AFTER "alembic upgrade head" (migration a3d9f1c7e5b2).
-- Writes only Directus metadata; never creates or alters application tables.
-- Safe to run more than once. Afterwards: docker compose restart directus
--
-- Editing model:
--   * Subject page          -> open the subject, use the four collapsible groups.
--   * Subject + Level page  -> open the subject, "Study level pages" list, open a level row.
--   * Specialization pages  -> still the "Page sections" list (subject_sections).

BEGIN;

-- 1) Collection for the junction table, so a level row can be opened and edited ----
INSERT INTO directus_collections (collection, icon, note, display_template, hidden, singleton, accountability)
VALUES ('subject_study_levels', 'layers',
        'One row per Subject + Study level page. Holds that page''s About / Why / Advertisement / CTA.',
        '{{study_level_id.name}}', false, false, 'all')
ON CONFLICT (collection) DO UPDATE SET
    icon = EXCLUDED.icon, note = EXCLUDED.note,
    display_template = EXCLUDED.display_template, hidden = EXCLUDED.hidden;

-- 2) Fields on SUBJECTS (subject page blocks) -----------------------------------
DELETE FROM directus_fields WHERE collection = 'subjects' AND (field ~ '^grp_(about|why|ad|cta)$' OR field ~ '^(about|why|ad|cta)_(title|subtitle|body|url)$');

INSERT INTO directus_fields
    (collection, field, special, interface, options, display, display_options, readonly, hidden, sort, width, note, "group", required)
VALUES
('subjects', 'grp_about', 'alias,no-data,group', 'group-detail', '{"start":"closed","headerIcon":"article"}'::json, NULL, NULL, false, false, 100, 'full', 'Intro text of the page.', NULL, false),
('subjects', 'about_title', NULL, 'input', NULL, NULL, NULL, false, false, 101, 'half', 'Heading. Leave EMPTY to hide this block on the website.', 'grp_about', false),
('subjects', 'about_body', NULL, 'input-rich-text-html', '{"toolbar":["bold","italic","underline","h2","h3","bullist","numlist","link"]}'::json, NULL, NULL, false, false, 102, 'full', 'Description text.', 'grp_about', false),
('subjects', 'grp_why', 'alias,no-data,group', 'group-detail', '{"start":"closed","headerIcon":"article"}'::json, NULL, NULL, false, false, 103, 'full', '"Why study this" block.', NULL, false),
('subjects', 'why_title', NULL, 'input', NULL, NULL, NULL, false, false, 104, 'half', 'Heading. Leave EMPTY to hide this block on the website.', 'grp_why', false),
('subjects', 'why_body', NULL, 'input-rich-text-html', '{"toolbar":["bold","italic","underline","h2","h3","bullist","numlist","link"]}'::json, NULL, NULL, false, false, 105, 'full', 'Description text.', 'grp_why', false),
('subjects', 'grp_ad', 'alias,no-data,group', 'group-detail', '{"start":"closed","headerIcon":"article"}'::json, NULL, NULL, false, false, 106, 'full', 'Always shown with an "Advertisement" label. Leave the title empty to hide it.', NULL, false),
('subjects', 'ad_title', NULL, 'input', NULL, NULL, NULL, false, false, 107, 'half', 'Heading. Leave EMPTY to hide this block on the website.', 'grp_ad', false),
('subjects', 'ad_subtitle', NULL, 'input', NULL, NULL, NULL, false, false, 108, 'half', 'Short extra line.', 'grp_ad', false),
('subjects', 'ad_body', NULL, 'input-rich-text-html', '{"toolbar":["bold","italic","underline","h2","h3","bullist","numlist","link"]}'::json, NULL, NULL, false, false, 109, 'full', 'Description text.', 'grp_ad', false),
('subjects', 'ad_url', NULL, 'input', NULL, NULL, NULL, false, false, 110, 'full', 'Optional link. Must start with https:// (other links are ignored).', 'grp_ad', false),
('subjects', 'grp_cta', 'alias,no-data,group', 'group-detail', '{"start":"closed","headerIcon":"article"}'::json, NULL, NULL, false, false, 111, 'full', 'Leave the title empty to hide it. Subtitle = button text; no link = button scrolls to the enquiry form.', NULL, false),
('subjects', 'cta_title', NULL, 'input', NULL, NULL, NULL, false, false, 112, 'half', 'Heading. Leave EMPTY to hide this block on the website.', 'grp_cta', false),
('subjects', 'cta_subtitle', NULL, 'input', NULL, NULL, NULL, false, false, 113, 'half', 'Short extra line.', 'grp_cta', false),
('subjects', 'cta_body', NULL, 'input-rich-text-html', '{"toolbar":["bold","italic","underline","h2","h3","bullist","numlist","link"]}'::json, NULL, NULL, false, false, 114, 'full', 'Description text.', 'grp_cta', false),
('subjects', 'cta_url', NULL, 'input', NULL, NULL, NULL, false, false, 115, 'full', 'Optional link. Must start with https:// (other links are ignored).', 'grp_cta', false);

-- 3) Fields on SUBJECT_STUDY_LEVELS (level page blocks) ---------------------------
DELETE FROM directus_fields WHERE collection = 'subject_study_levels'
  AND field IN ('id', 'subject_id', 'study_level_id', 'created_at');

INSERT INTO directus_fields
    (collection, field, special, interface, options, display, display_options, readonly, hidden, sort, width, note, required)
VALUES
('subject_study_levels', 'id', 'uuid', 'input', NULL, NULL, NULL, true, true, 1, 'full', NULL, false),
('subject_study_levels', 'subject_id', 'm2o', 'select-dropdown-m2o',
 '{"template":"{{name}}"}'::json, 'related-values', '{"template":"{{name}}"}'::json,
 false, false, 2, 'half', 'The subject.', true),
('subject_study_levels', 'study_level_id', 'm2o', 'select-dropdown-m2o',
 '{"template":"{{name}}"}'::json, 'related-values', '{"template":"{{name}}"}'::json,
 false, false, 3, 'half', 'The study level (e.g. Bachelors). One row per subject + level.', true),
('subject_study_levels', 'created_at', 'date-created', 'datetime', NULL, 'datetime', NULL, true, true, 4, 'half', NULL, false);

DELETE FROM directus_fields WHERE collection = 'subject_study_levels' AND (field ~ '^grp_(about|why|ad|cta)$' OR field ~ '^(about|why|ad|cta)_(title|subtitle|body|url)$');

INSERT INTO directus_fields
    (collection, field, special, interface, options, display, display_options, readonly, hidden, sort, width, note, "group", required)
VALUES
('subject_study_levels', 'grp_about', 'alias,no-data,group', 'group-detail', '{"start":"closed","headerIcon":"article"}'::json, NULL, NULL, false, false, 10, 'full', 'Intro text of the page.', NULL, false),
('subject_study_levels', 'about_title', NULL, 'input', NULL, NULL, NULL, false, false, 11, 'half', 'Heading. Leave EMPTY to hide this block on the website.', 'grp_about', false),
('subject_study_levels', 'about_body', NULL, 'input-rich-text-html', '{"toolbar":["bold","italic","underline","h2","h3","bullist","numlist","link"]}'::json, NULL, NULL, false, false, 12, 'full', 'Description text.', 'grp_about', false),
('subject_study_levels', 'grp_why', 'alias,no-data,group', 'group-detail', '{"start":"closed","headerIcon":"article"}'::json, NULL, NULL, false, false, 13, 'full', '"Why study this" block.', NULL, false),
('subject_study_levels', 'why_title', NULL, 'input', NULL, NULL, NULL, false, false, 14, 'half', 'Heading. Leave EMPTY to hide this block on the website.', 'grp_why', false),
('subject_study_levels', 'why_body', NULL, 'input-rich-text-html', '{"toolbar":["bold","italic","underline","h2","h3","bullist","numlist","link"]}'::json, NULL, NULL, false, false, 15, 'full', 'Description text.', 'grp_why', false),
('subject_study_levels', 'grp_ad', 'alias,no-data,group', 'group-detail', '{"start":"closed","headerIcon":"article"}'::json, NULL, NULL, false, false, 16, 'full', 'Always shown with an "Advertisement" label. Leave the title empty to hide it.', NULL, false),
('subject_study_levels', 'ad_title', NULL, 'input', NULL, NULL, NULL, false, false, 17, 'half', 'Heading. Leave EMPTY to hide this block on the website.', 'grp_ad', false),
('subject_study_levels', 'ad_subtitle', NULL, 'input', NULL, NULL, NULL, false, false, 18, 'half', 'Short extra line.', 'grp_ad', false),
('subject_study_levels', 'ad_body', NULL, 'input-rich-text-html', '{"toolbar":["bold","italic","underline","h2","h3","bullist","numlist","link"]}'::json, NULL, NULL, false, false, 19, 'full', 'Description text.', 'grp_ad', false),
('subject_study_levels', 'ad_url', NULL, 'input', NULL, NULL, NULL, false, false, 20, 'full', 'Optional link. Must start with https:// (other links are ignored).', 'grp_ad', false),
('subject_study_levels', 'grp_cta', 'alias,no-data,group', 'group-detail', '{"start":"closed","headerIcon":"article"}'::json, NULL, NULL, false, false, 21, 'full', 'Leave the title empty to hide it. Subtitle = button text; no link = button scrolls to the enquiry form.', NULL, false),
('subject_study_levels', 'cta_title', NULL, 'input', NULL, NULL, NULL, false, false, 22, 'half', 'Heading. Leave EMPTY to hide this block on the website.', 'grp_cta', false),
('subject_study_levels', 'cta_subtitle', NULL, 'input', NULL, NULL, NULL, false, false, 23, 'half', 'Short extra line.', 'grp_cta', false),
('subject_study_levels', 'cta_body', NULL, 'input-rich-text-html', '{"toolbar":["bold","italic","underline","h2","h3","bullist","numlist","link"]}'::json, NULL, NULL, false, false, 24, 'full', 'Description text.', 'grp_cta', false),
('subject_study_levels', 'cta_url', NULL, 'input', NULL, NULL, NULL, false, false, 25, 'full', 'Optional link. Must start with https:// (other links are ignored).', 'grp_cta', false);

-- 4) Relations --------------------------------------------------------------------
DELETE FROM directus_relations
WHERE many_collection = 'subject_study_levels' AND many_field IN ('subject_id', 'study_level_id');

INSERT INTO directus_relations (many_collection, many_field, one_collection, one_field, one_deselect_action)
VALUES
('subject_study_levels', 'subject_id', 'subjects', 'study_level_links', 'delete'),
('subject_study_levels', 'study_level_id', 'study_levels', NULL, 'nullify');

-- 5) "Study level pages" list on the subject screen (alias field) ------------------
DELETE FROM directus_fields WHERE collection = 'subjects' AND field = 'study_level_links';

INSERT INTO directus_fields
    (collection, field, special, interface, options, display, display_options, readonly, hidden, sort, width, note, required)
VALUES
('subjects', 'study_level_links', 'o2m', 'list-o2m',
 '{"template":"{{study_level_id.name}}","enableCreate":true,"enableSelect":false}'::json,
 'related-values', '{"template":"{{study_level_id.name}}"}'::json,
 false, false, NULL, 'full',
 'One row per study level of this subject (Bachelors, Masters ...). Open a row to edit the About / Why / Advertisement / CTA of that Subject + Level page.',
 false);

COMMIT;
