# Draughtsman Mechanical — Study App (Quizlet-clone)

## Kya bana hai

1. **Flutter Android app** (`app/` folder) — Quizlet jaisa, full working:
   - Home screen — subjects → chapters list
   - **Flashcards** — tap karke flip (term ↔ definition)
   - **Learn Mode** — "Got it! / Still Learning" — jab tak sab "Got it" na ho jaye
   - **Study Guide** — chapter ka summary + key concepts
   - **Quiz** — auto-generated multiple-choice questions
   - Hindi (Devanagari) font support built-in (Noto Sans Devanagari)
   - Ek sample chapter (Safety, Trade Theory se) already data mein hai — app abhi hi test ho sakta hai

2. **Extracted text** (`extracted_text/`) — teeno PDFs se saara text nikal liya gaya hai (Hindi, page-wise split)

3. **Content generator script** (`scripts/generate_flashcards.py`) — baaki ~1080 pages ko automatically flashcards mein convert karega, tumhare Gemini API key se

4. **GitHub Actions workflow** (`.github/workflows/build-apk.yml`) — jab bhi `main` branch pe push karoge, apne aap APK ban jayega (Actions tab ke "Artifacts" mein milega)

## Ab kya karna hai (2 steps)

### Step 1 — Poora content generate karo

```bash
pip install google-generativeai
export GEMINI_API_KEY="apni_gemini_key_daalo"
python3 scripts/generate_flashcards.py
```

- Ye ~1095 pages ko 6-6 pages ke chunks mein todke Gemini se flashcards banayega
- **Resumable hai** — beech mein rok do (Ctrl+C), dobara chalao to jahan chhoda tha wahin se shuru hoga (`scripts/progress.json` mein track hota hai)
- Har chunk ke baad `app/assets/data/flashcards_data.json` save hota rehta hai — safe hai

### Step 2 — GitHub pe push karo

```bash
git init
git add .
git commit -m "Draughtsman Mechanical study app"
git remote add origin <tumhara_github_repo_url>
git push -u origin main
```

Push hote hi GitHub Actions automatically APK build kar dega. Repo ke **Actions** tab mein jaake latest run se APK download kar sakte ho.

## Image / Diagram support (naya)

Book ke diagrams (traffic signals, tools, symbols) zyada tar **vector-drawn**
hain, embedded photos nahi — isliye simple image-extraction se nahi milte.
Isliye pipeline ab har chapter ke liye us range ke 2-3 pages ko **screenshot
(render)** kar leta hai aur unhe Study Guide screen mein dikhata hai
(zoom karne ke liye tap kar sakte ho).

- `source_pdfs/` folder mein teeno original PDFs bhi include kar diye hain
  (script ko in se hi page-images render karne hote hain)
- `scripts/generate_flashcards.py` mein `RENDER_IMAGES = True` hai by default.
  Agar sirf text-based flashcards chahiye (fast, chota app size), to isse
  `False` kar do.
- Har chapter ke liye max 3 images by default (`MAX_IMAGES_PER_CHUNK`) —
  zyada chahiye to badha sakte ho, lekin APK size bhi badhega.

## Notes

- Model `gemini-2.0-flash` use ho raha hai — fast aur bulk processing ke liye sasta bhi. Chahiye to `scripts/generate_flashcards.py` mein `MODEL_NAME` change kar sakte ho.
- Sample data mein abhi sirf 1 chapter (11 flashcards) hai taaki app turant test ho sake — poora generate hone ke baad ye replace ho jayega.
- Agar rate limit hit ho, script khud retry karta hai (4 attempts, backoff ke saath).
