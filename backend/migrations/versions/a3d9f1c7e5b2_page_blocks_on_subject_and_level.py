"""Page blocks (about / why / advertisement / cta) as columns on subjects and subject_study_levels

One row of `subjects` now holds the single-item blocks of the Subject page.
One row of `subject_study_levels` holds the blocks of the Subject + Level page.
Existing subject_sections rows (published, first per page and type) are copied
over and removed. Specialization pages keep using subject_sections for now.

Revision ID: a3d9f1c7e5b2
Revises: 8e2f4b6c1a93
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "a3d9f1c7e5b2"
down_revision: Union[str, Sequence[str], None] = "8e2f4b6c1a93"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

# subject_sections.section -> (column prefix, fields)
BLOCKS = {
    "about": ("about", ["title", "body"]),
    "why": ("why", ["title", "body"]),
    "advertisement": ("ad", ["title", "subtitle", "body", "url"]),
    "cta": ("cta", ["title", "subtitle", "body", "url"]),
}
LENGTHS = {"title": 200, "subtitle": 200, "url": 500}


def _columns():
    for prefix, fields in BLOCKS.values():
        for f in fields:
            col_type = sa.Text() if f == "body" else sa.String(LENGTHS[f])
            yield f"{prefix}_{f}", col_type


def upgrade() -> None:
    for table in ("subjects", "subject_study_levels"):
        for name, col_type in _columns():
            op.add_column(table, sa.Column(name, col_type, nullable=True))

    for section, (prefix, fields) in BLOCKS.items():
        sets = ", ".join(f"{prefix}_{f} = p.{f}" for f in fields)

        # Subject page: rows with no level and no specialization.
        op.execute(f"""
            WITH picked AS (
                SELECT DISTINCT ON (subject_id) *
                FROM subject_sections
                WHERE section = '{section}' AND status = 'published'
                  AND study_level_id IS NULL AND specialization_id IS NULL
                ORDER BY subject_id, display_order, title
            ), upd AS (
                UPDATE subjects s SET {sets}
                FROM picked p WHERE s.id = p.subject_id
                RETURNING p.id AS section_id
            )
            DELETE FROM subject_sections WHERE id IN (SELECT section_id FROM upd)
        """)

        # Subject + Level page: make sure the link row exists, then copy.
        op.execute(f"""
            INSERT INTO subject_study_levels (id, subject_id, study_level_id)
            SELECT gen_random_uuid(), subject_id, study_level_id
            FROM (
                SELECT DISTINCT subject_id, study_level_id FROM subject_sections
                WHERE section = '{section}' AND status = 'published'
                  AND study_level_id IS NOT NULL AND specialization_id IS NULL
            ) pairs
            ON CONFLICT ON CONSTRAINT uq_subject_study_level DO NOTHING
        """)
        op.execute(f"""
            WITH picked AS (
                SELECT DISTINCT ON (subject_id, study_level_id) *
                FROM subject_sections
                WHERE section = '{section}' AND status = 'published'
                  AND study_level_id IS NOT NULL AND specialization_id IS NULL
                ORDER BY subject_id, study_level_id, display_order, title
            ), upd AS (
                UPDATE subject_study_levels l SET {sets}
                FROM picked p
                WHERE l.subject_id = p.subject_id AND l.study_level_id = p.study_level_id
                RETURNING p.id AS section_id
            )
            DELETE FROM subject_sections WHERE id IN (SELECT section_id FROM upd)
        """)


def downgrade() -> None:
    # Copy the blocks back into subject_sections (published), then drop the columns.
    for section, (prefix, fields) in BLOCKS.items():
        cols = {f: f"{prefix}_{f}" for f in fields}
        subtitle = f"x.{cols['subtitle']}" if "subtitle" in cols else "NULL"
        url = f"x.{cols['url']}" if "url" in cols else "NULL"
        op.execute(f"""
            INSERT INTO subject_sections
                (id, subject_id, study_level_id, section, title, subtitle, body, url, status)
            SELECT gen_random_uuid(), x.id, NULL, '{section}', x.{cols['title']},
                   {subtitle}, x.{cols['body']}, {url}, 'published'
            FROM subjects x WHERE x.{cols['title']} IS NOT NULL
        """)
        op.execute(f"""
            INSERT INTO subject_sections
                (id, subject_id, study_level_id, section, title, subtitle, body, url, status)
            SELECT gen_random_uuid(), x.subject_id, x.study_level_id, '{section}', x.{cols['title']},
                   {subtitle}, x.{cols['body']}, {url}, 'published'
            FROM subject_study_levels x WHERE x.{cols['title']} IS NOT NULL
        """)

    for table in ("subject_study_levels", "subjects"):
        for name, _ in _columns():
            op.drop_column(table, name)
