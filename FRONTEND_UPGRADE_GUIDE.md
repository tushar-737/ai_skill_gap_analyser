# Frontend Upgrade Guide — AI Skill Gap Analyzer

> Audit date: 2026-08-09 · Branch: `arena/019fe75b-ai-skill-gap-analyser`
> Scope: `frontend/` (React 19 + Vite 8 + Tailwind v4) with notes on how the FastAPI backend affects the frontend.

---

## 1. Verdict (TL;DR)

The app is a **solid, working single-page assessment tool**: it builds cleanly (`vite build` ✓), passes `oxlint` with 0 errors, has a polished dark UI, good responsive behavior, and thoughtful accessibility touches (skip-link, aria-labels, focus rings, `role="list"`).

It is not yet a "great **project**" because of **architecture and polish gaps**, not feature gaps:

1. The entire UI lives in **one 1,541-line component** (`App.jsx`) with hand-rolled `useEffect` data-fetching.
2. There is **dead code and dead dependencies** (a 902-line unused component, unused router/chart libs, unused assets).
3. There are **a few real bugs** (invisible score text on the dark theme, hardcoded `127.0.0.1` API URL, CORS allowlist that blocks non-localhost origins, duplicated CSS).
4. It's **single-page with no persistence** — results vanish on refresh, and the "AI" angle is static rule-based text.

Everything below is verified against the actual code. Fix P0 items first (a few hours), then work through P1/P2.

---

## 2. What's already good (keep it)

| Area | Evidence |
|---|---|
| Clean build & lint | `vite build` ✓ (205 kB JS / 64 kB gzip), `oxlint` 0 warnings |
| Visual design | Consistent dark theme, gradient accents, glass cards, fluid `clamp()` typography |
| Responsiveness | `@media (max-width: 700px)` handled for cards, results, skill rows |
| Accessibility basics | Skip link, `aria-label`s on selects/button, visible focus rings, `role="list"`/`listitem`, SVG `role="img"` + label |
| Performance basics | `useMemo` for score math, single small bundle, no heavy chart lib in the main bundle |
| Backend API | Clean REST endpoints with DB session handling; `with-skills` endpoint already enables smart recommendations |
| Skill-gap math | Match score, readiness tiers, priority ordering, alternative-career matching — the core logic is genuinely useful |

---

## 3. Verified issues (bugs first)

### 🔴 3.1 Bugs

**B1. Match score text is nearly invisible on the dark theme**
`frontend/src/components/MatchChart.jsx`:
- `<text fill="#111827">` → near-black text on a dark background.
- `<circle stroke="#eee">` → harsh white track ring.

Fix: use theme colors (e.g. `fill: #e2e8f0`, track `rgba(148,163,184,0.15)`) or accept `currentColor` props.

**B2. Hardcoded API URL breaks every deployment**
`frontend/src/api/api.js` → `const API_BASE_URL = "http://127.0.0.1:8000"`.
`127.0.0.1` means "the user's own machine". In any hosted environment (Netlify/Vercel/preview URLs), every request fails.

Fix (standard Vite pattern):
- `vite.config.js`: `server.proxy = { "/api": "http://127.0.0.1:8000" }`
- `api.js`: use relative `/api/...` by default, overridable via `import.meta.env.VITE_API_URL`.

**B3. Backend CORS blocks non-localhost origins**
`backend/main.py` hardcodes `allow_origins = ["http://localhost:5173/5175", "http://127.0.0.1:5173/5175"]`.
Any other host (LAN IP, preview, deployed domain) gets CORS errors in the browser.

Fix: read origins from an env var (e.g. `ALLOWED_ORIGINS`) and default to `["*"]`-style wildcard in dev, or use the `allow_origin_regex` pattern.

**B4. Duplicated CSS**
`frontend/src/App.css` defines `.skills-list` / `.skill-row` twice (once in the main section, once in a trailing "Skill rating controls" block with `!important` overrides — a smell that something was being fought). `index.css` and `App.css` both set `body` font/background.

Fix: delete the trailing duplicate block, consolidate base styles into `index.css`, keep component styles in one place.

**B5. SVG gradient ID collision**
`MatchChart.jsx` hardcodes `id="grad"` inside `<defs>`. If a second chart renders on the page (compare view, dashboard), IDs collide and gradients render wrong.

Fix: use React 19's `useId()`.

**B6. `alert()` for validation**
`App.jsx` `handleAnalyze()` pops browser alerts. They interrupt flow and are inconsistent with the inline design.

Fix: inline error text under the relevant step + `aria-invalid` / `aria-describedby`.

### 🟠 3.2 Dead code & tech debt

