from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models.models import StudyLevel
from app.schemas import schemas

router = APIRouter(tags=["study levels"])


@router.get("/study-levels", response_model=list[schemas.StudyLevelOut])
def list_study_levels(db: Session = Depends(get_db)):
    return db.scalars(
        select(StudyLevel)
        .where(StudyLevel.status == "published")
        .order_by(StudyLevel.display_order, StudyLevel.name)
    ).all()
