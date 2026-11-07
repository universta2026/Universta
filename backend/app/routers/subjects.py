from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models.models import Specialization, StudyLevel, Subject, SubjectStudyLevel
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

    return schemas.SubjectDetail(
        **schemas.SubjectOut.model_validate(subject).model_dump(),
        specializations=[
            schemas.SpecializationOut.model_validate(s) for s in specializations
        ],
        study_levels=[schemas.StudyLevelOut.model_validate(s) for s in study_levels],
    )


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
