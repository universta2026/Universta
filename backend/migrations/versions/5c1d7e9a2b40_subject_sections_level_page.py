"""subject_sections: study level pages (study_level_id + about/advertisement/cta)

Revision ID: 5c1d7e9a2b40
Revises: 17ebcb2267f9
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "5c1d7e9a2b40"
down_revision: Union[str, Sequence[str], None] = "17ebcb2267f9"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

OLD = "section IN ('why', 'industry', 'company', 'course', 'destination', 'university')"
NEW = "section IN ('about', 'why', 'industry', 'company', 'advertisement', 'cta', 'course', 'destination', 'university')"
INDEX = "ix_subject_sections_subject_section_status_order"


def upgrade() -> None:
    op.add_column("subject_sections", sa.Column("study_level_id", sa.Uuid(), nullable=True))
    op.create_foreign_key(
        "fk_subject_sections_study_level_id", "subject_sections", "study_levels",
        ["study_level_id"], ["id"], ondelete="CASCADE",
    )
    op.drop_constraint("ck_subject_sections_section", "subject_sections", type_="check")
    op.create_check_constraint("ck_subject_sections_section", "subject_sections", NEW)
    op.drop_index(INDEX, table_name="subject_sections")
    op.create_index(
        INDEX, "subject_sections",
        ["subject_id", "study_level_id", "section", "status", "display_order"],
    )


def downgrade() -> None:
    op.execute(
        "DELETE FROM subject_sections "
        "WHERE study_level_id IS NOT NULL OR section IN ('about', 'advertisement', 'cta')"
    )
    op.drop_index(INDEX, table_name="subject_sections")
    op.create_index(
        INDEX, "subject_sections",
        ["subject_id", "section", "status", "display_order"],
    )
    op.drop_constraint("ck_subject_sections_section", "subject_sections", type_="check")
    op.create_check_constraint("ck_subject_sections_section", "subject_sections", OLD)
    op.drop_constraint("fk_subject_sections_study_level_id", "subject_sections", type_="foreignkey")
    op.drop_column("subject_sections", "study_level_id")
