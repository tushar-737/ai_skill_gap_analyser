# AI Skill Gap Analyzer — Repository Analysis

**Date:** 2026-08-10 (UTC)  
**Branch:** `arena/019feb9c-ai-skill-gap-analyser` → `main` @ `3e7b846 good`  
**Stack:** FastAPI + SQLAlchemy (MySQL) · React 19 + Vite 8 + Tailwind 4 · Gemini 2.0 Flash  
**Single commit:** 49 files, 7,241 lines added, no prior history. `__pycache__` and UTF-16 `requirements.txt` were committed.


---

## 1) Executive Summary

A clean, well-scoped **AI Skill Gap Analyzer**: the user picks Education → Domain → Career, rates `0-100` per required skill, and gets a local match score + readiness, strong skills, gaps, priority list, curated learning links, alternative career recommendations, shareable link, local-storage persistence, and an **AI-generated phased roadmap** (Gemini with rule-based fallback).

**Overall:** **7.2 / 10** — Solid UX, sensible decomposition, strong frontend hygiene (pure `lib/scoring.js`, unit tests, hooks per resource, Tailwind). Main risks are **operational** (MySQL-only, no Docker/env template, weak `requirements.txt` encoding, checked-in `.env`/`.pyc`), **contract drift** between backend `POST /api/analyze` and frontend local scoring, missing styles for ~18 classes, and a few security/info-leak endpoints.

---

## 2) Project Map

```
ai_skill_gap_analyser/
├── backend/
│   ├── main.py        # 1208 LOC — FastAPI app, 14 endpoints, scoring + Gemini roadmap
│   ├── database.py    # 73 LOC — SQLAlchemy engine/session (MySQL+pymysql)
│   ├── models.py      # 179 LOC — 6 tables (careers_v2, skills_v2, etc.)
│   ├── .env           # committed — DB_USER=root / DB_PASSWORD=1234 / ai_skill_gap
│   └── __pycache__/   # should be ignored
├── frontend/
│   ├── src/
│   │   ├── App.jsx              # container (state, persistence, share, computed results)
│   │   ├── api/api.js           # fetch wrapper, relative /api + VITE_API_URL
│   │   ├── hooks/               # 5 hooks: useInitialData, useCareers, useCareerSkills,
│   │   │                        #       useDomainCareerSkills, useAiRoadmap
│   │   ├── lib/                 # scoring.js (pure, tested), resources.js, share.js, storage.js
│   │   ├── components/
│   │   │   ├── layout/          # Header, Hero, Footer
│   │   │   ├── assessment/      # Stepper, EducationStep, DomainStep, CareerStep, SkillsRater
│   │   │   ├── results/         # ResultsSection, ScoreCard, SkillListCard, PriorityList,
│   │   │   │                    # SummaryCards, AiRecommendation
│   │   │   └── ui/              # MatchChart (SVG), LoadingScreen, ErrorBanner
│   │   ├── App.css / index.css
│   │   └── main.jsx
│   ├── vite.config.js           # host: true, allowedHosts: true, /api → 127.0.0.1:8000
│   ├── package.json             # React 19.2.8, Vite 8.2, Tailwind 4.3, Vitest 4.1
│   └── index.html
└── requirements.txt             # UTF-16LE encoded, Flask+FastAPI duplication
```

**Git:** `main` has 1 commit only. Working tree clean. No CI, no root README.

---

## 3) Backend — `backend/`

### 3.1 Architecture
* **Framework:** FastAPI `0.141.1`, Uvicorn `0.52.1`, SQLAlchemy `2.0.51`.
* **DB:** MySQL via `pymysql`, `mysql+` URL built from env (`DB_USER` etc.) with `pool_pre_ping` + `pool_recycle=3600`.
* **CORS:** env `ALLOWED_ORIGINS` CSV or fallback to `localhost:5173/5175`. `allow_credentials=True`, `allow_methods=["*"]`.

### 3.2 Data Model (`models.py`)
| Model | Table | Columns | Notes |
|---|---|---|---|
| `EducationCategory` | `education_categories` | id, name (UQ), description | |
| `EducationProgram` | `education_programs` | id, category_id FK→cat, name, level, description | |
| `Domain` | `domains` | id, name (UQ), description | |
| `Career` | `careers_v2` | id, domain_id FK→domains, name, description, average_level | name not unique |
| `Skill` | `skills_v2` | id, name (UQ), category, description | |
| `CareerSkillRequirement` | `career_skill_requirements` | id, career_id FK→careers_v2, skill_id FK→skills_v2, required_level int default 50 | no composite UQ |

