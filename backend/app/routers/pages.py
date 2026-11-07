from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models.models import PageContent
from app.schemas import schemas

router = APIRouter(tags=["page content"])


@router.get("/pages/{page_key}", response_model=schemas.PageContentOut)
def get_page_content(page_key: str, db: Session = Depends(get_db)):
    """Editable page text from the page_content table, grouped by section:
    {"sections": {"hero": {"title": "...", "intro": "..."}}}"""
    rows = db.scalars(
        select(PageContent).where(
            PageContent.page_key == page_key,
            PageContent.status == "published",
        )
    ).all()
    if not rows:
        raise HTTPException(status_code=404, detail="Page not found")

    sections: dict[str, dict] = {}
    for row in rows:
        sections.setdefault(row.section_key, {})[row.content_key] = row.content_value
    return schemas.PageContentOut(page_key=page_key, sections=sections)
