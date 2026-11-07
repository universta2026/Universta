-- Editable headings for the subject detail page (page_key = subject-detail). Safe to run twice.
INSERT INTO page_content (id, page_key, section_key, content_key, content_value, status) VALUES
 (gen_random_uuid(), 'subject-detail', 'overview',        'title', '"Overview"', 'published'),
 (gen_random_uuid(), 'subject-detail', 'specializations', 'title', '"Specializations"', 'published'),
 (gen_random_uuid(), 'subject-detail', 'specializations', 'intro', '"Narrow your focus. Each specialization has its own modules, universities and career paths."', 'published'),
 (gen_random_uuid(), 'subject-detail', 'study_levels',    'title', '"Study levels"', 'published'),
 (gen_random_uuid(), 'subject-detail', 'study_levels',    'intro', '"Choose a level to see entry requirements, programmes and costs."', 'published')
ON CONFLICT (page_key, section_key, content_key) DO NOTHING;