**D1. `Assessment.jsx` (902 lines) is unused and broken**
- Imported nowhere (`grep` confirms).
- Calls `POST /api/analyze` — **that endpoint does not exist** in `backend/main.py`, so it could never work.
- Contains hardcoded skill/career lists and its own duplicated UI.

Fix: delete it (and remove `axios`, which only it uses) — or, if you want that "add your own skills / resume upload" feature, build it properly against a real backend endpoint (see R9).

**D2. Unused dependencies** — `package.json`:
| Package | Status |
|---|---|
| `axios` | only used by dead `Assessment.jsx` → remove |
| `react-router-dom` | never imported → remove or adopt (P1) |
| `recharts` | never imported → remove or adopt (P2 dashboard) |
| `lucide-react` | only used by dead `Assessment.jsx` → remove (or adopt for icons — recommended) |
| `tailwindcss` / `@tailwindcss/vite` | imported in `index.css`, but ~95% of styles are hand-written CSS → pick one system |

Removing dead deps shrinks `package.json`, install time, and bundle; oxlint then has fewer files to ignore.

**D3. Unused assets** — `src/assets/hero.png`, `public/icons.svg` are never referenced. Delete or use them (hero image could actually improve the hero section).

**D4. Monolithic component** — `App.jsx` = 1,541 lines holding state, data fetching, business logic, and ~8 UI sections. Hard to test, easy to break, painful to extend.

**D5. Stray root `package-lock.json`** — an empty lockfile at the repo root; the real one is in `frontend/`. Delete it.

**D6. `index.html` metadata** — `<title>frontend</title>`, no meta description, no Open Graph/Twitter tags, no theme-color. This is your SEO/social-sharing front door.

### 🟡 3.3 Small UX gaps

- **No loading skeletons** — only plain text ("Loading careers...", "Loading required skills...") or a full-screen spinner.
- **No empty/error distinction** — "Unable to connect to the backend." covers both network and 500s; no retry button.
- **No persistence** — close the tab, everything is gone; no way to share a result or track progress over time.
- **Long selects** — education/domain lists grow; native `<select>` gets unwieldy (no search).
- **No animation** — results section appears instantly; a little motion would make "analysis complete" feel rewarding.
- **`prefers-reduced-motion`** not respected (smooth scroll + spinner are fine, but animations should respect it when added).
- **Contrast** — some `#64748b` captions on `#0f172a` are borderline (≈4.1:1); fine for large text, worth checking for small captions.

---

## 4. Upgrade roadmap (prioritized)

### ✅ P0 — Quick wins · a few hours · do these today

| # | Change | Files | Impact |
|---|---|---|---|
| 1 | Fix MatchChart colors + `useId` | `MatchChart.jsx` | Visible bug fix |
| 2 | Vite proxy `/api` → `http://127.0.0.1:8000`; relative URLs in `api.js` + `VITE_API_URL` override | `vite.config.js`, `api.js` | Makes app deployable |
| 3 | Backend CORS from env var / regex | `backend/main.py` | Unblocks any host |
| 4 | Delete `Assessment.jsx`, unused deps, unused assets, root lockfile | repo | Removes 900+ lines dead code |
| 5 | Dedupe CSS, move base styles to `index.css` | `App.css`, `index.css` | Maintainability |
| 6 | Real `index.html` metadata (title, description, OG, theme-color) | `index.html` | SEO/sharing |
| 7 | Replace `alert()` with inline errors + `aria-describedby` | `App.jsx` | UX + a11y |
| 8 | Add `vite.config` `server.host: true` + preview config | `vite.config.js` | Easier to run anywhere |

### 🚀 P1 — Short-term · 2–5 days · biggest quality leap

1. ✅ **Split `App.jsx` into components** — **done**: `src/hooks/useInitialData.js`, `useCareers.js`, `useDomainCareerSkills.js`, `useCareerSkills.js` + pure scoring in `src/lib/scoring.js`. (TanStack Query still optional later.)
2. ✅ **Stepper UI** — done: `Stepper.jsx` shows progress through the 4 steps with an animated progress bar.
3. ✅ **Persistence** — done: `lib/storage.js` (localStorage auto-save/restore) + `lib/share.js` (shareable `#/share/...` links that restore the full analysis; "Share Result Link" button).
4. **Skeletons + retry** — partially done: loading states exist per step; a Retry button on the global error banner is still open.
5. ✅ **Results animations** — done: fade/slide-in on results, score count-up; respects `prefers-reduced-motion`.
6. **Icons** — open: adopt `lucide-react` (small, tree-shakable) and replace emoji/`✓/!/→` glyphs for a consistent cross-platform look.
7. ✅ **Suggested learning resources per gap** — done: `lib/resources.js` maps ~30 skills to curated links (docs, roadmap.sh, courses); rendered as "Learn it" pills on each gap. Extend the map to add more skills.
8. **Compare careers** — open: side-by-side mode (selected career vs. top alternative) reusing `MatchChart`.

