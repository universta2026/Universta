# Universta ("Abroad Project") - Project Documentation

Purpose of this document: give a developer or an AI assistant everything needed to understand the code,
the folder structure, the data model, the API and the workflow of this project.
Read sections 1-4 first. Sections 5-9 are reference. Section 12 lists what is NOT done yet.

---

## 1. What the project is

Universta is a study-abroad website. Students browse **subjects** (fields of study), their
**specializations**, **study levels** (Foundation, Bachelor's, Master's...), and later universities,
countries and enquiries.

Content is written by non-technical editors in a CMS (**Directus**) and shown on a website (**Next.js**)
through an API (**FastAPI**). Everything is stored in one **PostgreSQL** database.

Team split:
- Backend person: PostgreSQL schema, Alembic migrations, FastAPI, Directus configuration, seed data.
- Frontend person (a teammate): the Next.js website and its design system.

Development machine: Windows, VS Code, PowerShell, Docker Desktop. Project root: `D:\Projects\Universta`.

---

## 2. Architecture

```
 Editors (browser)                       Visitors (browser)
        |                                        |
        v                                        v
   Directus CMS  (port 8055)             Next.js website (port 3000)
        |                                        |  server-side fetch
        | writes content                         v
        |                                 FastAPI (port 8000)  /api/...
        |                                        |
        +--------------> PostgreSQL <------------+
                         (Docker, host port 5433)
                    one database named "abroad"
```

Key decisions:
1. **One PostgreSQL database shared by Directus and FastAPI.** Directus creates its own `directus_*`
   tables. The application tables (`subjects`, `countries`...) are defined in SQLAlchemy and created by Alembic.
2. **FastAPI reads the database directly with SQLAlchemy. It does NOT call the Directus API.**
3. **Schema owner = SQLAlchemy models + Alembic.** Never create or alter application tables from the Directus
   Data Model UI. In Directus only change presentation (interfaces, labels, dropdown choices, special flags).
4. **Directus owns authentication, roles, files and activity.** Application tables reference Directus users
   through foreign keys to `directus_users.id` (UUID).
5. **The website only shows `status = 'published'` content.** The API filters this; the website never sees drafts.
6. **Frontend never talks to the database.** It calls FastAPI only (server-side `fetch` in Next.js server components).

---

## 3. Tech stack

| Layer | Technology |
|---|---|
| Database | PostgreSQL 16 (Docker image `postgres:16`) |
| CMS | Directus 11.x (Docker image `directus/directus:11`, tested on 11.17.4) |
| Backend | Python 3, FastAPI, SQLAlchemy 2.x (ORM, `Mapped[]` style), Alembic, psycopg 3, Pydantic v2, pydantic-settings, email-validator, uvicorn. Virtual env folder: `myenv` |
| Frontend | Next.js 15 (App Router) + React 19 + TypeScript + Tailwind CSS v4, `lucide-react` icons, `sanitize-html` |
| Fonts / design | Montserrat (headings) + Inter (body) via `next/font/google`; custom design system in `app/universta.css` (Brand Kit v1.0) |

---

## 4. Repository layout

### 4.1 Backend (`backend/`)

```
backend/
├── docker-compose.yml           PostgreSQL + Directus containers
├── alembic.ini
├── requirements.txt
├── .env                         DATABASE_URL, CORS_ORIGINS  (not committed)
├── app/
│   ├── main.py                  FastAPI app: CORS, mounts all routers under /api, GET /health
│   ├── cors/config.py           Settings class (database_url, cors_origins) read from .env
│   ├── db/database.py           engine, SessionLocal, get_db() dependency
│   ├── db/base.py               re-exports Base from models
│   ├── models/models.py         ALL SQLAlchemy models (+ stub table for directus_users)
│   ├── schemas/schemas.py       Pydantic response/request models
│   ├── routers/
│   │   ├── subjects.py          /subjects, /subjects/{slug}, /subjects/{slug}/specializations
│   │   ├── specializations.py   /specializations, /specializations/{slug}
│   │   ├── studylevels.py       /study-levels
│   │   ├── countries.py         /countries
│   │   ├── enquireies.py        POST /enquiries   (file name is spelled "enquireies" on purpose, do not rename)
│   │   └── pages.py             /pages/{page_key}  (editable page text)
│   └── demoapi.py               temporary learning file (GET/POST on countries). Not part of the product
├── migrations/
│   ├── env.py                   Alembic env (sets DB URL, filters out directus_* tables)
│   └── versions/
│       ├── 3de303a568af_initial_tables.py
│       ├── b7c1a9d2e4f1_auto_slug_triggers.py
│       └── 94243856b009_subject_sections.py      <- current head
└── *.sql  and  generate_seed_from_excel.py       seed / setup SQL files (section 8)
```

