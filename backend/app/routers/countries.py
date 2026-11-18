import uuid

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models.models import Country, CountrySection
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


# country_sections.section value -> field name in the response
SECTION_FIELDS = {
    "why": "why",
    "subject": "subjects",
    "course": "courses",
    "university": "universities",
    "exam": "exams",
    "scholarship": "scholarships",
    "visa": "visa",
    "application": "applications",
    "intake": "intakes",
    "cost": "costs",
    "eligibility": "eligibility",
}


# Blocks edited as fields on the country itself (title + body)
COLUMN_BLOCKS = ("why", "visa", "application", "cost", "eligibility")


@router.get("/countries/{slug}/sections", response_model=schemas.CountrySections)
def get_country_sections(slug: str, db: Session = Depends(get_db)):
    """Published content blocks of /studyabroad/<slug>, e.g. {"universities": [...], "visa": [...]}."""
    country = db.scalar(
        select(Country).where(Country.slug == slug, Country.status == "published")
    )
    if country is None:
        raise HTTPException(status_code=404, detail="Country not found")

    rows = db.scalars(
        select(CountrySection)
        .where(
            CountrySection.country_id == country.id,
            CountrySection.status == "published",
        )
        .order_by(CountrySection.display_order, CountrySection.title)
    ).all()

    grouped: dict[str, list[schemas.SectionItem]] = {}

    # Text blocks stored as columns on the country (first in their list).
    for section in COLUMN_BLOCKS:
        title = (getattr(country, f"{section}_title") or "").strip()
        if title:
            grouped[SECTION_FIELDS[section]] = [
                schemas.SectionItem(
                    id=uuid.uuid5(country.id, section),
                    title=title,
                    body=getattr(country, f"{section}_body"),
                )
            ]
    for row in rows:
        grouped.setdefault(SECTION_FIELDS[row.section], []).append(
            schemas.SectionItem.model_validate(row)
        )
    return schemas.CountrySections(**grouped)