> No Alembic, no seed script, no `Base.metadata.create_all()` — deployment assumes an existing `ai_skill_gap` MySQL with `v2` tables pre-filled.

### 3.3 API Surface (`main.py`, 14 routes)
| Method | Path | Purpose |
|---|---|---|
| `GET` | `/` | health |
| `GET` | `/api/database-test` | `SELECT 1` probe |
| `GET` | `/api/debug-db` | returns `DATABASE()`, `@@hostname`, `@@port`, `@@server_uuid`, all careers — **info leak** |
| `GET` | `/api/education-categories` | list cats |
| `GET` | `/api/education-programs` | list programs |
| `GET` | `/api/domains` | list domains |
| `GET` | `/api/careers` | all careers |
| `GET` | `/api/careers/domain/{domain_id}` | by domain |
| `GET` | `/api/skills` | all skills |
| `GET` | `/api/skills/category/{category}` | by category |
| `GET` | `/api/careers/{career_id}/skills` | join with required_level |
| `GET` | `/api/careers/domain/{domain_id}/with-skills` | batch load for recommendations |
| `GET` | `/api/statistics` | counts for 5 tables |
| `POST` | `/api/analyze` | skill-gap analysis: weighted match, gaps/strengths, readiness, top+5 alts |
| `POST` | `/api/ai/roadmap` | Gemini `gemini-2.0-flash` → phased roadmap JSON, fallback to rule-based |

**Scoring (`POST /api/analyze`):**
```
total_required = Σ required_level (0-100 clamped)
total_user     = Σ min(user_level, required_level)
match% = total_user/total_required *100 (rounded to 2 decimals)
gap    = max(0, required - user)
priority: gap ≤0 None, ≤10 Low, ≤30 Medium, ≤50 High, >50 Critical
readiness: ≥90 Excellent, ≥75 Strong, ≥60 Good, ≥40 Needs Improvement, <40 Beginner
```
Careers without requirements are skipped. Results sorted descending `match%`.

**AI Roadmap:**
* Prompt built from `career_name`, `match_score`, `gaps (name/current/required/gap)`, `strong_skills`, `education`.
* `response_mime_type: application/json`, `response_schema: {summary, steps{title,description,skills[],resources{name,type}[]}}`.
* On failure or missing `GEMINI_API_KEY`, deterministic `fallback_roadmap()` returns per-gap phases (or “Maintain and specialize”).

---

## 4) Frontend — `frontend/`

### 4.1 Container (`App.jsx`, 432 LOC)
Single-source wizard state (5 `useState` + 2 `useRef`). Flow:
`selectedEducation` → `selectedDomain` → `selectedCareer` → `skillLevels` → `showResults`.
* **Data:** `useInitialData` (education+domains in parallel), `useCareers`, `useDomainCareerSkills`, `useCareerSkills`.
* **Persistence:** `loadState()`/`saveState()` to `localStorage` key `skillgap:state:v1` every state change; **share link takes precedence** (`#/share/<base64url JSON>` via `decodeShareState`).
* **Restoration trick:** `pendingLevelsRef` holds `{c,l,showResults}` until `requiredSkills` load, then levels applied — avoids reset race.
* **Compute:** `useMemo(computeResults)` + `useMemo(computeCareerRecommendations)` pure functions from `lib/scoring.js`.
* **AI:** `useAiRoadmap` gated on `showResults && results && careerName`.
* **Validation:** `handleAnalyze` guards education/domain/career + non-empty skills before `setShowResults(true)` and scrolls to `#results`.

