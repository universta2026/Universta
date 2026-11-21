"""country_sections: link subject / course rows to subjects and specializations

Revision ID: e6a3c9d1f4b7
Revises: d5f2b8a9c1e3
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "e6a3c9d1f4b7"
down_revision: Union[str, Sequence[str], None] = "d5f2b8a9c1e3"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("country_sections", sa.Column("subject_id", sa.Uuid(), nullable=True))
    op.add_column("country_sections", sa.Column("specialization_id", sa.Uuid(), nullable=True))
    op.create_foreign_key(
        "fk_country_sections_subject_id", "country_sections", "subjects",
        ["subject_id"], ["id"], ondelete="SET NULL",
    )
    op.create_foreign_key(
        "fk_country_sections_specialization_id", "country_sections", "specializations",
        ["specialization_id"], ["id"], ondelete="SET NULL",
    )


def downgrade() -> None:
    op.drop_constraint("fk_country_sections_specialization_id", "country_sections", type_="foreignkey")
    op.drop_constraint("fk_country_sections_subject_id", "country_sections", type_="foreignkey")
    op.drop_column("country_sections", "specialization_id")
    op.drop_column("country_sections", "subject_id")
