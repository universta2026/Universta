from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.cors.config import settings
from app.routers import (
    countries,
    enquireies,
    pages,
    specializations,
    studylevels,
    subjects,
)

app = FastAPI(title="Universta API")

# Lets the Next.js website (and the browser) call this API.
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)

for module in (subjects, specializations, studylevels, countries, pages, enquireies):
    app.include_router(module.router, prefix="/api")


@app.get("/health")
def health():
    return {"status": "ok"}
