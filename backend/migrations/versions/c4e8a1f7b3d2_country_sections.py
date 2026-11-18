"""country_sections

Content blocks of the Study Abroad country pages (/studyabroad/<country>).

Revision ID: c4e8a1f7b3d2
Revises: 92c3baf3c566
Create Date: 2026-11-17 12:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'c4e8a1f7b3d2'
down_revision: Union[str, Sequence[str], None] = '92c3baf3c566'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.create_table('country_sections',
    sa.Column('id', sa.Uuid(), nullable=False),
    sa.Column('country_id', sa.Uuid(), nullable=False),
    sa.Column('section', sa.String(length=30), nullable=False),
    sa.Column('title', sa.String(length=200), nullable=False),
    sa.Column('subtitle', sa.String(length=200), nullable=True),
    sa.Column('body', sa.Text(), nullable=True),
    sa.Column('url', sa.String(length=500), nullable=True),
    sa.Column('is_sponsored', sa.Boolean(), server_default='false', nullable=False),
    sa.Column('status', sa.String(length=30), server_default='draft', nullable=False),
    sa.Column('display_order', sa.Integer(), server_default='0', nullable=False),
    sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True),
    sa.CheckConstraint("section IN ('why', 'subject', 'course', 'university', 'exam', 'scholarship', 'visa', 'application', 'intake', 'cost', 'eligibility')", name='ck_country_sections_section'),
    sa.CheckConstraint("status IN ('draft', 'pending_review', 'published', 'archived')", name='ck_country_sections_status'),
    sa.ForeignKeyConstraint(['country_id'], ['countries.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index('ix_country_sections_country_section_status_order', 'country_sections', ['country_id', 'section', 'status', 'display_order'], unique=False)


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_index('ix_country_sections_country_section_status_order', table_name='country_sections')
    op.drop_table('country_sections')