### 4.2 Lib (`lib/`)
* **`scoring.js` (88 LOC)** — two pure exports, fully matching original `App.jsx` math (now extracted & tested). `matchScore = round(totalCurrent/totalRequired*100)`, `strong = gap===0`, `gaps = gap>0 sorted desc`, readiness tiers `≥80 Highly Ready / ≥60 Career Ready / ≥40 Developing / else Beginner`. `computeCareerRecommendations` filters `domainCareerSkills`, maps overlapping skills, keeps those with `current>0 || required>0`, match capped per-career, top 3.
* **`resources.js` (185 LOC)** — `RESOURCES` map (python/js/ts/react/html/css/tailwind/sql/mysql/pg/pandas/numpy/ml/stats/dl/powerbi/excel/git/api/django/fastapi/flask/node/docker/aws/data… plus aliases `js→javascript` etc., normalized lowercase). Fallback: Google search URL.
* **`share.js` (89 LOC)** — base64url encode/decode via `TextEncoder/Decoder`, URL hash `#/share/…`, clipboard with `navigator.clipboard` + textarea fallback.
* **`storage.js` (31 LOC)** — `localStorage` JSON with try/catch (private-mode safe).

### 4.3 Hooks
Each hook follows cancel-guard pattern (`let cancelled=false`). `useInitialData` does `Promise.all` for education+domains. Error channels via `setError` prop. `useAiRoadmap` dependency trick `JSON.stringify(skillGaps)` to avoid reference churn (eslint disabled).

### 4.4 Components (16)
Layout: `Header` (brand `AI` badge), `Hero` (title+ `🚀 AI CAREER ANALYZER` badge), `Footer`. Assessment: `Stepper` (5 labels, active/completed colors), `EducationStep`, `DomainStep`, `CareerStep` (disables until domain), `SkillsRater` (range `0-100 step 5`, `Analyze My Skill Gap` button). Results: `ResultsSection` (badge, `🔗 Share`, `ScoreCard` animated count-up 900ms ease-out with `prefers-reduced-motion` bypass, `SummaryCards`, two `SkillListCard`s with `📚 Learn` links, `PriorityList` top 5, `AiRecommendation` with loading/summary/steps). UI: `MatchChart` SVG donut with `useId` gradient (colon stripped), `LoadingScreen`, `ErrorBanner`. Recommendations: `CareerRecommendations`.

### 4.5 Styles
`index.css` (Inter, reset, smooth scroll, `#f8fafc` bg). `App.css` (751 LOC) covers assessment-container (1100px), stepper, forms, skill-items range, buttons `.primary-button`, errors, loading, results-section/score-card/summary/skill-list/priority/recommendation-card/roadmap. **Gaps (see §7):** 18 JSX classes have no CSS rule (`header`, `hero`, `brand*`, `subtitle`, `footer*`, `assessment-step`, `step-header`, `skills-rater`, `skills-list`, `skill-info`, `analyze-button`, `priority-card`, `loading-screen`, etc.) — works because browser defaults + `App.css` partials, but header/hero appear unstyled until added. Conversely `assessment-section`, `skill-header`, `skills-container`, `primary-button`, `step` etc. defined but unused (naming drift).

### 4.6 API Layer (`api/api.js`, 213 LOC)
`API_BASE_URL = import.meta.env.VITE_API_URL || ""` — relative `/api` via Vite proxy in dev (`vite.config.js: /api → http://127.0.0.1:8000`). `apiRequest` throws on `!ok`. Exports 11 helpers + `getAiRoadmap` (POST snake_case body mapping).

### 4.7 Build
`vite build` ✓: **45 modules → `dist/assets/index-*.js` 217.57 kB (67.97 kB gzip), CSS 8.29 kB**. `vitest run` ✓: **11 tests pass** (scoring). `oxlint` configured (react/oxc, rules-of-hooks error). `allowedHosts:true`, `host:true`.

---

## 5) Feature Audit

| Feature | Status | Notes |
|---|---|---|
| 4-step wizard with Stepper | ✅ | stepper `activeStep` derived from selection; domain→career reset |
| Skill rating 0-100 | ✅ | range with `skillLevels` map, display `%` |
| Local scoring (frontend) | ✅ | instant, no round-trip |
| Backend scoring (`/api/analyze`) | ⚠️ | **unused** by frontend — duplication, readiness labels diverge |
| Alternative careers | ✅ | domain-scoped, top 3 by match, overlapping filter |
| Learning links | ✅ | curated per skill + fallback search |
| Priority list | ✅ | top 5 gaps descending |
| AI roadmap | ✅ | Gemini + fallback, loading + error states |
| Share link | ✅ | base64url hash, auto-restore |
| Persistence | ✅ | localStorage, survives refresh |
| Responsive | ⚠️ | 768px breakpoint, stepper overflows; but header/footer missing style |
| Accessibility | ⚙️ | `skip-link`, `aria-label` on MatchChart, but missing focus styles/labels |

