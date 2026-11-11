from fastapi import APIRouter, Depends, HTTPException
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


@router.get("/countries/{slug}", response_model=schemas.CountryOut)
def get_country(slug: str, db: Session = Depends(get_db)):
    country = db.scalar(
        select(Country).where(Country.slug == slug, Country.status == "published")
    )
    if country is None:
        raise HTTPException(status_code=404, detail="Country not found")
    return country
