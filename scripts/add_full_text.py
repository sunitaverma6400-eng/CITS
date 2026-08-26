"""
Adds the ORIGINAL book text (full, page-by-page) into flashcards_data.json
so the app can show a "Read Chapter" mode, not just flashcards/summary.

No API needed — this just re-reads the already-extracted text files and
matches them to the same chapter IDs the generator used.

Run:
    python3 scripts/add_full_text.py
"""

import os
import re
import json

OUTPUT_FILE = "app/assets/data/flashcards_data.json"
TEXT_DIR = "extracted_text"
PAGES_PER_CHUNK = 6

SUBJECTS = [
    {"id": "trade_theory", "file": "trade_theory.txt"},
    {"id": "trade_practical", "file": "trade_practical.txt"},
    {"id": "training_methodology", "file": "training_methodology.txt"},
]


def chunk_pages(text, pages_per_chunk):
    pages = text.split("\x0c")
    chunks = []
    for i in range(0, len(pages), pages_per_chunk):
        group = pages[i:i + pages_per_chunk]
        joined = "\n".join(group).strip()
        start_page = i + 1
        end_page = min(i + pages_per_chunk, len(pages))
        chunks.append((f"p{start_page}-{end_page}", joined))
    return chunks


def clean_text(t):
    # collapse excess blank lines for nicer reading
    t = re.sub(r"\n{3,}", "\n\n", t)
    return t.strip()


def main():
    if not os.path.exists(OUTPUT_FILE):
        print(f"ERROR: {OUTPUT_FILE} not found. Run generate_flashcards.py first.")
        return

    with open(OUTPUT_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)

    chapter_lookup = {}
    for subject in data.get("subjects", []):
        for chapter in subject.get("chapters", []):
            chapter_lookup[chapter["id"]] = chapter

    updated = 0
    for subject in SUBJECTS:
        path = os.path.join(TEXT_DIR, subject["file"])
        if not os.path.exists(path):
            print(f"Skipping {subject['file']} (not found)")
            continue

        with open(path, "r", encoding="utf-8") as f:
            text = f.read()

        chunks = chunk_pages(text, PAGES_PER_CHUNK)
        for chunk_id, chunk_text in chunks:
            chapter_id = f"{subject['id']}_{chunk_id}"
            if chapter_id in chapter_lookup:
                chapter_lookup[chapter_id]["fullText"] = clean_text(chunk_text)
                updated += 1

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"Done! Added fullText to {updated} chapters.")
    print(f"Saved: {OUTPUT_FILE}")


if __name__ == "__main__":
    main()
