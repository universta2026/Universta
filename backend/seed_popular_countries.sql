-- Flags 8 countries as "popular" (shown in the Popular study destinations section of /study-abroad).
-- Safe to run more than once. Change the slugs to pick other countries.
BEGIN;
UPDATE countries SET is_popular = false;
UPDATE countries SET is_popular = true
WHERE status = 'published'
  AND slug IN ('united-kingdom', 'united-states', 'canada', 'australia', 'germany', 'ireland', 'france', 'netherlands');
COMMIT;
