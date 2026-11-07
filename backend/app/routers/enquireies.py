from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models.models import Country, Enquiry
from app.schemas import schemas

router = APIRouter(tags=["enquiries"])


@router.post("/enquiries", response_model=schemas.EnquiryCreated, status_code=201)
def create_enquiry(payload: schemas.EnquiryCreate, db: Session = Depends(get_db)):
    # Honeypot: bots fill hidden fields. Pretend success and store nothing.
    if payload.website:
        return schemas.EnquiryCreated()

    if payload.preferred_country_id is not None:
        found = db.scalar(
            select(Country.id).where(
                Country.id == payload.preferred_country_id,
                Country.status == "published",
            )
        )
        if found is None:
            raise HTTPException(status_code=400, detail="Invalid preferred country")

    db.add(
        Enquiry(
            full_name=payload.full_name.strip(),
            email=payload.email,
            phone=payload.phone,
            preferred_country_id=payload.preferred_country_id,
            planned_intake=payload.planned_intake,
            source_page=payload.source_page,
        )
    )
    db.commit()
    return schemas.EnquiryCreated()
