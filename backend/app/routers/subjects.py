import uuid

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models.models import (
    Specialization,
    StudyLevel,
    Subject,
    SubjectSection,
    SubjectStudyLevel,
)
from app.schemas import schemas

router = APIRouter(tags=["subjects"])

PUBLISHED = "published"


def get_published_subject(db: Session, slug: str) -> Subject:
    subject = db.scalar(
        select(Subject).where(Subject.slug == slug, Subject.status == PUBLISHED)
    )
    if subject is None:
        raise HTTPException(status_code=404, detail="Subject not found")
    return subject


def owner_blocks(owner) -> dict[str, schemas.SectionItem | None]:
    """about / why / advertisement / cta stored as columns on a Subject or SubjectStudyLevel row.

    A block with an empty title is not shown. The id is derived from the owner row,
    so it is stable between requests (the frontend uses it as a React key).
    """
    def block(name: str, prefix: str):
        title = (getattr(owner, f"{prefix}_title") or "").strip()
        if not title:
            return None
        return schemas.SectionItem(
            id=uuid.uuid5(owner.id, name),
            title=title,
            subtitle=getattr(owner, f"{prefix}_subtitle", None),
            body=getattr(owner, f"{prefix}_body", None),
            url=getattr(owner, f"{prefix}_url", None),
        )

    return {
        "about": block("about", "about"),
        "why": block("why", "why"),
        "advertisement": block("advertisement", "ad"),
        "cta": block("cta", "cta"),
    }


def build_page_sections(rows, owner=None) -> schemas.LevelPageSections:
    """Group published subject_sections rows into the blocks of a page.

    `owner` (Subject / SubjectStudyLevel row) supplies about / why / advertisement / cta
    from its own columns. Without it (specialization pages) they come from the rows.
    """
    by_section: dict[str, list[schemas.SectionItem]] = {}
    for row in rows:
        by_section.setdefault(row.section, []).append(
            schemas.SectionItem.model_validate(row)
        )

    def first(name: str):  # about / why / advertisement / cta: only the first one is shown
        items = by_section.get(name, [])
        return items[0] if items else None

    blocks = owner_blocks(owner) if owner is not None else {
        name: first(name)
        for name in ("about", "why", "advertisement", "cta")
    }
    return schemas.LevelPageSections(
        about=blocks["about"],
        why=blocks["why"],
        industries=by_section.get("industry", []),
        companies=by_section.get("company", []),
        advertisement=blocks["advertisement"],
        cta=blocks["cta"],
        courses=by_section.get("course", []),
        destinations=by_section.get("destination", []),
        universities=by_section.get("university", []),
    )


@router.get("/subjects", response_model=list[schemas.SubjectListItem])
def list_subjects(db: Session = Depends(get_db)):
    """All published subjects, each with its published specializations."""
    subjects = db.scalars(
        select(Subject)
        .where(Subject.status == PUBLISHED)
        .order_by(Subject.display_order, Subject.name)
    ).all()

    specs = db.scalars(
        select(Specialization)
        .where(
            Specialization.status == PUBLISHED,
            Specialization.subject_id.in_([s.id for s in subjects]),
        )
        .order_by(Specialization.display_order, Specialization.name)
    ).all()

    grouped: dict = {}
    for sp in specs:
        grouped.setdefault(sp.subject_id, []).append(
            schemas.SpecializationOut.model_validate(sp)
        )

    return [
        schemas.SubjectListItem(
            **schemas.SubjectOut.model_validate(s).model_dump(),
            specializations=grouped.get(s.id, []),
        )
        for s in subjects
    ]


@router.get("/subjects/{slug}", response_model=schemas.SubjectDetail)
def get_subject(slug: str, db: Session = Depends(get_db)):
    subject = get_published_subject(db, slug)

    specializations = db.scalars(
        select(Specialization)
        .where(
            Specialization.subject_id == subject.id,
            Specialization.status == PUBLISHED,
        )
        .order_by(Specialization.display_order, Specialization.name)
    ).all()

    study_levels = db.scalars(
        select(StudyLevel)
        .join(SubjectStudyLevel, SubjectStudyLevel.study_level_id == StudyLevel.id)
        .where(
            SubjectStudyLevel.subject_id == subject.id,
            StudyLevel.status == PUBLISHED,
        )
        .order_by(StudyLevel.display_order, StudyLevel.name)
    ).all()

    # Extra content blocks (why / industry / company / course / destination / university)
    section_rows = db.scalars(
        select(SubjectSection)
        .where(
            SubjectSection.subject_id == subject.id,
            # level / specialization rows belong to their own pages, not this one
            SubjectSection.study_level_id.is_(None),
            SubjectSection.specialization_id.is_(None),
            SubjectSection.status == PUBLISHED,
        )
        .order_by(SubjectSection.display_order, SubjectSection.title)
    ).all()

    by_section: dict[str, list[schemas.SectionItem]] = {}
    for row in section_rows:
        by_section.setdefault(row.section, []).append(
            schemas.SectionItem.model_validate(row)
        )
    blocks = owner_blocks(subject)

    return schemas.SubjectDetail(
        **schemas.SubjectOut.model_validate(subject).model_dump(),
        specializations=[
            schemas.SpecializationOut.model_validate(s) for s in specializations
        ],
        study_levels=[schemas.StudyLevelOut.model_validate(s) for s in study_levels],
        about=blocks["about"],
        why=blocks["why"],
        advertisement=blocks["advertisement"],
        cta=blocks["cta"],
        industries=by_section.get("industry", []),
        companies=by_section.get("company", []),
        courses=by_section.get("course", []),
        destinations=by_section.get("destination", []),
        universities=by_section.get("university", []),
    )


