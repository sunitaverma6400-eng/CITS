"""
Draughtsman Mechanical PDF -> Flashcards generator (REST version)
"""
import os
import re
import json
import time
import glob
import subprocess
import requests

API_KEY = os.environ.get("GEMINI_API_KEY", "")
MODEL_NAME = "gemini-flash-lite-latest"
GEMINI_URL = f"https://generativelanguage.googleapis.com/v1beta/models/{MODEL_NAME}:generateContent"
PAGES_PER_CHUNK = 6
MIN_CHARS_PER_CHUNK = 400
OUTPUT_FILE = "app/assets/data/flashcards_data.json"
PROGRESS_FILE = "scripts/progress.json"
TEXT_DIR = "extracted_text"
SOURCE_PDF_DIR = "source_pdfs"
IMAGES_OUT_DIR = "app/assets/images"
RENDER_IMAGES = True
IMAGE_DPI = 110
MAX_IMAGES_PER_CHUNK = 3

SUBJECTS = [
    {"id": "trade_theory", "name": "Trade Theory", "file": "trade_theory.txt", "pdf": "trade_theory.pdf"},
    {"id": "trade_practical", "name": "Trade Practical", "file": "trade_practical.txt", "pdf": "trade_practical.pdf"},
    {"id": "training_methodology", "name": "Training Methodology", "file": "training_methodology.txt", "pdf": "training_methodology.pdf"},
]

PROMPT_TEMPLATE = """Tum ek ITI Draughtsman Mechanical trade ke expert teacher ho.
Neeche diya gaya text ek Hindi NIMI training book ke kuch pages se hai.
Isse padhkar Hindi mein ek study module banao jisme:

1. Ek short "summary" (2-4 sentences) jo is section ka overview de.
2. "keyConcepts": 3-6 important concepts, har ek ka "term" aur ek line "explanation".
3. "flashcards": 6-12 flashcards, har ek ka "term" (chota, ek concept/keyword) aur
   "definition" (uska explanation, 1-3 sentences). Yeh exam-relevant honi chahiye.

Sirf valid JSON output do, koi extra text nahi, is exact shape mein:

{{
  "summary": "...",
  "keyConcepts": [{{"term": "...", "explanation": "..."}}],
  "flashcards": [{{"term": "...", "definition": "..."}}]
}}

Agar text mein koi meaningful technical/educational content nahi hai
(jaise sirf cover page, index, blank ya author acknowledgment page),
to isse return karo: {{"summary": "", "keyConcepts": [], "flashcards": []}}

--- TEXT START ---
{chunk_text}
--- TEXT END ---
"""


