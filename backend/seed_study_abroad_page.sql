-- Editable text for the /studyabroad pages. Safe to run twice (existing rows are kept).
--
-- HOW IT WORKS (no new table, no API change, no code change needed):
--   page_key = 'study-abroad'            -> default text shared by /studyabroad, every country page and every continent page
--   page_key = 'study-abroad:germany'    -> overrides for ONE country  (page_key = 'study-abroad:' + countries.slug)
--   page_key = 'study-abroad:europe'     -> overrides for ONE continent (continent slug: africa, asia, europe,
--                                           north-america, south-america, oceania, antarctica, other)
-- An override row replaces the default with the same section_key + content_key.
-- Values are JSON strings, e.g. '"Study in {country}"' (with the double quotes).
-- Placeholders: {country}, {continent}, {count}. In a title, a word in { } gets the blue highlight.
-- A section is hidden on the website when it has no content (nothing is shown as a placeholder).
--
-- Real data (not text) comes from the existing tables: countries (name, slug, country_code, description,
-- is_popular, status, display_order) and subjects. Continents are derived from countries.country_code.
-- Editors set the country's long text in countries.description OR in page_content overview/body.

INSERT INTO page_content (id, page_key, section_key, content_key, content_value, status) VALUES
 -- /studyabroad (index)
 (gen_random_uuid(), 'study-abroad', 'index', 'title',             '"Where do you want to {study}?"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'index', 'intro',             '"Choose a continent or a country to see what it offers international students."', 'published'),
 (gen_random_uuid(), 'study-abroad', 'index', 'popular_eyebrow',   '"Popular"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'index', 'popular_title',     '"Popular study destinations"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'index', 'continents_eyebrow','"Browse"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'index', 'continents_title',  '"Browse by continent"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'index', 'panel_title',       '"Study in {continent}"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'index', 'continent_link',    '"View all in {continent}"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'index', 'empty_message',     '"No destinations are listed yet."', 'published'),
 (gen_random_uuid(), 'study-abroad', 'index', 'cta_title',         '"Not sure where to go? {Ask an expert.}"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'index', 'cta_text',          '"Tell us your field and your budget. We will suggest where to apply."', 'published'),
 (gen_random_uuid(), 'study-abroad', 'meta',  'index_title',       '"Study abroad | Universta"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'meta',  'title',             '"Study in {country} | Universta"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'crumbs','home',              '"Home"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'crumbs','study_abroad',      '"Study abroad"', 'published'),

 -- country page /studyabroad/<country-slug>
 (gen_random_uuid(), 'study-abroad', 'hero',     'title',  '"Study in {country}"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'hero',     'cta',    '"Talk to an expert"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'labels',   'sponsored', '"Sponsored"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'nearby',   'title',  '"More countries in {continent}"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'nearby',   'link',   '"View all in {continent}"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'faq',      'title',  '"Studying in {country}"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'nav',      'nearby', '"Nearby countries"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'nav',      'faq',    '"FAQ"', 'published'),

 -- country page: the 11 content blocks. section_key = block id. Titles (and tab names in section 'nav').
 -- The items inside each block are rows of the country_sections table (Directus: Countries > Sections).
 (gen_random_uuid(), 'study-abroad', 'why',          'title', '"Why study in {country}"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'subjects',     'title', '"Top subjects to study in {country}"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'courses',      'title', '"Top courses to study in {country}"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'universities', 'title', '"Top universities to study in {country}"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'exams',        'title', '"Exam requirements to study in {country}"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'scholarships', 'title', '"Scholarships to study in {country}"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'visa',         'title', '"Student visa requirements for {country}"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'applications', 'title', '"Application requirements to study in {country}"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'intakes',      'title', '"Intakes in {country}"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'costs',        'title', '"Cost of studying in {country}"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'eligibility',  'title', '"Eligibility criteria to study in {country}"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'nav', 'why',          '"Why study"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'nav', 'subjects',     '"Subjects"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'nav', 'courses',      '"Courses"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'nav', 'universities', '"Universities"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'nav', 'exams',        '"Exams"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'nav', 'scholarships', '"Scholarships"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'nav', 'visa',         '"Visa"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'nav', 'applications', '"Application"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'nav', 'intakes',      '"Intakes"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'nav', 'costs',        '"Cost"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'nav', 'eligibility',  '"Eligibility"', 'published'),

 -- continent page /studyabroad/<continent-slug> (same section names, different titles)
 (gen_random_uuid(), 'study-abroad', 'countries', 'title', '"Countries in {continent}"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'others',    'title', '"Explore other continents"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'others',    'link',  '"Explore"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'facts',     'countries_label', '"Countries"', 'published'),

 -- "Your next step" band (all study-abroad pages)
 (gen_random_uuid(), 'study-abroad', 'next_steps', 'title',              '"Your next step"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'next_steps', 'scholarships_title', '"Scholarships"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'next_steps', 'exams_title',        '"Pick your test"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'next_steps', 'visa_title',         '"Student visa"', 'published'),
 (gen_random_uuid(), 'study-abroad', 'next_steps', 'consultants_title',  '"Find a consultant"', 'published')
ON CONFLICT (page_key, section_key, content_key) DO NOTHING;

-- OPTIONAL keys (no default; the block is hidden until a row exists). Add them per country or continent:
--   hero / intro                 short line under the title (country page falls back to countries.description)
--   overview / body              rich text HTML, continent pages only
--   <block> / intro              short text under any of the 11 country block titles (block = why, subjects, ... eligibility)
--   nearby / intro, countries / intro, others / intro
--
-- Per-country wording, e.g. "Why study in the UK" instead of "Why study in United Kingdom":
--   INSERT ... 'study-abroad:united-kingdom', 'why', 'title', '"Why study in the UK"' ...
--
-- THE 11 COUNTRY BLOCKS (why, subjects, courses, universities, exams, scholarships, visa, applications,
-- intakes, costs, eligibility) get their ITEMS from the country_sections table, not from page_content:
--   Directus > Countries > open a country > "Sections" > Create New.  One row = one item
--   (a university, a course, a scholarship...) or one text block (visa rules, eligibility...).
--   Setup: alembic upgrade head, then directus_country_sections_setup.sql, then restart Directus.
--   API: GET /api/countries/{slug}/sections
--   faq / q1 + a1  ...  q6 + a6   (a pair is shown only when both exist)
--   next_steps / <scholarships|exams|visa|consultants>_desc
--
-- Example for one country (uncomment to try):
-- INSERT INTO page_content (id, page_key, section_key, content_key, content_value, status) VALUES
--  (gen_random_uuid(), 'study-abroad:germany', 'why',  'title',       '"Why study in Germany"', 'published'),
--  (gen_random_uuid(), 'study-abroad:germany', 'faq',   'q1',          '"Is tuition free in Germany?"', 'published'),
--  (gen_random_uuid(), 'study-abroad:germany', 'faq',   'a1',          '"Most public universities charge no tuition."', 'published')
-- ON CONFLICT (page_key, section_key, content_key) DO NOTHING;
