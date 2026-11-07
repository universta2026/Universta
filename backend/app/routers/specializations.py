from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models.models import Specialization, Subject
from app.schemas import schemas

router = APIRouter(tags=["specializations"])

PUBLISHED = "published"


@router.get("/specializations", response_model=list[schemas.SpecializationOut])
def list_specializations(featured: bool | None = None, db: Session = Depends(get_db)):
    """Published specializations whose subject is also published.
    Use ?featured=true to get only the featured ones."""
    stmt = (
        select(Specialization)
        .join(Subject, Subject.id == Specialization.subject_id)
        .where(Specialization.status == PUBLISHED, Subject.status == PUBLISHED)
        .order_by(Specialization.display_order, Specialization.name)
    )
    if featured is not None:
        stmt = stmt.where(Specialization.is_featured.is_(featured))
    return db.scalars(stmt).all()


@router.get("/specializations/{slug}", response_model=schemas.SpecializationDetail)
def get_specialization(slug: str, db: Session = Depends(get_db)):
    row = db.execute(
        select(Specialization, Subject)
        .join(Subject, Subject.id == Specialization.subject_id)
        .where(
            Specialization.slug == slug,
            Specialization.status == PUBLISHED,
            Subject.status == PUBLISHED,
        )
    ).first()
    if row is None:
        raise HTTPException(status_code=404, detail="Specialization not found")

    spec, subject = row
    return schemas.SpecializationDetail(
        **schemas.SpecializationOut.model_validate(spec).model_dump(),
        subject_name=subject.name,
        subject_slug=subject.slug,
    )
