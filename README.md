# AI Skill Gap Analyzer

Analyze your skills, discover your career readiness, and get a personalized
priority learning plan — powered by FastAPI + MySQL + React.

![stack](https://img.shields.io/badge/Frontend-React%2019%20%2B%20Vite%208-38bdf8)
![stack](https://img.shields.io/badge/Backend-FastAPI%20%2B%20MySQL-6366f1)

## Features

- **4-step assessment** — education → career domain → target career → rate your skills (0–100 sliders)
- **Career analysis** — match score ring, readiness tier, strong skills, prioritized skill gaps
- **Alternative career recommendations** — careers in the same domain ranked by your current profile
- **📚 Learning resources** — every skill gap comes with curated docs, roadmaps, and free courses
- **🔗 Shareable results** — copy a link that restores the whole analysis
- **💾 Persistence** — your selections are restored on the next visit (localStorage)
- **Progress stepper + animations** — with `prefers-reduced-motion` support
- Accessible: skip-link, aria-labels, focus rings, `role="alert"` errors

## Project structure

```
backend/            FastAPI app + SQLAlchemy models (MySQL)
frontend/           React 19 + Vite 8 app (see frontend/README.md)
FRONTEND_UPGRADE_GUIDE.md   Audit + roadmap (bugs, architecture, next steps)
```

## Getting started

### 1. Backend (FastAPI + MySQL)

```bash
# create the database once
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS ai_skill_gap CHARACTER SET utf8mb4;"

cd backend
pip install -r requirements.txt

# create tables (or import your data dump instead)
python -c "import database, models; database.Base.metadata.create_all(bind=database.engine)"

# run the API
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

> DB credentials live in `backend/database.py` (default `root:1234@localhost:3306/ai_skill_gap`).
> Swagger docs: http://127.0.0.1:8000/docs

### 2. Frontend (React + Vite)

```bash
cd frontend
npm install
npm run dev        # http://localhost:5173
```

In development, Vite proxies `/api` → `http://127.0.0.1:8000`, so the frontend
works from any host without CORS setup. For a hosted API, set `VITE_API_URL`
(see `frontend/.env.example`). The backend accepts origins from the
`ALLOWED_ORIGINS` env var (comma-separated).

### 3. Scripts

| Command | What it does |
|---|---|
| `npm run dev` | start the dev server (port 5173) |
| `npm run build` | production build → `dist/` |
| `npm run lint` | oxlint |
| `npm test` | Vitest unit tests (scoring logic) |
| `npm run preview` | preview the production build (port 4173) |

## Testing

`frontend/src/lib/scoring.js` holds pure, unit-tested scoring math:

```bash
cd frontend
npm test
```
