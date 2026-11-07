"""
Reads the Subjects / Specializations Excel file and writes one SQL file that
replaces ALL subjects and specializations in the database.

Excel layout expected (sheet 1):
    column A = subject name (on its own row)
    column B = specialization names (in the rows below that subject)

Usage (from the backend folder):
    python -m pip install openpyxl
    python generate_seed_from_excel.py "All_Subjects___Specialization.xlsx" seed_all_subjects.sql
"""
import re
import sys
from collections import Counter, defaultdict

import openpyxl

# icon_key values the website knows (see components/SubjectIcon.tsx). Others show a book icon.
ICONS = {
    "Computing & Information Technology": "code",
    "Business & Management": "briefcase",
    "Economics & Finance": "briefcase",
    "Engineering": "cog",
    "Health, Medicine & Veterinary Studies": "heart",
    "Law": "scale",
    "Creative Arts, Design & Communication": "pen-tool",
    "Architecture & Built Environment": "pen-tool",
    "Fashion & Textiles": "pen-tool",
    "Arts, Humanities & Social Sciences": "users",
    "Psychology & Behavioural Sciences": "users",
    "Social Work & Community Services": "users",
    "Science": "flask",
    "Biological & Life Sciences": "flask",
    "Pharmaceutical & Pharmaceutical Sciences": "flask",
    "Hospitality, Tourism & Events": "utensils",
    "Hospitality, Culinary & Food": "utensils",
    "Communication, Media & Journalism": "megaphone",
    "Media, Entertainment & Gaming": "megaphone",
}


def slugify(text: str) -> str:
    text = text.lower().replace("&", " ").replace("'", "")
    return re.sub(r"[^a-z0-9]+", "-", text).strip("-")


def q(text: str) -> str:
    """SQL string literal."""
    return "'" + text.replace("'", "''") + "'"


def read_excel(path: str):
    ws = openpyxl.load_workbook(path).worksheets[0]
    subjects, current = [], None
    for a, b in ws.iter_rows(min_row=2, max_col=2, values_only=True):
        a = str(a).strip() if a is not None else ""
        b = str(b).strip() if b is not None else ""
        if a:
            current = {"name": a, "specs": []}
            subjects.append(current)
        if b:
            if current is None:
                raise SystemExit(f"Specialization '{b}' appears before any subject")
            current["specs"].append(b)
    return subjects


def main(xlsx_path: str, out_path: str):
    subjects = read_excel(xlsx_path)

    # 1) remove duplicates inside the same subject (keep the first)
    removed = []
    for s in subjects:
        seen, unique = set(), []
        for sp in s["specs"]:
            if sp.lower() in seen:
                removed.append((s["name"], sp))
                continue
            seen.add(sp.lower())
            unique.append(sp)
        s["specs"] = unique

    # 2) subject slugs must be unique
    subject_slugs = [slugify(s["name"]) for s in subjects]
    assert len(set(subject_slugs)) == len(subject_slugs), "duplicate subject slug"
    for s, slug in zip(subjects, subject_slugs):
        s["slug"] = slug

    # 3) specialization slugs must be unique across ALL subjects.
    #    A name used under several subjects gets "<name>-<subject-slug>" everywhere.
    name_count = Counter(sp.lower() for s in subjects for sp in s["specs"])
    rows, used = [], set()
    for s in subjects:
        for order, sp in enumerate(s["specs"], 1):
            base = slugify(sp)
            slug = f"{base}-{s['slug']}" if name_count[sp.lower()] > 1 else base
            assert slug and slug not in used, f"slug collision: {slug}"
            assert len(slug) <= 200, f"slug too long: {slug}"
            used.add(slug)
            rows.append((s["slug"], sp, slug, order))

    shared_names = sum(1 for c in name_count.values() if c > 1)

    out = []
    w = out.append
    w("-- Generated from the Excel file by generate_seed_from_excel.py")
    w(f"-- {len(subjects)} subjects, {len(rows)} specializations. Everything runs in ONE transaction:")
    w("-- if any statement fails, nothing is changed.")
    w("--")
    w("-- WARNING: this DELETES all existing subjects and specializations first")
    w("-- (and, through cascade, their study-level links and popular searches).")
    w("BEGIN;")
    w("")
    w("DELETE FROM specializations;")
    w("DELETE FROM subjects;")
    w("")
    w("INSERT INTO subjects (id, name, slug, icon_key, status, display_order, published_at) VALUES")
    lines = []
    for i, s in enumerate(subjects, 1):
        icon = q(ICONS[s["name"]]) if s["name"] in ICONS else "NULL"
        lines.append(f" (gen_random_uuid(), {q(s['name'])}, {q(s['slug'])}, {icon}, 'published', {i}, now())")
    w(",\n".join(lines) + ";")
    w("")
    w("INSERT INTO specializations (id, subject_id, name, slug, status, display_order, published_at)")
    w("SELECT gen_random_uuid(), s.id, v.name, v.slug, 'published', v.ord, now()")
    w("FROM (VALUES")
    lines = [f" ({q(subj)}, {q(name)}, {q(slug)}, {order})" for subj, name, slug, order in rows]
    w(",\n".join(lines))
    w(") AS v(subject_slug, name, slug, ord)")
    w("JOIN subjects s ON s.slug = v.subject_slug;")
    w("")
    w("-- Link every subject to all published study levels (the subject page shows them).")
    w("-- MBA is only linked to Business & Management.")
    w("INSERT INTO subject_study_levels (id, subject_id, study_level_id)")
    w("SELECT gen_random_uuid(), s.id, l.id")
    w("FROM subjects s CROSS JOIN study_levels l")
    w("WHERE l.status = 'published'")
    w("  AND (l.slug <> 'mba' OR s.slug = 'business-management')")
    w("ON CONFLICT (subject_id, study_level_id) DO NOTHING;")
    w("")
    w("COMMIT;")
    w("")
    w("-- Check: should show the numbers below")
    w(f"SELECT (SELECT count(*) FROM subjects) AS subjects, -- expected {len(subjects)}")
    w(f"       (SELECT count(*) FROM specializations) AS specializations; -- expected {len(rows)}")

    with open(out_path, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(out) + "\n")

    print(f"Subjects:                         {len(subjects)}")
    print(f"Specializations written:          {len(rows)}")
    print(f"Duplicates removed in same subject: {len(removed)}")
    for subj, sp in removed:
        print(f"   - '{sp}' repeated under '{subj}'")
    print(f"Names shared by several subjects: {shared_names} (their slugs end with the subject slug)")
    print(f"Wrote {out_path}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit('Usage: python generate_seed_from_excel.py "file.xlsx" output.sql')
    main(sys.argv[1], sys.argv[2])
