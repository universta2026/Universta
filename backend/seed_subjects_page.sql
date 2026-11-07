-- Adds the text of the Subjects page to the page_content table (safe to run twice).
INSERT INTO page_content (id, page_key, section_key, content_key, content_value, status) VALUES
 (gen_random_uuid(), 'subjects', 'hero',    'eyebrow',       '"SUBJECTS & SPECIALIZATIONS"', 'published'),
 (gen_random_uuid(), 'subjects', 'hero',    'title',         '"Find the field that fits you"', 'published'),
 (gen_random_uuid(), 'subjects', 'hero',    'intro',         '"Explore {count} major fields and dozens of specializations. Every subject guide shows careers, typical modules, top universities and how degrees differ by study level."', 'published'),
 (gen_random_uuid(), 'subjects', 'search',  'placeholder',   '"Search subjects or specializations..."', 'published'),
 (gen_random_uuid(), 'subjects', 'search',  'button',        '"Search"', 'published'),
 (gen_random_uuid(), 'subjects', 'filters', 'title',         '"Filters"', 'published'),
 (gen_random_uuid(), 'subjects', 'list',    'empty_message', '"No subjects match your search. Try a different word or clear the filters."', 'published')
ON CONFLICT (page_key, section_key, content_key) DO NOTHING;