### 🏗️ P2 — Long-term · 1–3 weeks · "production-grade project"

1. **TypeScript migration** — the single biggest "good project" signal. Types for `Skill`, `Career`, `Domain`, `AnalysisResult` turn the gap math into compile-checked code. Do it incrementally (`.tsx` per component; `tsc --noEmit` in CI). *Still open — recommended as its own dedicated pass.*
2. ✅ **Testing** — **done**: Vitest + unit tests for `lib/scoring.js` (`npm test`). Next step: component tests with React Testing Library, and a mocked-API flow test of the assessment.
3. **React Router adoption** — `#/` home (assessment), `#/results/:id` (shareable result page), `#/dashboard` (history/progress). The package is already in `package.json`.
4. **Dashboard with progress over time** — if you add history persistence, `recharts` (already installed) can plot readiness-score trends across re-assessments.
5. **State management** — TanStack Query for server state + plain context for the assessment wizard. No Redux needed at this scale.
6. **Code splitting** — `React.lazy` the results section / dashboard so the initial bundle stays small.
7. **CI/CD** — GitHub Actions: `lint → test → build` on PR; auto-deploy to Vercel/Netlify (free tier is fine).
8. **Error monitoring** — ErrorBoundary + Sentry once deployed.
9. **README + docs** — replace the Vite template README with setup/scripts/architecture/API docs; add `.env.example`.
10. **i18n / theme toggle** — CSS variables make a light theme cheap; i18n only if you have a real audience need.

---

## 5. Suggested file structure after refactor

> ✅ **P1a status (2026-08-09): implemented.** `App.jsx` (was 1,541 lines) is now a ~280-line container; fetching lives in `src/hooks/*`, scoring math in `src/lib/scoring.js` (pure, testable), and UI in `src/components/**`. The tree below matches the actual code (layout/ui/assessment/results/recommendations).

```
frontend/src/
├── api/
│   ├── client.js          # fetch wrapper, base URL from env, error normalization
│   └── endpoints.js       # typed API functions
├── components/
│   ├── layout/
│   │   ├── Header.jsx
│   │   ├── Footer.jsx
│   │   └── Stepper.jsx
│   ├── assessment/
│   │   ├── EducationStep.jsx
│   │   ├── DomainStep.jsx
│   │   ├── CareerStep.jsx
│   │   └── SkillsRater.jsx   # skill rows + slider
│   ├── results/
│   │   ├── ScoreCard.jsx
│   │   ├── SkillList.jsx     # strong skills / gaps (reused)
│   │   ├── PriorityList.jsx
│   │   ├── Recommendation.jsx
│   │   └── ResultsSection.jsx
│   └── ui/
│       ├── MatchChart.jsx    # useId, theme colors
│       ├── Skeleton.jsx
│       ├── ErrorBanner.jsx   # with Retry
│       └── Select.jsx        # searchable combobox
├── hooks/
│   ├── useEducation.js       # or use TanStack Query
│   ├── useCareers.js
│   └── useLocalStorage.js
├── lib/
│   ├── scoring.js            # pure functions: matchScore, readiness, gaps
│   └── links.js              # skill → learning resources map
├── pages/
│   ├── Home.jsx
│   └── Result.jsx            # shareable deep link
├── styles/
│   ├── index.css             # base, tokens (CSS variables)
│   └── components.css        # or per-component CSS modules
├── App.jsx                   # ~100 lines: composition only
└── main.jsx
```

---

## 6. Priority cheat-sheet

| Effort | Highest impact |
|---|---|
| ⏱️ 1–2 h | Fix MatchChart colors · delete dead code/deps · Vite proxy + CORS env |
| Half a day | Inline validation · index.html metadata · CSS cleanup |
| 1 day | Component split + custom hooks · skeletons · localStorage persistence |
| 2–3 days | Stepper UI · shareable results · learning-resource links · animations |
| 1–2 weeks | TypeScript · Vitest + RTL · React Router pages · dashboard with recharts · CI |

---

## 7. Notes on the backend (affects frontend)

- `POST /api/analyze` referenced by the deleted component does not exist — if you revive "custom skills / resume" assessment, add it deliberately (with a real schema) rather than as a hardcoded stub.
- CORS must become environment-driven (P0-3), or every non-localhost deployment of the frontend will fail at the browser.
- Consider adding `/api/analyses` (save/load history) and `/api/resources` (skill → learning links) to power P1-7 and P2-4.
