-- SAMPLE content for the Subject Detail page (replace with real content in Directus).
-- Adds a few published items to the first 3 published subjects.
-- Run after "alembic upgrade head". Safe to run more than once (skips rows that already exist).

INSERT INTO subject_sections
    (id, subject_id, section, title, subtitle, body, url, is_sponsored, status, display_order)
SELECT gen_random_uuid(), s.id, v.section, REPLACE(v.title, '{subject}', s.name),
       v.subtitle, v.body, v.url, v.sp, 'published', v.ord
FROM (
    SELECT id, name FROM subjects
    WHERE status = 'published'
    ORDER BY display_order, name
    LIMIT 3
) AS s
CROSS JOIN (VALUES
    ('why',         'Why study {subject}?',   NULL,      '<p>Sample text: this subject opens doors to <strong>global careers</strong>, strong salaries and study options in many countries.</p>', NULL,                  false, 1),
    ('industry',    'Technology',             NULL,      '<p>Sample industry description.</p>',                                                                                                  NULL,                  false, 1),
    ('industry',    'Healthcare',             NULL,      '<p>Sample industry description.</p>',                                                                                                  NULL,                  false, 2),
    ('company',     'Sample Company Ltd',     NULL,      '<p>Sample company description.</p>',                                                                                                   'https://example.com', true,  1),
    ('course',      'Sample Course',          'Bachelor''s', '<p>Sample course description.</p>',                                                                                                  NULL,                  false, 1),
    ('destination', 'United Kingdom',         NULL,      '<p>Sample destination description.</p>',                                                                                               NULL,                  false, 1),
    ('university',  'Sample University',      'London',  '<p>Sample university description.</p>',                                                                                                'https://example.com', false, 1)
) AS v(section, title, subtitle, body, url, sp, ord)
WHERE NOT EXISTS (
    SELECT 1 FROM subject_sections ss
    WHERE ss.subject_id = s.id
      AND ss.section = v.section
      AND ss.title = REPLACE(v.title, '{subject}', s.name)
);

-- SAMPLE content for the Subject + Study Level page, e.g. /subjects/<subject>/<level> (replace in Directus).
-- Adds items to the first published level of the first 3 subjects. Safe to run more than once.
INSERT INTO subject_sections
    (id, subject_id, study_level_id, section, title, subtitle, body, url, is_sponsored, status, display_order)
SELECT gen_random_uuid(), s.id, l.id, v.section, REPLACE(REPLACE(v.title, '{subject}', s.name), '{level}', l.name),
       v.subtitle, v.body, v.url, v.sp, 'published', v.ord
FROM (SELECT id, name FROM subjects WHERE status = 'published' ORDER BY display_order, name LIMIT 3) AS s
JOIN LATERAL (
    SELECT sl.id, sl.name FROM study_levels sl
    JOIN subject_study_levels ssl ON ssl.study_level_id = sl.id AND ssl.subject_id = s.id
    WHERE sl.status = 'published' ORDER BY sl.display_order, sl.name LIMIT 1
) AS l ON true
CROSS JOIN (VALUES
    ('about',         'About {level} in {subject}',         NULL, '<p>Sample text: what a {level} in this field looks like.</p>', NULL, false, 1),
    ('why',           'Why choose a {level} in {subject}?', NULL, '<p>Sample text: reasons to study at this level.</p>',          NULL, false, 1),
    ('industry',      'Technology',                         NULL, '<p>Sample industry for this level.</p>',                       NULL, false, 1),
    ('company',       'Sample Company Ltd',                 NULL, '<p>Sample company that hires at this level.</p>',              'https://example.com', true, 1),
    ('advertisement', 'Sample advertisement',               NULL, '<p>Sample sponsored message.</p>',                             'https://example.com', true, 1),
    ('cta',           'Get free advice on your {level}',    NULL, '<p>Sample call to action text.</p>',                           NULL, false, 1),
    ('course',        'Sample Course',                      'Sample University', '<p>Sample course.</p>',                         'https://example.com', true, 1),
    ('destination',   'United Kingdom',                     NULL, '<p>Sample destination.</p>',                                   NULL, false, 1),
    ('university',    'Sample University',                  'London', '<p>Sample university.</p>',                                'https://example.com', true, 1)
) AS v(section, title, subtitle, body, url, sp, ord)
WHERE NOT EXISTS (
    SELECT 1 FROM subject_sections ss
    WHERE ss.subject_id = s.id AND ss.study_level_id = l.id AND ss.section = v.section
      AND ss.title = REPLACE(REPLACE(v.title, '{subject}', s.name), '{level}', l.name)
);

-- SAMPLE content for the Specialization page, e.g. /subjects/<subject>/<specialization> (replace in Directus).
-- Adds items to the first published specialization of the first 3 subjects. Safe to run more than once.
INSERT INTO subject_sections
    (id, subject_id, specialization_id, section, title, subtitle, body, url, is_sponsored, status, display_order)
