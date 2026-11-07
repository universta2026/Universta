"""auto slug triggers

Creates the slug automatically from the name when the slug is left empty
(subjects, specializations, countries, study_levels). Works for Directus,
FastAPI and plain SQL inserts, because it lives in the database.

Revision ID: b7c1a9d2e4f1
Revises: 3de303a568af
Create Date: 2026-11-08 10:00:00.000000

"""
from typing import Sequence, Union

from alembic import op

# revision identifiers, used by Alembic.
revision: str = 'b7c1a9d2e4f1'
down_revision: Union[str, Sequence[str], None] = '3de303a568af'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

TABLES = ("subjects", "specializations", "countries", "study_levels")

SLUGIFY_FN = """
CREATE OR REPLACE FUNCTION slugify_text(txt text) RETURNS text
LANGUAGE sql IMMUTABLE AS $$
  SELECT btrim(
    regexp_replace(
      lower(replace(replace(coalesce(txt, ''), '&', ' '), '''', '')),
      '[^a-z0-9]+', '-', 'g'),
    '-')
$$
"""

TRIGGER_FN = """
CREATE OR REPLACE FUNCTION set_slug_from_name() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
  base text;
  candidate text;
  n integer DEFAULT 1;
  taken boolean;
BEGIN
  -- A slug that was typed by a person: just tidy it (lowercase, hyphens).
  IF NEW.slug IS NOT NULL THEN
    NEW.slug = slugify_text(NEW.slug);
  END IF;
  IF NEW.slug IS NOT NULL AND NEW.slug <> '' THEN
    RETURN NEW;
  END IF;

  -- Slug left empty: build it from the name.
  base = slugify_text(NEW.name);
  IF base = '' THEN
    RAISE EXCEPTION 'Cannot create a slug: the name needs at least one letter or number';
  END IF;

  -- Make it unique: data-science, data-science-2, data-science-3 ...
  candidate = base;
  LOOP
    EXECUTE 'SELECT EXISTS (SELECT 1 FROM ' || quote_ident(TG_TABLE_NAME)
         || ' WHERE slug = $1 AND id <> $2)'
      INTO taken
      USING candidate, COALESCE(NEW.id, CAST('00000000-0000-0000-0000-000000000000' AS uuid));
    EXIT WHEN NOT taken;
    n = n + 1;
    candidate = base || '-' || n;
  END LOOP;

  NEW.slug = candidate;
  RETURN NEW;
END
$$
"""


def upgrade() -> None:
    op.execute(SLUGIFY_FN)
    op.execute(TRIGGER_FN)
    for table in TABLES:
        op.execute(
            f"CREATE TRIGGER trg_{table}_set_slug "
            f"BEFORE INSERT OR UPDATE ON {table} "
            f"FOR EACH ROW EXECUTE FUNCTION set_slug_from_name()"
        )


def downgrade() -> None:
    for table in TABLES:
        op.execute(f"DROP TRIGGER IF EXISTS trg_{table}_set_slug ON {table}")
    op.execute("DROP FUNCTION IF EXISTS set_slug_from_name()")
    op.execute("DROP FUNCTION IF EXISTS slugify_text(text)")
