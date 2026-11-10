"""
SQLAlchemy 2.0 models for the Abroad Project.

Directus owns CMS authentication, roles, permissions, files, activity and revisions.
This file defines only application tables.

Assumptions:
- PostgreSQL database.
- Directus has already initialized its system collections.
- Directus `directus_users.id` is UUID.
- SQLAlchemy 2.0.
"""

import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import (
    Boolean,
    CheckConstraint,
    DateTime,
    ForeignKey,
    Index,
    Integer,
    String,
    Text,
    UniqueConstraint,
    Uuid,
    func,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from sqlalchemy import Table, Column, Uuid


# -------------------------------------------------------------------
# BASE
# -------------------------------------------------------------------

class Base(DeclarativeBase):
    pass

class PageBlocksMixin:
    """Single-item content blocks of one page (Subject page or Subject + Level page).

    Empty title = block not shown on the website.
    """

    about_title: Mapped[Optional[str]] = mapped_column(String(200))
    about_body: Mapped[Optional[str]] = mapped_column(Text)  # rich text HTML

    why_title: Mapped[Optional[str]] = mapped_column(String(200))
    why_body: Mapped[Optional[str]] = mapped_column(Text)  # rich text HTML

    ad_title: Mapped[Optional[str]] = mapped_column(String(200))
    ad_subtitle: Mapped[Optional[str]] = mapped_column(String(200))
    ad_body: Mapped[Optional[str]] = mapped_column(Text)
    ad_url: Mapped[Optional[str]] = mapped_column(String(500))

    cta_title: Mapped[Optional[str]] = mapped_column(String(200))
    cta_subtitle: Mapped[Optional[str]] = mapped_column(String(200))  # button text
    cta_body: Mapped[Optional[str]] = mapped_column(Text)
    cta_url: Mapped[Optional[str]] = mapped_column(String(500))


#Directus

directus_users = Table(
    "directus_users",
    Base.metadata,
    Column("id", Uuid(as_uuid=True), primary_key=True),
    info={"managed_by": "directus"},
)


# -------------------------------------------------------------------
# COUNTRIES
# -------------------------------------------------------------------

class Country(Base):
    __tablename__ = "countries"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    name: Mapped[str] = mapped_column(String(150), nullable=False)
    slug: Mapped[str] = mapped_column(String(180), unique=True, nullable=False)
    country_code: Mapped[Optional[str]] = mapped_column(String(3))
    description: Mapped[Optional[str]] = mapped_column(Text)

    status: Mapped[str] = mapped_column(
        String(30), nullable=False, default="draft", server_default="draft"
    )
    display_order: Mapped[int] = mapped_column(
        Integer, nullable=False, default=0, server_default="0"
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    updated_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), onupdate=func.now()
    )

    enquiries: Mapped[list["Enquiry"]] = relationship(back_populates="preferred_country")

    __table_args__ = (
        CheckConstraint(
            "status IN ('draft', 'pending_review', 'published', 'archived')",
            name="ck_countries_status",
        ),
        Index("ix_countries_status_display_order", "status", "display_order"),
    )


# -------------------------------------------------------------------
# SUBJECTS
# -------------------------------------------------------------------

class Subject(PageBlocksMixin, Base):
    __tablename__ = "subjects"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    name: Mapped[str] = mapped_column(String(150), nullable=False)
    slug: Mapped[str] = mapped_column(String(180), unique=True, nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text)
    icon_key: Mapped[Optional[str]] = mapped_column(String(100))

    status: Mapped[str] = mapped_column(
        String(30), nullable=False, default="draft", server_default="draft"
    )
    display_order: Mapped[int] = mapped_column(
        Integer, nullable=False, default=0, server_default="0"
    )

    # These UUIDs reference Directus system users.
    # Directus must have been initialized before creating these FK constraints.
    created_by: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("directus_users.id", ondelete="SET NULL"),
    )
    updated_by: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("directus_users.id", ondelete="SET NULL"),
    )
    reviewed_by: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("directus_users.id", ondelete="SET NULL"),
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    updated_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), onupdate=func.now()
    )
    published_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))

    specializations: Mapped[list["Specialization"]] = relationship(
        back_populates="subject", cascade="all, delete-orphan"
    )
    study_level_links: Mapped[list["SubjectStudyLevel"]] = relationship(
        back_populates="subject", cascade="all, delete-orphan"
    )
    popular_searches: Mapped[list["PopularSearch"]] = relationship(
        back_populates="subject"
    )
    sections: Mapped[list["SubjectSection"]] = relationship(
        back_populates="subject", cascade="all, delete-orphan"
    )

    __table_args__ = (
        CheckConstraint(
            "status IN ('draft', 'pending_review', 'published', 'archived')",
            name="ck_subjects_status",
        ),
        Index("ix_subjects_status_display_order", "status", "display_order"),
    )