### 4.2 Frontend (`frontend/`) - built by the frontend teammate

```
frontend/
├── .env.local                   API_URL=http://127.0.0.1:8000/api
├── package.json  tsconfig.json  next.config.ts  postcss.config.mjs
├── public/                      logos
├── app/
│   ├── layout.tsx               fonts, <SiteHeader/>, children, <SiteFooter/>
│   ├── globals.css              @import tailwind + universta.css, and the .rich-text styles
│   ├── universta.css            the design system (CSS variables, .card, .btn, .tag, .grid ...)
│   ├── page.tsx                 temporary: redirects "/" to "/subjects"
│   ├── subjects/page.tsx                     list page
│   ├── subjects/[slug]/page.tsx              subject detail page
│   ├── subjects/[slug]/[level]/page.tsx      subject + study level page
│   ├── specializations/[slug]/page.tsx       specialization detail page
│   └── specializations/[slug]/[level]/page.tsx
├── components/
│   ├── SubjectsExplorer.tsx     client component: hero, search box, subject cards
│   ├── ui.tsx                   shared building blocks (DetailHero, Section, Faq, tables, NextStepsBand ...)
│   ├── LevelPageView.tsx        view used by the two [level] pages
│   ├── RichText.tsx             renders sanitized HTML from Directus rich text fields
│   ├── SubjectIcon.tsx          maps the subject's icon_key to a lucide icon
│   ├── SiteHeader / SiteFooter / SubNav / SaveButton / LeadForm / SubscribeForm / Ph / site-config.ts
└── lib/
    ├── api.ts                   the ONLY place that calls FastAPI (+ TypeScript types)
    └── html.ts                  stripHtml() and shorten() helpers
```

---

## 5. Database

### 5.1 Conventions
- Primary keys are **UUIDs generated in Python** (`default=uuid.uuid4`). There is NO database default for `id`.
  Therefore Directus fields named `id` carry the special flag `uuid`, and raw SQL inserts use `gen_random_uuid()`.
- Content tables have `status`: one of `draft`, `pending_review`, `published`, `archived`
  (`enquiries` uses `new`, `contacted`, `in_progress`, `closed`). Enforced by CHECK constraints.
- `display_order` (integer, lower first) controls sort order. Timestamps use `timestamptz`.
- `created_by`, `updated_by`, `reviewed_by` (on subjects and specializations) are UUID foreign keys to
  `directus_users.id` with `ON DELETE SET NULL`.
- `models.py` contains a **stub** `directus_users` table (`Table("directus_users", Base.metadata, Column("id", Uuid, primary_key=True))`)
  only so SQLAlchemy can resolve the foreign keys. Alembic's `include_object` filter in `migrations/env.py`
  ignores every table starting with `directus_`, so it is never created, altered or dropped by Alembic.

### 5.2 Tables

