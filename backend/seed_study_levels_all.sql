-- 7 study levels in the right order, linked to the subjects. Safe to run twice.
INSERT INTO study_levels (id, name, slug, description, duration, status, display_order) VALUES
 (gen_random_uuid(), 'Foundation', 'foundation', 'A preparatory year that builds the subject knowledge and English skills needed to start a bachelor''s degree.', '1 year', 'published', 1),
 (gen_random_uuid(), 'Pathway', 'pathway', 'A programme run with a partner university that leads into the first or second year of a degree.', '6-12 months', 'published', 2),
 (gen_random_uuid(), 'Diploma', 'diploma', 'Practical, career-focused study that often counts towards the second year of a bachelor''s degree.', '1-2 years', 'published', 3),
 (gen_random_uuid(), 'Bachelor''s', 'bachelors', 'Your first university degree, after finishing secondary school.', '3-4 years', 'published', 4),
 (gen_random_uuid(), 'Master''s', 'masters', 'Specialist or career-change study after a bachelor''s degree.', '1-2 years', 'published', 5),
 (gen_random_uuid(), 'MBA', 'mba', 'A master''s degree in business and management, usually for people with work experience.', '1-2 years', 'published', 6),
 (gen_random_uuid(), 'PhD', 'phd', 'Original research under a supervisor, usually after a master''s degree.', '3-5 years', 'published', 7)
ON CONFLICT (slug) DO UPDATE SET display_order = EXCLUDED.display_order;

-- Link every published subject to every level, except MBA, which only fits Business & Management.
INSERT INTO subject_study_levels (id, subject_id, study_level_id)
SELECT gen_random_uuid(), s.id, l.id
FROM subjects s
CROSS JOIN study_levels l
WHERE s.status = 'published'
  AND l.status = 'published'
  AND (l.slug <> 'mba' OR s.slug = 'business-management')
ON CONFLICT (subject_id, study_level_id) DO NOTHING;