---

## 6) Scoring Deep Dive & Contract Drift

**Frontend tiers:** `≥80 Highly Ready`, `≥60 Career Ready`, `≥40 Developing`, else `Beginner`.
**Backend tiers:** `≥90 Excellent`, `≥75 Strong`, `≥60 Good`, `≥40 Needs Improvement`, else `Beginner`.
→ If frontend ever called `/api/analyze`, users would see label mismatches and 1-2% rounding differences (backend `toFixed(2)` vs frontend `Math.round`). Also backend adds `priority` (`None/Low/Medium/High/Critical`) never consumed frontend.

**Recommendation:** pick one source of truth — either **(A)** make frontend call `POST /api/analyze` and delete local scoring, or **(B)** keep frontend-local scoring and remove backend `/api/analyze` (or keep it for non-UI consumers with matching labels). At minimum unify `get_readiness` ↔ `readiness` map and expose `gap→priority` if needed.

---

## 7) Issues & Bugs (ranked)

### 🔴 High
1. **`requirements.txt` UTF-16LE (BOM + `\0` bytes)** — `pip install -r requirements.txt` fails on Linux/Docker; file reported as `Binary` in git stat. Must be rewritten UTF-8.
2. **Committed secrets & artifacts** — `backend/.env` (`root/1234`), `backend/__pycache__/*.pyc` in repo history. Add `.gitignore` (`__pycache__/`, `.env`, `.venv`) and rotate creds; provide `.env.example`.
3. **Missing CSS for core layout** — `header`, `hero`, `brand`, `brand-icon`, `brand-highlight`, `subtitle`, `footer`, `footer-container`, `assessment-step`, `step-header`, `skills-list`, `skill-info`, `analyze-button`, etc. → header/hero unstyled after `vite build`. Either rename JSX to match existing `assessment-section` or add the 18 rules.
4. **`GET /api/debug-db` info leak** — exposes DB hostname/port/server_uuid + all career ids+names without auth. Remove or gate behind env `DEBUG=true`.
5. **No DB bootstrap** — no Alembic, seed, or `docker-compose.yml`; fresh clone cannot run (MySQL `ai_skill_gap` with `careers_v2`/`skills_v2` must be manually created).

### 🟡 Medium
6. **Dual scoring drift** (above) — two implementations diverging.
7. **Flask+pymysql+bloat** in `requirements.txt` alongside FastAPI — pulls `blinker`, `itsdangerous`, `Werkzeug` never used; heavy ML stack (`numpy 2.4.4`, `pandas 3.0.3`, `matplotlib 3.10.9`, `pillow 12.2`, `openpyxl 3.1.5`) unused server-side → slow install, CVE surface. Trim to `fastapi`, `uvicorn`, `sqlalchemy`, `pymysql`, `pydantic`, `requests`, `python-dotenv`.
8. **`vite.config.js` proxy hardcoded to `127.0.0.1:8000`** — breaks in preview/container where backend is on another host. Use `env VITE_PROXY_TARGET` or rely solely on `VITE_API_URL`.
9. **`useAiRoadmap` cache & spam** — no debounce/cache; rapid slider changes retrigger 20s Gemini calls; no abort `AbortController`. Add `useRef` cache keyed by `{career, hash(gaps)}` + 5 min TTL.
10. **CORS `allow_credentials=True` + wildcard `allow_methods=["*"]`** — tighten to `GET,POST`.
11. **Career-skill FK without composite unique** → duplicate rows possible.

### 🟢 Low / Nits
12. `requirements.txt` missing `python-multipart`, `python-dotenv` pinned version not locked? Actually `dotenv` used but ok.
13. `App.jsx` `saveState` runs on every keystroke/slider → throttle/debounce.
14. `resource-type` pills have low contrast in roadmap.
15. `frontend/package.json` has `@tailwindcss/vite` `^4.3.3` but `tailwindcss` `^4.3.3` — lock to same minor.
16. No CI (`gh-actions`), no root `README.md` (only frontend).
17. `oxlint` `only-export-components` warns on hooks files exporting non-components — adjust or suppress.

