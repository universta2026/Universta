-- Directus field settings for countries.is_popular (what editors see).
-- Safe to run more than once. Run AFTER `alembic upgrade head`, then: docker compose restart directus
-- Expected: DELETE -> 0 or 1 rows, INSERT -> 1 row.

BEGIN;

DELETE FROM directus_fields WHERE collection = 'countries' AND field = 'is_popular';

INSERT INTO directus_fields
    (collection, field, special, interface, options, display, display_options, readonly, hidden, sort, width, note, required)
VALUES
('countries', 'is_popular', 'cast-boolean', 'boolean',
 '{"label":"Popular"}'::json,
 'boolean', NULL,
 false, false, NULL, 'half',
 'Show on the international-student landing page',
 false);

COMMIT;

-- ---------------------------------------------------------------
-- OPTIONAL test seed (NOT run automatically): flag 3 published countries as popular.
-- These three slugs exist and are published. Change them to flag other countries.
-- ---------------------------------------------------------------
-- UPDATE countries
-- SET is_popular = true
-- WHERE status = 'published'
--   AND slug IN ('united-kingdom', 'canada', 'australia');
--
-- Undo:  UPDATE countries SET is_popular = false;
