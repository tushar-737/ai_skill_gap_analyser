# AI Skill Gap Analyzer

**AI-powered skill gap + career recommendation system** — React 19 + Vite 8 + Tailwind 4 + FastAPI + MySQL (Workbench) + AI (Groq `llama-3.3-70b` / Gemini `2.0-flash` with Keyword fallback).

> Pick **Education → Domain → Career**, **upload a resume (PDF/DOCX)** or rate skills manually, get **match % + readiness**, **gaps vs strengths**, **priority learning**, **curated resources**, **AI phased roadmap**, **alternative careers**, **share link**, and **Workbench-persisted history**.

[![Status](https://img.shields.io/badge/status-demo_ready-green)]() [![Stack](https://img.shields.io/badge/stack-React%20%7C%20FastAPI%20%7C%20MySQL-blue)]()

---

## ✨ Features (what you demo in 1 min)

1. **4-step wizard** with Stepper (Education → Domain → Career → Skills)
2. **Resume upload (PDF/DOCX/TXT, 5 MB)** — drag & drop, auto-extract with **Groq/Gemini AI** (passkey-protected) → auto-fills sliders
3. **Offline Keyword fallback** — works with no API key (substring match against `skills_v2`)
4. **Workbench persistence** — every upload saved to `resume_analyses` (JSON) → `My Uploads` history page (last 10, reload any)
5. **Scoring** — `match% = Σ min(have,need)/Σ need`, `gap = need - have`, `priority` + `readiness` tiers
6. **AI Roadmap** — Gemini/Groq → `summary + 3-5 phases` or rule-based fallback (always returns)
7. **Learning resources** per skill gap (`resources.js` curated links + Google fallback)
8. **Alternative careers** — top 3 in same domain by overlapping match
9. **Share link** (`#/share/<base64url>`) + `localStorage` persistence
10. **Workbench-ready** — `backend/workbench/init.sql` creates all 7 tables

---

## 🧱 Architecture

```
frontend/  React 19 + Vite 8 + Tailwind 4
  ├─ api/api.js              fetch wrapper (VITE_API_URL or /api proxy)
  ├─ lib/scoring.js          pure math (tested, 11 tests)
  ├─ lib/resources.js        skill → docs/roadmap/course links
  ├─ lib/share.js            base64url hash encode/decode
  └─ components/assessment   ResumeUploader (drag-drop + AI), Education/Domain/Career, SkillsRater
     components/resume       ResumeHistory (Workbench)
     components/results      ScoreCard (animated), SkillListCard, PriorityList, AiRecommendation
     components/recommendations

backend/   FastAPI 0.141 + SQLAlchemy 2 + PyMySQL
  ├─ main.py                 14 + 2 resume endpoints, Gap calc, Gemini/Groq + fallback
  ├─ models.py               Education*, Domain, Career(careers_v2), Skill(skills_v2), CSR, ResumeAnalysis
  ├─ database.py             loads backend/.env robustly (repo root or backend/)
  └─ workbench/init.sql      Forward Engineer in MySQL Workbench (creates ai_skill_gap + 7 tables)
```

---

## 🚀 Quick Start (Windows — your setup)

### 1) MySQL Workbench (once)
1. Open **MySQL Workbench** → Connect `localhost:3306`
2. **File → Open SQL Script** → `backend/workbench/init.sql` → **Execute ⚡**
3. Verify: `Schemas → ai_skill_gap → Tables` (7 tables) or `SHOW TABLES;`

### 2) Backend
```powershell
cd AI-Skill-Gap-Analyzer

copy backend\.env.example backend\.env
notepad backend\.env
# Set:
# DB_USER=root
# DB_PASSWORD=your_mysql_password
# DB_HOST=localhost
# DB_PORT=3306
# DB_NAME=ai_skill_gap
# Or use one URL instead of the DB_* values:
# DATABASE_URL=mysql+pymysql://app_user:strong_password@localhost:3306/ai_skill_gap
# AI_PROVIDER=auto          # auto = groq -> gemini -> keyword
# GROQ_API_KEY=gsk_...      # https://console.groq.com/keys (30 RPM free, recommended)
# GROQ_MODEL=llama-3.3-70b-versatile
# GEMINI_API_KEY=AQ....     # https://aistudio.google.com/app/apikey (15 RPM free)
# GEMINI_MODEL=gemini-2.0-flash

# venv (you already have backend\venv)
.\backend\venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn backend.main:app --reload --port 8000
# Should log: [AI] provider=auto | Gemini: yes (53 chars) | Groq: yes (56 chars)
# Docs: http://127.0.0.1:8000/docs
```

### 3) Frontend
```powershell
npm --prefix frontend install
npm --prefix frontend run dev
# http://localhost:5173  (proxies /api → 8000, no CORS)
```

---

## 🔑 AI Passkey (Groq = best for free)

**We support both — `AI_PROVIDER=auto` tries Groq first (faster + higher quota), then Gemini.**

* **Groq (recommended):** https://console.groq.com/keys → Create → `gsk_...` → `GROQ_API_KEY`
  * Free: **30 RPM / 14.4k TPM**, `llama-3.3-70b` is excellent for resume parsing
* **Gemini:** https://aistudio.google.com/app/apikey → Create in **Default Gemini Project** → `AQ...` → `GEMINI_API_KEY`
  * Free: 15 RPM (`2.0-flash`), `429` → auto fallback to `Keyword` (blue) with banner
* **No key?** → **Keyword mode** (`Keyword` blue badge) works offline — substring match against `skills_v2`

---

## 📄 Resume Upload Flow

1. **Drop PDF/DOCX/TXT** on the `★ Upload Resume` zone (or click)
2. **Backend:** `pypdf` (PDF) / `zip+xml` (DOCX stdlib, no `lxml` needed) → `raw_text`
3. **AI:** Groq/Gemini → `{skills: [{name, inferred_level 0-100, evidence}]}` → mapped to `skills_v2` IDs (aliases: `js→javascript`, `ml→machine learning`, etc.)
4. **Frontend:** `inferred_levels` auto-fill **SkillsRater** sliders (editable) → **Analyze My Skill Gap**
5. **Workbench:** `INSERT INTO resume_analyses` → see in **My Uploads** or Workbench:
   ```sql
   SELECT id, file_name, extraction_source, created_at
   FROM resume_analyses ORDER BY id DESC LIMIT 5;

   SELECT JSON_EXTRACT(extracted_skills, '$.skills') FROM resume_analyses WHERE id = 12;
   ```

**History UI:** `My Uploads — Workbench History` shows last 10, **Reload** any to restore sliders.

---

## 🔧 Scripts

| Command | Where | What |
|---|---|---|
| `uvicorn backend.main:app --reload --port 8000` | root | API (8000, docs at `/docs`) |
| `npm --prefix frontend run dev` | root | Vite 8 dev (5173) |
| `npm --prefix frontend run build` | root | Production build → `frontend/dist/` (13.7kB CSS, 70kB gz) |
| `npm --prefix frontend test` | root | Vitest unit tests (scoring) |
| `python -m unittest discover -s backend/tests` | root | Backend unit tests (scoring, upload validation, rate limiting; no MySQL server needed) |
| `pip install -r requirements.txt` | root | `fastapi, uvicorn[standard], sqlalchemy, pymysql, pypdf, requests, python-dotenv` (no `lxml` build needed) |

**Env:** `VITE_API_URL` (optional, browser-visible absolute API base; empty → uses `/api` proxy) and `VITE_PROXY_TARGET` (optional Vite server-side proxy target; defaults to `http://127.0.0.1:8000`).

---

## 🗄️ Workbench Schema

All tables are `InnoDB utf8mb4`, `IF NOT EXISTS`:

* `education_categories` (id, name UQ, description)
* `education_programs` (id, category_id FK, name, level)
* `domains` (id, name UQ)
* `careers_v2` (id, domain_id FK, name, average_level)
* `skills_v2` (id, name UQ, category)
* `career_skill_requirements` (id, career_id FK, skill_id FK, required_level, UQ(career_id,skill_id))
* `resume_analyses` (id, file_name, file_size, owner_token, raw_text TEXT optional, extracted_skills JSON, target_career_id FK, extraction_source, created_at DATETIME)
  * Upload history is isolated by an opaque browser session token. It is not a replacement for authentication in a multi-user deployment.

Seed your own data in Workbench or via `POST /api/...` — the code creates no dummy data.

---

## 📊 Scoring (single source: `lib/scoring.js` + backend parity)

```js
totalRequired = Σ required_level (0-100 clamped)
totalHave     = Σ min(inferred_or_user, required)
match%        = round(totalHave/totalRequired*100)
gap           = max(0, required - have)
readiness     = ≥80 Highly Ready | ≥60 Career Ready | ≥40 Developing | <40 Beginner
priority      = gap 0 None, ≤10 Low, ≤30 Medium, ≤50 High, >50 Critical
```

Frontend does local scoring for instant UI; backend `/api/analyze` mirrors it for API clients.

---

## 🔒 Security Notes

* `.env` is **gitignored** — only `.env.example` is committed. Never paste keys in screenshots/issues.
* `/api/debug-db` is **gated by `DEBUG=true`** (404 in prod).
* `CORS` is `GET,POST,OPTIONS` only, origin-locked via `ALLOWED_ORIGINS`.
* Resume `5 MB` limit, `pypdf` + stdlib `zip` parsing (no `lxml` C++ build on Windows).
* Resume history is isolated to an opaque browser session token; global history deletion is not available. Raw resume text is not persisted unless `STORE_RESUME_TEXT=true`.
* AI-enabled resume analysis sends resume text to the configured Groq or Gemini provider. Obtain user consent before using this in a public deployment.
* AI roadmap and resume-analysis requests are rate-limited per client IP in a single backend process. Configure the limits with `RATE_LIMIT_WINDOW_SECONDS`, `RESUME_ANALYZE_LIMIT`, and `AI_ROADMAP_LIMIT`; use a shared gateway/Redis limiter for multi-instance deployments.

---

## 🩹 Troubleshooting

* **`lxml build error` on Windows** → fixed: we removed `lxml`/`python-docx` — `requirements.txt` now needs no compiler (uses stdlib zip for DOCX)
* **`Table 'resume_analyses' doesn't exist (1146)`** → run `backend/workbench/init.sql` in Workbench once
* **`Keyword` blue instead of `Groq/Gemini` green** → Check terminal: `[AI] provider=...` must show `yes`. If `429 quota` banner shows, wait 60s or switch `AI_PROVIDER=groq` / `GEMINI_MODEL=gemini-1.5-flash` and restart
* **`__pycache__` or `frontend/src/assets` permission denied on `git pull`** → close `uvicorn` + Vite (`Ctrl+C`), then `Remove-Item -Recurse -Force frontend\src\assets -ErrorAction SilentlyContinue` and pull again

---

## 📄 License & Credits

Built for portfolio/demo — React + FastAPI + MySQL Workbench + Groq/Gemini. PRs welcome.

