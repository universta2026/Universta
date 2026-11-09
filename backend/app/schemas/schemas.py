import uuid
from typing import Any, Optional

from pydantic import (
    BaseModel,
    ConfigDict,
    EmailStr,
    Field,
    field_validator,
    model_validator,
)


class ORMModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)


# ---------- Public content (only safe fields are exposed) ----------

class CountryOut(ORMModel):
    id: uuid.UUID
    name: str
    slug: str
    country_code: str | None = None
    description: str | None = None


class SpecializationOut(ORMModel):
    id: uuid.UUID
    name: str
    slug: str
    description: str | None = None
    is_featured: bool


class SpecializationDetail(SpecializationOut):
    subject_name: str
    subject_slug: str


class StudyLevelOut(ORMModel):
    id: uuid.UUID
    name: str
    slug: str
    description: str | None = None
    duration: str | None = None
    entry_label: Optional[str] = None
    requirements: Optional[list[str]] = None


class SubjectOut(ORMModel):
    id: uuid.UUID
    name: str
    slug: str
    description: str | None = None
    icon_key: str | None = None


class SubjectListItem(SubjectOut):
    specializations: list[SpecializationOut]


class SectionItem(ORMModel):
    """One content item of the Subject Detail page (from subject_sections)."""

    id: uuid.UUID
    title: str
    subtitle: str | None = None
    body: str | None = None  # rich text HTML: the frontend must render it with <RichText>
    url: str | None = None
    is_sponsored: bool = False

    @field_validator("url")
    @classmethod
    def allow_safe_url(cls, v: str | None) -> str | None:
        # Editors can type anything: only safe links leave the API.
        if not v:
            return None
        v = v.strip()
        if v.startswith("#") or (v.startswith("/") and not v.startswith("//")):
            return v
        if v.lower().startswith(("https://", "mailto:", "tel:")):
            return v
        return None


class SubjectDetail(SubjectOut):
    specializations: list[SpecializationOut]
    study_levels: list[StudyLevelOut]
    why: SectionItem | None = None
    industries: list[SectionItem] = Field(default_factory=list)
    companies: list[SectionItem] = Field(default_factory=list)
    courses: list[SectionItem] = Field(default_factory=list)
    destinations: list[SectionItem] = Field(default_factory=list)
    universities: list[SectionItem] = Field(default_factory=list)


class LevelPageSections(ORMModel):
    """Extra content of one Subject + Study Level page (from subject_sections)."""

    about: SectionItem | None = None
    why: SectionItem | None = None
    industries: list[SectionItem] = Field(default_factory=list)
    companies: list[SectionItem] = Field(default_factory=list)
    advertisement: SectionItem | None = None
    cta: SectionItem | None = None
    courses: list[SectionItem] = Field(default_factory=list)
    destinations: list[SectionItem] = Field(default_factory=list)
    universities: list[SectionItem] = Field(default_factory=list)


class PageContentOut(BaseModel):
    page_key: str
    sections: dict[str, dict[str, Any]]


# ---------- Enquiries ----------

class EnquiryCreate(BaseModel):
    full_name: str = Field(min_length=2, max_length=180)
    email: EmailStr | None = None
    phone: str | None = Field(default=None, max_length=30)
    preferred_country_id: uuid.UUID | None = None
    planned_intake: str | None = Field(default=None, max_length=100)
    source_page: str | None = Field(default=None, max_length=150)
    website: str | None = None  # honeypot: real users leave this empty

    @model_validator(mode="after")
    def require_contact(self):
        if not self.email and not self.phone:
            raise ValueError("Provide an email or a phone number")
        return self


class EnquiryCreated(BaseModel):
    message: str = "Thank you, we will contact you soon."