# -------------------------------------------------------------------
# SPECIALIZATIONS
# -------------------------------------------------------------------

class Specialization(Base):
    __tablename__ = "specializations"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    subject_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("subjects.id", ondelete="CASCADE"),
        nullable=False,
    )

    name: Mapped[str] = mapped_column(String(180), nullable=False)
    slug: Mapped[str] = mapped_column(String(200), unique=True, nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text)

    is_featured: Mapped[bool] = mapped_column(
        Boolean, nullable=False, default=False, server_default="false"
    )
    status: Mapped[str] = mapped_column(
        String(30), nullable=False, default="draft", server_default="draft"
    )
    display_order: Mapped[int] = mapped_column(
        Integer, nullable=False, default=0, server_default="0"
    )

    created_by: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("directus_users.id", ondelete="SET NULL")
    )
    updated_by: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("directus_users.id", ondelete="SET NULL")
    )
    reviewed_by: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("directus_users.id", ondelete="SET NULL")
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    updated_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), onupdate=func.now()
    )
    published_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))

    subject: Mapped["Subject"] = relationship(back_populates="specializations")
    popular_searches: Mapped[list["PopularSearch"]] = relationship(
        back_populates="specialization"
    )

    __table_args__ = (
        CheckConstraint(
            "status IN ('draft', 'pending_review', 'published', 'archived')",
            name="ck_specializations_status",
        ),
        Index(
            "ix_specializations_subject_status_order",
            "subject_id",
            "status",
            "display_order",
        ),
    )


# -------------------------------------------------------------------
# STUDY LEVELS
# -------------------------------------------------------------------

class StudyLevel(Base):
    __tablename__ = "study_levels"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    name: Mapped[str] = mapped_column(String(150), nullable=False)
    # Adding  these two new columns --> 11/09/2026  9:07 AM
    entry_label: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    requirements: Mapped[Optional[list[str]]] = mapped_column(JSONB, nullable=True)
    slug: Mapped[str] = mapped_column(String(180), unique=True, nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text)
    duration: Mapped[Optional[str]] = mapped_column(String(100))

    status: Mapped[str] = mapped_column(
        String(30), nullable=False, default="draft", server_default="draft"
    )
    display_order: Mapped[int] = mapped_column(
        Integer, nullable=False, default=0, server_default="0"
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    updated_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), onupdate=func.now()
    )

    subject_links: Mapped[list["SubjectStudyLevel"]] = relationship(
        back_populates="study_level", cascade="all, delete-orphan"
    )

    __table_args__ = (
        CheckConstraint(
            "status IN ('draft', 'pending_review', 'published', 'archived')",
            name="ck_study_levels_status",
        ),
        Index("ix_study_levels_status_display_order", "status", "display_order"),
    )


# -------------------------------------------------------------------
# SUBJECT <-> STUDY LEVEL (MANY-TO-MANY)
# Uses a single UUID PK for Directus compatibility.
# -------------------------------------------------------------------

class SubjectStudyLevel(PageBlocksMixin, Base):
    __tablename__ = "subject_study_levels"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    subject_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("subjects.id", ondelete="CASCADE"),
        nullable=False,
    )
    study_level_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("study_levels.id", ondelete="CASCADE"),
        nullable=False,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )

    subject: Mapped["Subject"] = relationship(back_populates="study_level_links")
    study_level: Mapped["StudyLevel"] = relationship(back_populates="subject_links")

    __table_args__ = (
        UniqueConstraint(
            "subject_id", "study_level_id", name="uq_subject_study_level"
        ),
    )


# -------------------------------------------------------------------
# SUBJECT SECTIONS
# Extra content blocks for the Subject Detail page. One row = one item
# (one "why" block, one industry, one company, one course, ...).
# Editors manage them from the subject screen in Directus.
# -------------------------------------------------------------------