SELECT gen_random_uuid(), s.id, sp.id, v.section, REPLACE(v.title, '{spec}', sp.name),
       v.subtitle, v.body, v.url, v.sp, 'published', v.ord
FROM (SELECT id FROM subjects WHERE status = 'published' ORDER BY display_order, name LIMIT 3) AS s
JOIN LATERAL (
    SELECT id, name FROM specializations
    WHERE subject_id = s.id AND status = 'published' ORDER BY display_order, name LIMIT 1
) AS sp ON true
CROSS JOIN (VALUES
    ('about',         'About {spec}',                  NULL, '<p>Sample text: what {spec} is about.</p>',          NULL, false, 1),
    ('why',           'Why study {spec}?',             NULL, '<p>Sample text: reasons to choose {spec}.</p>',      NULL, false, 1),
    ('industry',      'Technology',                    NULL, '<p>Sample industry.</p>',                            NULL, false, 1),
    ('company',       'Sample Company Ltd',            NULL, '<p>Sample company.</p>',                             'https://example.com', true, 1),
    ('advertisement', 'Sample advertisement',          NULL, '<p>Sample sponsored message.</p>',                   'https://example.com', true, 1),
    ('cta',           'Get free advice on {spec}',     NULL, '<p>Sample call to action text.</p>',                 NULL, false, 1),
    ('course',        'Sample Course',                 'Sample University', '<p>Sample course.</p>',               'https://example.com', true, 1),
    ('destination',   'United Kingdom',                NULL, '<p>Sample destination.</p>',                         NULL, false, 1),
    ('university',    'Sample University',             'London', '<p>Sample university.</p>',                      'https://example.com', true, 1)
) AS v(section, title, subtitle, body, url, sp, ord)
WHERE NOT EXISTS (
    SELECT 1 FROM subject_sections ss
    WHERE ss.subject_id = s.id AND ss.specialization_id = sp.id AND ss.section = v.section
      AND ss.title = REPLACE(v.title, '{spec}', sp.name)
);

-- SAMPLE content for the Specialization + Level page, e.g. /subjects/<subject>/<specialization>/<level> (replace in Directus).
-- First published specialization + first published level of the first 3 subjects. Safe to run more than once.
INSERT INTO subject_sections
    (id, subject_id, specialization_id, study_level_id, section, title, subtitle, body, url, is_sponsored, status, display_order)
SELECT gen_random_uuid(), s.id, sp.id, l.id, v.section,
       REPLACE(REPLACE(v.title, '{spec}', sp.name), '{level}', l.name),
       v.subtitle, v.body, v.url, v.sp, 'published', v.ord
FROM (SELECT id FROM subjects WHERE status = 'published' ORDER BY display_order, name LIMIT 3) AS s
JOIN LATERAL (
    SELECT id, name FROM specializations
    WHERE subject_id = s.id AND status = 'published' ORDER BY display_order, name LIMIT 1
) AS sp ON true
JOIN LATERAL (
    SELECT sl.id, sl.name FROM study_levels sl
    JOIN subject_study_levels ssl ON ssl.study_level_id = sl.id AND ssl.subject_id = s.id
    WHERE sl.status = 'published' ORDER BY sl.display_order, sl.name LIMIT 1
) AS l ON true
CROSS JOIN (VALUES
    ('about',         'About {level} in {spec}',          NULL, '<p>Sample text: what a {level} in {spec} looks like.</p>', NULL, false, 1),
    ('why',           'Why choose a {level} in {spec}?',  NULL, '<p>Sample text: reasons to choose this path.</p>',          NULL, false, 1),
    ('industry',      'Technology',                       NULL, '<p>Sample industry.</p>',                                   NULL, false, 1),
    ('company',       'Sample Company Ltd',               NULL, '<p>Sample company.</p>',                                    'https://example.com', true, 1),
    ('advertisement', 'Sample advertisement',             NULL, '<p>Sample sponsored message.</p>',                          'https://example.com', true, 1),
    ('cta',           'Get free advice on {spec}',        NULL, '<p>Sample call to action text.</p>',                        NULL, false, 1),
    ('course',        'Sample Course',                    'Sample University', '<p>Sample course.</p>',                      'https://example.com', true, 1),
    ('destination',   'United Kingdom',                   NULL, '<p>Sample destination.</p>',                                NULL, false, 1),
    ('university',    'Sample University',                'London', '<p>Sample university.</p>',                             'https://example.com', true, 1)
) AS v(section, title, subtitle, body, url, sp, ord)
WHERE NOT EXISTS (
    SELECT 1 FROM subject_sections ss
    WHERE ss.subject_id = s.id AND ss.specialization_id = sp.id AND ss.study_level_id = l.id AND ss.section = v.section
      AND ss.title = REPLACE(REPLACE(v.title, '{spec}', sp.name), '{level}', l.name)
);
