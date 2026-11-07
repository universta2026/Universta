from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models.models import Country
from app.schemas import schemas

router = APIRouter(tags=["countries"])


@router.get("/countries", response_model=list[schemas.CountryOut])
def list_countries(db: Session = Depends(get_db)):
    return db.scalars(
        select(Country)
        .where(Country.status == "published")
        .order_by(Country.display_order, Country.name)
    ).all()