class SubjectSection(Base):
    __tablename__ = "subject_sections"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    subject_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("subjects.id", ondelete="CASCADE"),
        nullable=False,
    )
    # Empty = shown on the subject page. Set = shown only on that study-level page
    # of the subject (e.g. Engineering + Bachelors).
    study_level_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("study_levels.id", ondelete="CASCADE"),
        nullable=True,
    )
    # Set = shown only on that specialization's page (e.g. Civil Engineering).
    specialization_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("specializations.id", ondelete="CASCADE"),
        nullable=True,
    )
    # about | why | industry | company | advertisement | cta | course | destination | university
    section: Mapped[str] = mapped_column(String(30), nullable=False)

    title: Mapped[str] = mapped_column(String(200), nullable=False)
    subtitle: Mapped[Optional[str]] = mapped_column(String(200))
    body: Mapped[Optional[str]] = mapped_column(Text)  # rich text HTML
    url: Mapped[Optional[str]] = mapped_column(String(500))
    is_sponsored: Mapped[bool] = mapped_column(
        Boolean, nullable=False, default=False, server_default="false"
    )

    status: Mapped[str] = mapped_column(
        String(30), nullable=False, default="draft", server_default="draft"
    )
    display_order: Mapped[int] = mapped_column(
        Integer, nullable=False, default=0, server_default="0"
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    updated_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), onupdate=func.now()
    )

    subject: Mapped["Subject"] = relationship(back_populates="sections")

    __table_args__ = (
        CheckConstraint(
            "section IN ('about', 'why', 'industry', 'company', 'advertisement', 'cta', 'course', 'destination', 'university')",
            name="ck_subject_sections_section",
        ),
        CheckConstraint(
            "status IN ('draft', 'pending_review', 'published', 'archived')",
            name="ck_subject_sections_status",
        ),
        Index(
            "ix_subject_sections_subject_section_status_order",
            "subject_id",
            "study_level_id",
            "section",
            "status",
            "display_order",
        ),
    )


# -------------------------------------------------------------------
# POPULAR SEARCHES
# -------------------------------------------------------------------

class PopularSearch(Base):
    __tablename__ = "popular_searches"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    label: Mapped[str] = mapped_column(String(180), nullable=False)
    target_type: Mapped[str] = mapped_column(String(30), nullable=False)

    subject_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("subjects.id", ondelete="CASCADE")
    )
    specialization_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("specializations.id", ondelete="CASCADE"),
    )

    display_order: Mapped[int] = mapped_column(
        Integer, nullable=False, default=0, server_default="0"
    )
    is_active: Mapped[bool] = mapped_column(
        Boolean, nullable=False, default=True, server_default="true"
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    updated_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), onupdate=func.now()
    )

    subject: Mapped[Optional["Subject"]] = relationship(
        back_populates="popular_searches"
    )
    specialization: Mapped[Optional["Specialization"]] = relationship(
        back_populates="popular_searches"
    )

    __table_args__ = (
        CheckConstraint(
            "target_type IN ('subject', 'specialization')",
            name="ck_popular_searches_target_type",
        ),
        CheckConstraint(
            """
            (target_type = 'subject'
                AND subject_id IS NOT NULL
                AND specialization_id IS NULL)
            OR
            (target_type = 'specialization'
                AND specialization_id IS NOT NULL
                AND subject_id IS NULL)
            """,
            name="ck_popular_searches_target_reference",
        ),
        Index("ix_popular_searches_active_order", "is_active", "display_order"),
    )


# -------------------------------------------------------------------
# PAGE CONTENT
# -------------------------------------------------------------------

class PageContent(Base):
    __tablename__ = "page_content"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )

    page_key: Mapped[str] = mapped_column(String(100), nullable=False)
    section_key: Mapped[str] = mapped_column(String(100), nullable=False)
    content_key: Mapped[str] = mapped_column(String(100), nullable=False)

    content_value: Mapped[Optional[dict]] = mapped_column(JSONB)

    status: Mapped[str] = mapped_column(
        String(30), nullable=False, default="draft", server_default="draft"
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    updated_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), onupdate=func.now()
    )

    __table_args__ = (
        UniqueConstraint(
            "page_key",
            "section_key",
            "content_key",
            name="uq_page_section_content",
        ),
        CheckConstraint(
            "status IN ('draft', 'pending_review', 'published', 'archived')",
            name="ck_page_content_status",
        ),
    )


# -------------------------------------------------------------------
# ENQUIRIES
# -------------------------------------------------------------------

class Enquiry(Base):
    __tablename__ = "enquiries"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )

    full_name: Mapped[str] = mapped_column(String(180), nullable=False)
    email: Mapped[Optional[str]] = mapped_column(String(255))
    phone: Mapped[Optional[str]] = mapped_column(String(30))

    preferred_country_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("countries.id", ondelete="SET NULL")
    )
    planned_intake: Mapped[Optional[str]] = mapped_column(String(100))

    source_page: Mapped[Optional[str]] = mapped_column(String(150))
    status: Mapped[str] = mapped_column(
        String(30), nullable=False, default="new", server_default="new"
    )

    # Directus employee assigned to handle this enquiry.
    assigned_to: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("directus_users.id", ondelete="SET NULL")
    )
    internal_notes: Mapped[Optional[str]] = mapped_column(Text)

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    updated_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), onupdate=func.now()
    )

    preferred_country: Mapped[Optional["Country"]] = relationship(
        back_populates="enquiries"
    )

    __table_args__ = (
        CheckConstraint(
            "status IN ('new', 'contacted', 'in_progress', 'closed')",
            name="ck_enquiries_status",
        ),
        Index("ix_enquiries_status_created_at", "status", "created_at"),
        Index("ix_enquiries_assigned_to", "assigned_to"),
    )
