import uuid
from typing import Any

from pydantic import BaseModel, ConfigDict, EmailStr, Field, model_validator


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


class SubjectOut(ORMModel):
    id: uuid.UUID
    name: str
    slug: str
    description: str | None = None
    icon_key: str | None = None


class SubjectListItem(SubjectOut):
    specializations: list[SpecializationOut]


class SubjectDetail(SubjectOut):
    specializations: list[SpecializationOut]
    study_levels: list[StudyLevelOut]


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