---

## 8) Security & Reliability Checklist

| Check | Verdict |
|---|---|
| Secrets in repo | ❌ `.env` committed |
| Auth | ⚠️ none — all endpoints public (fine for demo, not prod) |
| Input validation | ✅ Pydantic `SkillGapRequest`, clamping 0-100 |
| SQL injection | ✅ ORM, no raw user SQL except safe `text("SELECT 1")` |
| Rate limiting | ❌ missing on `/api/ai/roadmap` (LLM cost) |
| Error surfacing | ⚠️ `database_test`/`debug_db` return `str(e)` (stack-leak risk) |
| Dependency pinning | ✅ pinned in requirements + lock in `package-lock.json` (but bloated) |
| CORS origin lock | ⚙️ env-driven but fallback open locally |

---

## 9) Testing

* **Frontend:** 11 tests in `scoring.test.js` cover `computeResults` (null, match, sorting, cap, readiness tiers) and `computeCareerRecommendations` (empty, exclude self, sort/cap, filter zero, overlapping math). **Pass rate 100%**, but no tests for `resources`, `share`, or components (Vitest + RTL could be added). Run: `npm --prefix frontend test`.
* **Backend:** **0 tests** — add `pytest` + `httpx` for FastAPI, freeze scoring expectations, mock Gemini.

---

## 10) Performance

* **Bundle:** 68 kB gzipped — good. Could code-split `AiRecommendation`/`Recharts`.
* **API:** `GET /api/careers/domain/{id}/with-skills` does 3 queries (careers→requirements→skills) + Python loops — fine to ~1k careers; add pagination if >5k.
* **DB:** no indexes beyond PK/FK; consider `index on career_skill_requirements(career_id, skill_id)` and `skills_v2.name`.

---

## 11) Recommended Next Steps (prioritized)

**P0 — before any deployment:**
1. Re-encode `requirements.txt` to UTF-8, prune deps, add `.gitignore` to exclude `__pycache__/`, `.env`, `node_modules`, `dist`, `.venv`; untrack `.pyc` (`git rm --cached`).
2. Add `backend/.env.example` (`DB_*`, `GEMINI_API_KEY`, `ALLOWED_ORIGINS`, `GEMINI_MODEL`, `VITE_API_URL`) and move real `.env` out of repo; rotate `root/1234`.
3. Add missing CSS (or rename JSX) — quick fix: copy `assessment-section` → `assessment-step`, define `.header/.hero/.brand*` from Figma, style `analyze-button` like `.primary-button`.
4. Disable `/api/debug-db` in prod (`if os.getenv("DEBUG") != "true": 404`).

**P1 — this week:**
5. Unify scoring: delete `POST /api/analyze` or make frontend call it; align readiness strings + add `priority` to UI if kept.
6. Add `docker-compose.yml` (MySQL 8 + FastAPI + Vite preview), `init.sql` seed, and `alembic/` migrations.
7. Tighten `requirements.txt` + `package.json`, add `npm audit` / `pip-audit`, add GitHub Actions (lint+test+build).
8. Cache AI roadmap (3-5 min) + `AbortController` + debounce 400ms.

**P2 — polish:**
9. Add backend `pytest` suite, frontend RTL tests for `SkillsRater`/`share`.
10. Add root `README.md` (setup: `python -m venv`, `pip install`, `uvicorn backend.main:app --reload` ; `npm i && npm run dev` ; env vars).
11. Accessibility pass (focus rings, label `for`, contrast), `aria-live` for results.
12. Consider SQLite fallback for offline/demo (`DATABASE_URL` switch if `DB_HOST` empty).

---

## 12) Verdict

This is a **production-candidate MVP** — the happy path is polished and the code is readable and componentized. With the **P0 fixes (UTF-8 requirements, ignore `.env/__pycache__`, missing styles, debug endpoint, DB bootstrap)** plus **scoring unification**, it’s shippable as a student/portfolio tool. For enterprise use, add auth, rate limiting, migrations, and proper secret management.

*If you want me to apply the P0 fixes now, say “apply P0” and I’ll patch the branch, push, and open a PR.*

---

*Generated by local static analysis — no LLM data was sent. All file references are relative to `ai_skill_gap_analyser/`.*