def load_progress():
    if os.path.exists(PROGRESS_FILE):
        with open(PROGRESS_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    return {}


def save_progress(progress):
    os.makedirs(os.path.dirname(PROGRESS_FILE), exist_ok=True)
    with open(PROGRESS_FILE, "w", encoding="utf-8") as f:
        json.dump(progress, f, ensure_ascii=False, indent=2)


def load_output():
    if os.path.exists(OUTPUT_FILE):
        with open(OUTPUT_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    return {"subjects": []}


def save_output(data):
    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def get_subject_entry(data, subject_id, subject_name):
    for s in data["subjects"]:
        if s["id"] == subject_id:
            return s
    entry = {"id": subject_id, "name": subject_name, "chapters": []}
    data["subjects"].append(entry)
    return entry


def render_chunk_images(subject_id, pdf_filename, chunk_id, start_page, end_page):
    pdf_path = os.path.join(SOURCE_PDF_DIR, pdf_filename)
    if not os.path.exists(pdf_path):
        return []
    out_dir = os.path.join(IMAGES_OUT_DIR, subject_id)
    os.makedirs(out_dir, exist_ok=True)
    pages_in_range = list(range(start_page, end_page + 1))
    step = max(1, len(pages_in_range) // MAX_IMAGES_PER_CHUNK)
    picked_pages = pages_in_range[::step][:MAX_IMAGES_PER_CHUNK]
    image_paths = []
    for p in picked_pages:
        out_prefix = os.path.join(out_dir, f"{chunk_id}_p{p}")
        try:
            subprocess.run(
                ["pdftoppm", "-jpeg", "-r", str(IMAGE_DPI), "-f", str(p), "-l", str(p), pdf_path, out_prefix],
                check=True, capture_output=True, timeout=60,
            )
            matches = glob.glob(out_prefix + "*.jpg")
            if matches:
                rel_path = "assets/images/" + subject_id + "/" + os.path.basename(matches[0])
                image_paths.append(rel_path)
        except Exception as e:
            print(f"    (image render failed for page {p}: {e})")
    return image_paths


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


def clean_json_response(raw):
    raw = raw.strip()
    raw = re.sub(r"^```json", "", raw)
    raw = re.sub(r"^```", "", raw)
    raw = re.sub(r"```$", "", raw)
    return raw.strip()


def generate_for_chunk(chunk_text):
    prompt = PROMPT_TEMPLATE.format(chunk_text=chunk_text[:12000])
    payload = {"contents": [{"parts": [{"text": prompt}]}], "generationConfig": {"temperature": 0.4}}
    headers = {"Content-Type": "application/json"}
    for attempt in range(4):
        try:
            resp = requests.post(f"{GEMINI_URL}?key={API_KEY}", headers=headers, json=payload, timeout=60)
            if resp.status_code == 429:
                raise RuntimeError("rate limited (429)")
            resp.raise_for_status()
            data = resp.json()
            text = data["candidates"][0]["content"]["parts"][0]["text"]
            cleaned = clean_json_response(text)
            return json.loads(cleaned)
        except Exception as e:
            wait = 5 * (attempt + 1)
            print(f"    retry {attempt+1}/4 after error: {e} (waiting {wait}s)")
            time.sleep(wait)
    return None


def main():
    if not API_KEY:
        print("ERROR: set GEMINI_API_KEY environment variable pehle.")
        return
    progress = load_progress()
    data = load_output()
    for subject in SUBJECTS:
        path = os.path.join(TEXT_DIR, subject["file"])
        if not os.path.exists(path):
            print(f"Skipping {subject['file']} (not found)")
            continue
        with open(path, "r", encoding="utf-8") as f:
            text = f.read()
        chunks = chunk_pages(text, PAGES_PER_CHUNK)
        subject_entry = get_subject_entry(data, subject["id"], subject["name"])
        existing_chapter_ids = {c["id"] for c in subject_entry["chapters"]}
        print(f"\n=== {subject['name']}: {len(chunks)} chunks ===")
        for chunk_id, chunk_text in chunks:
            key = f"{subject['id']}_{chunk_id}"
            chapter_id = f"{subject['id']}_{chunk_id}"
            if progress.get(key) == "done" and chapter_id in existing_chapter_ids:
                continue
            if len(chunk_text.strip()) < MIN_CHARS_PER_CHUNK:
                progress[key] = "done"
                save_progress(progress)
                continue
            print(f"  Processing {chunk_id} ...")
            result = generate_for_chunk(chunk_text)
            if result is None:
                print(f"    FAILED permanently on {chunk_id}, skipping for now")
                continue
            if not result.get("flashcards"):
                progress[key] = "done"
                save_progress(progress)
                continue
            images = []
            if RENDER_IMAGES:
                start_page = int(re.search(r"p(\d+)-", chunk_id).group(1))
                end_page = int(re.search(r"-(\d+)$", chunk_id).group(1))
                images = render_chunk_images(subject["id"], subject["pdf"], chunk_id, start_page, end_page)
            chapter = {
                "id": chapter_id,
                "title": f"{subject['name']} - {chunk_id}",
                "studyGuide": {"summary": result.get("summary", ""), "keyConcepts": result.get("keyConcepts", [])},
                "flashcards": [{"id": f"{chapter_id}_{i}", **card} for i, card in enumerate(result["flashcards"])],
                "images": images,
            }
            subject_entry["chapters"].append(chapter)
            existing_chapter_ids.add(chapter_id)
            progress[key] = "done"
            save_progress(progress)
            save_output(data)
            time.sleep(2)
    print("\nDone! Final file:", OUTPUT_FILE)


if __name__ == "__main__":
    main()
