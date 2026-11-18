-- PLACEHOLDER rows for country_sections (Study Abroad country pages).
-- All rows are status = 'draft' and titled "[Placeholder] ...", so nothing appears on the website.
-- Replace them with real content in Directus (Countries -> Sections), then set status = 'published'.
-- Only the list blocks; text blocks (why/visa/application/cost/eligibility) are fields on the country.
-- Safe to re-run: skips rows that already exist for the same country + section + title.

INSERT INTO country_sections (id, country_id, section, title, subtitle, body, status, display_order)
SELECT gen_random_uuid(), c.id, s.section, '[Placeholder] ' || s.label, NULL,
       '<p>Placeholder content - replace with real information before publishing.</p>',
       'draft', 0
FROM countries c
CROSS JOIN (VALUES
    ('subject', 'Top subject'),
    ('course', 'Top course'),
    ('university', 'Top university'),
    ('exam', 'Exam requirement'),
    ('scholarship', 'Scholarship'),
    ('intake', 'Intake')
) AS s(section, label)
WHERE c.slug IN ('united-kingdom', 'united-states', 'canada', 'australia', 'germany')
  AND NOT EXISTS (
      SELECT 1 FROM country_sections cs
      WHERE cs.country_id = c.id AND cs.section = s.section
        AND cs.title = '[Placeholder] ' || s.label
  );
