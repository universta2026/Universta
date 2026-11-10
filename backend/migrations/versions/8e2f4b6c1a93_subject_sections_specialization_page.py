"""subject_sections: specialization pages (specialization_id)

Revision ID: 8e2f4b6c1a93
Revises: 5c1d7e9a2b40
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "8e2f4b6c1a93"
down_revision: Union[str, Sequence[str], None] = "5c1d7e9a2b40"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("subject_sections", sa.Column("specialization_id", sa.Uuid(), nullable=True))
    op.create_foreign_key(
        "fk_subject_sections_specialization_id", "subject_sections", "specializations",
        ["specialization_id"], ["id"], ondelete="CASCADE",
    )


def downgrade() -> None:
    op.execute("DELETE FROM subject_sections WHERE specialization_id IS NOT NULL")
    op.drop_constraint("fk_subject_sections_specialization_id", "subject_sections", type_="foreignkey")
    op.drop_column("subject_sections", "specialization_id")