| Table | Important columns | Notes |
|---|---|---|
| `countries` | name, slug (unique), country_code, description, status, display_order | Not used by the frontend yet |
| `subjects` | name, slug (unique), **description (rich text HTML)**, icon_key, status, display_order, created_by/updated_by/reviewed_by, published_at | Relationships: specializations, study levels, sections |
| `specializations` | subject_id (FK, CASCADE), name, slug (unique across ALL specializations), **description (rich text HTML)**, is_featured, status, display_order, audit columns | `is_featured` drives "Popular" lists |
| `study_levels` | name, slug (unique), description (plain text), duration (text like "3-4 years"), status, display_order | Foundation, Pathway, Diploma, Bachelor's, Master's, MBA, PhD |
| `subject_study_levels` | subject_id, study_level_id | Many-to-many link, unique pair. Study levels belong to subjects (specialization pages reuse their subject's levels) |
| `popular_searches` | label, target_type (`subject`/`specialization`), subject_id or specialization_id, is_active, display_order | Model exists, **no API endpoint yet** |
| `page_content` | page_key, section_key, content_key, **content_value (JSONB)**, status | Editable website text. Unique on (page_key, section_key, content_key). Strings must be stored as JSON strings, e.g. `"Find your field"` (with quotes) |
| `enquiries` | full_name, email, phone, preferred_country_id (FK countries), planned_intake, source_page, status, assigned_to (FK directus_users), internal_notes | Written by `POST /api/enquiries` |
| `subject_sections` | subject_id (FK, CASCADE), **section**, title, subtitle, body (rich text HTML), url, is_sponsored, status, display_order | Extra content for the subject page. `section` is one of `why`, `industry`, `company`, `course`, `destination`, `university` |

### 5.3 Database triggers (created by migration `b7c1a9d2e4f1`)
Functions `slugify_text(text)` and `set_slug_from_name()` plus a `BEFORE INSERT OR UPDATE` trigger on
`subjects`, `specializations`, `countries`, `study_levels`:
- If `slug` is empty or NULL, it is generated from `name` (lowercase, `&` removed, apostrophes removed,
  non-alphanumerics become `-`). Duplicates get `-2`, `-3`...
- If a slug is typed, it is normalised the same way.
- Renaming an item never changes its slug (URLs stay stable). Clearing the slug regenerates it.
- Works for Directus, FastAPI and plain SQL. This is why `slug` is not "required" in the Directus form.

### 5.4 Alembic
- Revision chain: `3de303a568af` (initial tables) -> `b7c1a9d2e4f1` (slug triggers) -> `94243856b009` (subject_sections, head).
- `migrations/env.py` sets `sqlalchemy.url` in code (host `127.0.0.1`, port `5433`) and prints it.
- Commands (run from `backend/`, venv active): `alembic upgrade head`, `alembic current`,
  `alembic revision --autogenerate -m "message"`.
- Always review an autogenerated migration: it must contain no `directus_*` operations.

---

## 6. Backend API (FastAPI)

Base URL in development: `http://localhost:8000/api` (interactive docs: `http://localhost:8000/docs`,
OpenAPI JSON: `http://localhost:8000/openapi.json`). Only **published** content is returned.
Missing or unpublished items return HTTP 404. CORS allows the origins listed in `.env` (`CORS_ORIGINS`).

| Method + path | Returns |
|---|---|
| `GET /health` | `{"status":"ok"}` (not under /api) |
| `GET /api/subjects` | List of subjects, each with `specializations[]` and `study_levels[]` (published only, ordered by display_order) |
| `GET /api/subjects/{slug}` | Subject detail: `id, name, slug, description, icon_key, specializations[], study_levels[], why, industries[], companies[], courses[], destinations[], universities[]` |
| `GET /api/subjects/{slug}/specializations` | Specializations of one subject |
| `GET /api/specializations?featured=true` | Published specializations whose subject is also published |
| `GET /api/specializations/{slug}` | Specialization + `subject_name`, `subject_slug` |
| `GET /api/study-levels` | All published study levels |
| `GET /api/countries` | Published countries |
| `GET /api/pages/{page_key}` | `{"page_key": "...", "sections": {"hero": {"title": "..."}}}` from `page_content`. 404 if no published rows |
| `POST /api/enquiries` | Saves an enquiry. Body: `full_name` (required), `email` or `phone` (one required), `preferred_country_id`, `planned_intake`, `source_page`, `website` (honeypot, must stay empty). Returns 201 `{"message": "..."}` |

Shapes used by the extra sections (`SectionItem`): `id, title, subtitle, body (HTML), url, is_sponsored`.

Code patterns:
- Each router file creates `router = APIRouter(tags=[...])` and is mounted in `main.py` with `prefix="/api"`.
- Endpoints are plain `def` (sync SQLAlchemy sessions) using `db: Session = Depends(get_db)`.
- Responses are built with Pydantic models (`from_attributes=True`). Internal columns (`created_by`, `internal_notes`...) are never exposed.
- Query pattern: `select(Model).where(Model.status == "published").order_by(Model.display_order, Model.name)`.
- Enquiry spam protection: honeypot field only. **No rate limiting yet.**

Settings (`app/cors/config.py`, read from `backend/.env`):
```
DATABASE_URL=postgresql+psycopg://<user>:<password>@127.0.0.1:5433/abroad
CORS_ORIGINS=["http://localhost:3000"]
```
The default `database_url` in the code points to the Docker Postgres on port 5433.

---

## 7. Directus (CMS) configuration

Directus runs from `docker-compose.yml` on `http://localhost:8055` and uses the same database.
Credentials (admin email/password, KEY, SECRET, DB password) are defined in `docker-compose.yml` for local development only.

Per-collection field setup (done in the UI, or by the SQL helper files):
- `id`: special `uuid`, hidden, readonly.
- `created_at`: special `date-created`; `updated_at`: special `date-updated` (readonly).
- `created_by` / `updated_by`: special `user-created,m2o` / `user-updated,m2o` (readonly); `reviewed_by` stays editable.
- `status`: dropdown with the allowed values; default `draft`.
- `slug`: not required, "Slugify" option on, note "Leave empty - created automatically from the name".
- `description` on `subjects` and `specializations`: interface **WYSIWYG / rich text (HTML)**, toolbar: bold, italic, underline, h2, h3, bullet list, numbered list, link.
- `page_content.content_value`: interface "Code" (JSON). Text values must be valid JSON strings (in double quotes).
- `subject_sections`: set up by `directus_subject_sections_setup.sql` (section dropdown, rich text body, Sponsored switch, status, M2O to subjects).

Important lessons:
- Fields shown with an orange triangle in Data Model are columns that exist but have no Directus settings yet.
- A Directus field that is not a real column breaks the collection screen (error: `column subjects.Specialization does not exist`).
  One-to-many "alias" fields must be created as type **One to Many** using the existing foreign key (e.g. `subject_sections.subject_id`), never as a normal field.
- After editing `directus_fields` with SQL, run `docker compose restart directus` (Directus caches the schema).
- Rows written directly by FastAPI/SQL bypass Directus: no activity log, no `created_by`.
- Public website reads do not go through Directus permissions because FastAPI reads the database itself.
  Roles/permissions in Directus are only for editors (not configured in detail yet).

---

## 8. Seed and setup SQL files (in `backend/`)

Run with (PowerShell, from `backend/`):
```
Get-Content <file>.sql | docker compose exec -T db psql -U abroad -d abroad
```
(Command Prompt: `docker compose exec -T db psql -U abroad -d abroad < <file>.sql`.)

| File | What it does | Notes |
|---|---|---|
| `seed_all_subjects.sql` | **Deletes all subjects/specializations**, then loads 30 subjects and 927 specializations from the Excel file, status `published`, links subjects to published study levels (MBA only to `business-management`) | Generated by `generate_seed_from_excel.py`. Names used under several subjects get slug `<name>-<subject-slug>` |
| `generate_seed_from_excel.py` | Reads the Excel (column A = subject, column B = its specializations below) and writes the SQL above. Removes duplicates inside one subject | `python generate_seed_from_excel.py "file.xlsx" seed_all_subjects.sql` (needs `openpyxl`) |
| `seed_study_levels_all.sql` | 7 study levels in order + links to subjects (MBA only on Business & Management) | Idempotent |
| `seed_subjects_page.sql` | Default texts for `page_key = subjects` | Idempotent |
| `seed_subject_detail_page.sql` | Default headings for `page_key = subject-detail` (older keys) | Idempotent |
| `seed_subject_page_content.sql` | Defaults for the 11-section subject page: headings with `{subject}` placeholder, advertisement, CTA | Idempotent |
| `seed_subject_sections_demo.sql` | SAMPLE rows in `subject_sections` for `engineering` and `computing-information-technology` | Run once. Sample data, to be replaced |
| `directus_slug_and_richtext_settings.sql` | Directus field settings: slug optional + slugify, description = rich text | Then restart Directus |
| `directus_subject_sections_setup.sql` | Registers the `subject_sections` collection, relation and field settings in Directus | Not yet verified against a live Directus. Fix in Data Model if something looks wrong |
| `seed_subjects_specializations.sql`, `seed_study_levels.sql` | Older dummy seeds, superseded | Do not use |

Current data after the seeds: 30 subjects, 927 specializations, 7 study levels, ~181 subject-level links.

---

## 9. Frontend

### 9.1 Data flow
```
Next.js server component (page.tsx)
   -> lib/api.ts  (fetch with { next: { revalidate: 30 } })
   -> FastAPI /api/...
```
- All fetching is in `lib/api.ts`. Pages import functions: `getSubjects()`, `getSubject(slug)`, `getSpecialization(slug)`, `getPageContent(pageKey)` and the helper `text(sections, section, key, fallback)`.
- Content published in Directus appears after at most about 30 seconds (revalidate). The base URL comes from `API_URL` (`.env.local`).
- The call is server-to-server, so CORS is not involved for these pages.
- `getSubject()` / `getSpecialization()` return `null` on HTTP 404, and the page calls `notFound()`.
- Restart `npm run dev` after changing `.env.local`.

### 9.2 Pages
| URL | File | Data |
|---|---|---|
| `/` | `app/page.tsx` | redirects to `/subjects` (temporary) |
| `/subjects` | `app/subjects/page.tsx` + `SubjectsExplorer` | `getSubjects()`, `getPageContent("subjects")`. Search filters subjects client-side (name, plain-text description, specialization names). Popular specializations = `is_featured` ones |
| `/subjects/[slug]` | `app/subjects/[slug]/page.tsx` | `getSubject`, `getSubjects` (for "Other subjects"), `getPageContent("subject-detail")`. Sections: Overview (rich text), Specializations, Study levels, Universities, Where to study, Careers, FAQ, sidebar |
| `/subjects/[slug]/[level]` | `.../[level]/page.tsx` + `LevelPageView` | subject + one of its study levels |
| `/specializations/[slug]` | `app/specializations/[slug]/page.tsx` | `getSpecialization` + parent subject's levels and related specializations |
| `/specializations/[slug]/[level]` | `.../[level]/page.tsx` | specialization + subject's level |

Placeholders: the component `<Ph>` marks values that have no data source yet (number of universities, tuition fee,
cost table, careers table, FAQ answers, "What you'll study" modules). Those parts of the design are static for now.

### 9.3 Editable text from Directus (`page_content`)
`text(sections, "hero", "title", "fallback")` returns the Directus value or the fallback, so pages work with no rows.
- `page_key = subjects`: `hero/eyebrow|title|intro`, `search/placeholder|button`, `list/eyebrow|title|intro|empty_message`,
  `popular/eyebrow|title`, `levels/eyebrow|title|intro`, `cta/title|text`.
- `page_key = subject-detail`: `overview/title`, `specializations/title|intro`, `study_levels/title|intro`,
  `universities/title|intro`, `destinations/title|intro`, `careers/title|intro`, `faq/title`.
- Placeholders inside texts: `{count}` (number of subjects), `{subjects}` and `{specializations}` (totals) on the subjects page,
  and `{word}` in a title becomes the blue highlight block (`withHighlight`).

### 9.4 Rich text (Directus WYSIWYG) handling - important
Fields `subjects.description`, `specializations.description`, `subject_sections.body` contain **HTML**.
- To render formatted text use `<RichText html={...} />` (sanitizes with `sanitize-html`: allowed tags p, br, strong, b, em, i, u, s, ul, ol, li, h2-h4, a, blockquote, hr; links get `rel="noopener noreferrer" target="_blank"`; schemes http, https, mailto, tel only). It outputs `<div class="rich-text">`, styled in `globals.css` with the brand variables.
- For hero lines, cards, previews and search use `stripHtml(html)` (and `shorten(text, 240)`) from `lib/html.ts`. Never print raw HTML as text.
- Never use `dangerouslySetInnerHTML` with unsanitized CMS content.
- Links coming from the CMS (`url` fields) should be passed through an allow-list (https, mailto, tel, paths starting with `/` or `#`); the helper `lib/url.ts` + `SubjectBlocks.tsx` exist in a separate update (see section 12).

### 9.5 Design system
`app/universta.css` (loaded from `globals.css`, inside `@layer components`) defines CSS variables (`--blue #033EFF`, `--ink`, `--amber`, `--cloud`, `--slate-*`, `--line`...) and classes such as `.card`, `.tag`, `.btn`, `.grid g-2/g-3/g-4`, `.page-hero`, `.section`, `.shell`, `.lead`, `.muted`, `.small`. Tailwind utility classes can still be combined with them.
Shared building blocks live in `components/ui.tsx`.

---

## 10. How to run everything (local development)

1. **Database + Directus:** `docker compose up -d` (in `backend/`). Directus: http://localhost:8055. Postgres on host port **5433** (5432 may be used by a local Postgres).
2. **Backend environment:** activate `myenv`, `python -m pip install -r requirements.txt`.
3. **Tables:** `alembic upgrade head`.
4. **Data:** run the SQL files from section 8 in this order:
   1. `seed_all_subjects.sql` (wipes and loads subjects + specializations)
   2. `seed_study_levels_all.sql` (study levels + links to subjects)
   3. `seed_subjects_page.sql`, `seed_subject_detail_page.sql`, `seed_subject_page_content.sql` (page texts)
   4. `directus_slug_and_richtext_settings.sql` and `directus_subject_sections_setup.sql` (Directus field settings)
   5. optional: `seed_subject_sections_demo.sql` (sample content)
   6. `docker compose restart directus`
5. **API:** `python -m uvicorn app.main:app --reload --port 8000` (use `python -m uvicorn` so the venv's Python is used).
6. **Frontend:** in `frontend/`: `npm install`, then `npm run dev` -> http://localhost:3000.
   (`npm run build` needs the API running, because pages fetch data at build time.)

Quick checks: `http://localhost:8000/api/subjects`, `http://localhost:8000/docs`, `alembic current` (expect `94243856b009`).

---

## 11. Development rules for this project

- **Schema changes:** edit `models.py` -> `alembic revision --autogenerate` -> review -> `alembic upgrade head`. Never edit tables by hand in pgAdmin or Directus.
- **Never touch `directus_*` tables** from application code. (The only exception is the setup SQL files that write Directus field settings.)
- **API contract:** adding fields is safe; renaming/removing fields needs agreement with the frontend developer. The OpenAPI JSON always shows the current shape.
- **Content flow:** editors work in Directus; they set `status = published` to make content visible.
- **Do not hardcode text** that editors may want to change: use `page_content` with a fallback.
- **Slugs:** never change a published slug (URLs and links break). Slugs are lowercase-hyphen; the DB trigger enforces this.
- **Git:** keep one source of truth per file. A bad merge once left `<<<<<<<` conflict markers in four frontend files; always search for them (`grep -rn "<<<<<<<"`) before committing.
- **SQL seeds on Windows PowerShell:** use `Get-Content file.sql | docker compose exec -T db psql ...` (the `<` redirect does not work in PowerShell). Keep seed files ASCII.
- **Security:** sanitize all CMS HTML, allow-list CMS links, keep the honeypot on the enquiry form, add rate limiting before production, change all default passwords and the Directus KEY/SECRET, do not expose Postgres publicly.

---

## 12. Status: what is NOT done / known issues

Not built yet:
- **11-section subject page requested by the owner** (About, Specializations, Why, Industries, Companies, Levels, Advertisement, CTA, Courses, Destinations, Universities). The **backend side is finished** (`subject_sections` table, API fields `why/industries/companies/courses/destinations/universities`, default texts in `seed_subject_page_content.sql`, per-subject text override via `page_content` rows with `page_key = subject-detail:{slug}`). A reference implementation exists (`SubjectBlocks.tsx`, `lib/url.ts`, a `subjects/[slug]/page.tsx` using them) but it is **not merged** into the teammate's design; the teammate's subject page still uses his own sections with placeholders.
- Frontend for **countries**, **enquiries** (the API exists: `POST /api/enquiries`; `LeadForm.tsx` is not yet connected), **popular searches** (model only, no endpoint).
- Real data for universities, courses, tuition costs, careers, FAQs, "what you'll study" modules (currently placeholders).
- Study-level filter in the subjects search bar (the dropdown is visual only; `/api/subjects` already returns `study_levels` per subject).
- Images/logos for companies and universities (would need Directus files + an asset URL in the API).
- Directus roles and permissions for editors/reviewers/employees; Directus schema snapshots for sharing config between machines.
- Rate limiting, authentication for any private endpoint, production deployment (shared server, HTTPS, environment variables instead of hardcoded DB URL in `migrations/env.py`).
- Automated tests.

Known issues / open points:
- `migrations/env.py` contains a hardcoded database URL (port 5433) and a debug `print`.
- The Directus setup SQL for `subject_sections` has not been run against a real Directus instance.
- Last reported problem: opening `/subjects` in the website was very slow (~40 s) and ended with `GET /subjects failed with status 500` from FastAPI. Cause not yet identified: first check the uvicorn traceback, `docker compose ps`, `alembic current` (must be `94243856b009`), and that `routers/subjects.py`, `schemas/schemas.py`, `models/models.py` are all from the same update. Slow Google Font downloads in `layout.tsx` can also slow the first page loads.

---

## 13. Glossary

- **slug**: URL-safe identifier, e.g. `computer-science-it` in `/subjects/computer-science-it`.
- **status / published**: only `published` rows appear on the website.
- **section (page_content)**: a named block of text on a page, e.g. `hero`.
- **subject_sections.section**: the kind of extra entry (`why`, `industry`, `company`, `course`, `destination`, `university`).
- **special flag (Directus)**: a field behaviour such as `uuid`, `date-created`, `user-created`.
- **ISR / revalidate**: Next.js serves a cached page and refreshes it in the background (30 seconds here).
