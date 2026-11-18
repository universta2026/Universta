"""Country text blocks (why / visa / application / cost / eligibility) as columns on countries

Same idea as the subject page blocks: one editable field group per block on the country
record. Published country_sections rows of those types (first per country) are copied
over and removed. List blocks (subject, course, university, exam, scholarship, intake)
stay in country_sections.

Revision ID: d5f2b8a9c1e3
Revises: c4e8a1f7b3d2
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

revision: str = "d5f2b8a9c1e3"
down_revision: Union[str, Sequence[str], None] = "c4e8a1f7b3d2"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

BLOCKS = ("why", "visa", "application", "cost", "eligibility")


def upgrade() -> None:
    for b in BLOCKS:
        op.add_column("countries", sa.Column(f"{b}_title", sa.String(200), nullable=True))
        op.add_column("countries", sa.Column(f"{b}_body", sa.Text(), nullable=True))

    for b in BLOCKS:
        op.execute(f"""
            WITH picked AS (
                SELECT DISTINCT ON (country_id) *
                FROM country_sections
                WHERE section = '{b}' AND status = 'published'
                ORDER BY country_id, display_order, title
            ), upd AS (
                UPDATE countries c SET {b}_title = p.title, {b}_body = p.body
                FROM picked p WHERE c.id = p.country_id
                RETURNING p.id AS section_id
            )
            DELETE FROM country_sections WHERE id IN (SELECT section_id FROM upd)
        """)


def downgrade() -> None:
    for b in BLOCKS:
        op.drop_column("countries", f"{b}_body")
        op.drop_column("countries", f"{b}_title")