@router.get(
    "/subjects/{slug}/levels/{level_slug}",
    response_model=schemas.LevelPageSections,
)
def get_subject_level_sections(slug: str, level_slug: str, db: Session = Depends(get_db)):
    """Extra content blocks of one Subject + Study Level page.

    A level with no row in study_levels (the frontend adds MBA / PGDM itself)
    simply has no blocks: it returns an empty page, not a 404.
    """
    subject = get_published_subject(db, slug)
    level = db.scalar(select(StudyLevel).where(StudyLevel.slug == level_slug))
    if level is None:
        return schemas.LevelPageSections()
    link = db.scalar(
        select(SubjectStudyLevel).where(
            SubjectStudyLevel.subject_id == subject.id,
            SubjectStudyLevel.study_level_id == level.id,
        )
    )

    rows = db.scalars(
        select(SubjectSection)
        .where(
            SubjectSection.subject_id == subject.id,
            SubjectSection.study_level_id == level.id,
            SubjectSection.specialization_id.is_(None),
            SubjectSection.status == PUBLISHED,
        )
        .order_by(SubjectSection.display_order, SubjectSection.title)
    ).all()
    return build_page_sections(rows, owner=link)


@router.get(
    "/subjects/{slug}/specializations/{spec_slug}/levels/{level_slug}/sections",
    response_model=schemas.LevelPageSections,
)
def get_specialization_level_sections(
    slug: str, spec_slug: str, level_slug: str, db: Session = Depends(get_db)
):
    """Extra content blocks of one Specialization + Study Level page
    (/subjects/engineering/civil-engineering/bachelors)."""
    subject = get_published_subject(db, slug)
    spec = db.scalar(
        select(Specialization).where(
            Specialization.subject_id == subject.id,
            Specialization.slug == spec_slug,
            Specialization.status == PUBLISHED,
        )
    )
    if spec is None:
        raise HTTPException(status_code=404, detail="Specialization not found")
    level = db.scalar(select(StudyLevel).where(StudyLevel.slug == level_slug))
    if level is None:  # MBA / PGDM are added by the frontend: no blocks for them
        return schemas.LevelPageSections()

    rows = db.scalars(
        select(SubjectSection)
        .where(
            SubjectSection.subject_id == subject.id,
            SubjectSection.specialization_id == spec.id,
            SubjectSection.study_level_id == level.id,
            SubjectSection.status == PUBLISHED,
        )
        .order_by(SubjectSection.display_order, SubjectSection.title)
    ).all()
    return build_page_sections(rows)


@router.get(
    "/subjects/{slug}/specializations/{spec_slug}/sections",
    response_model=schemas.LevelPageSections,
)
def get_specialization_sections(slug: str, spec_slug: str, db: Session = Depends(get_db)):
    """Extra content blocks of one Specialization page (same shape as a level page)."""
    subject = get_published_subject(db, slug)
    spec = db.scalar(
        select(Specialization).where(
            Specialization.subject_id == subject.id,
            Specialization.slug == spec_slug,
            Specialization.status == PUBLISHED,
        )
    )
    if spec is None:
        raise HTTPException(status_code=404, detail="Specialization not found")

    rows = db.scalars(
        select(SubjectSection)
        .where(
            SubjectSection.subject_id == subject.id,
            SubjectSection.specialization_id == spec.id,
            SubjectSection.study_level_id.is_(None),
            SubjectSection.status == PUBLISHED,
        )
        .order_by(SubjectSection.display_order, SubjectSection.title)
    ).all()
    return build_page_sections(rows)


@router.get(
    "/subjects/{slug}/specializations",
    response_model=list[schemas.SpecializationOut],
)
def list_subject_specializations(slug: str, db: Session = Depends(get_db)):
    subject = get_published_subject(db, slug)
    return db.scalars(
        select(Specialization)
        .where(
            Specialization.subject_id == subject.id,
            Specialization.status == PUBLISHED,
        )
        .order_by(Specialization.display_order, Specialization.name)
    ).all()
