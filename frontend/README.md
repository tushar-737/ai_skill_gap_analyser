# AI Skill Gap Analyzer — Frontend

React 19 + Vite 8 + Tailwind v4. The assessment wizard, career analysis, and
recommendation UI.

## Scripts

| Command | What it does |
|---|---|
| `npm run dev` | dev server (port 5173, proxies `/api` → `http://127.0.0.1:8000`) |
| `npm run build` | production build → `dist/` |
| `npm run lint` | oxlint |
| `npm test` | Vitest unit tests |
| `npm run preview` | preview the production build (port 4173) |

## Environment

| Variable | Purpose |
|---|---|
| `VITE_API_URL` | Optional. Absolute base URL for the API. Leave empty to use the Vite proxy (`/api`). See `.env.example`. |

## Structure

```
src/
├── api/api.js               # fetch wrapper + endpoint functions
├── hooks/                   # data-fetching hooks (per resource)
│   ├── useInitialData.js    # education programs + domains
│   ├── useCareers.js        # careers by domain
│   ├── useDomainCareerSkills.js
│   └── useCareerSkills.js   # required skills for the career
├── lib/
│   ├── scoring.js           # pure scoring math (unit-tested)
│   ├── resources.js         # skill → learning links
│   ├── share.js             # share-link encode/decode + clipboard
│   └── storage.js           # localStorage persistence
├── components/
│   ├── layout/              # Header, Hero, Footer
│   ├── assessment/          # Stepper, StepCard, Education/Domain/Career/Skills steps
│   ├── results/             # ResultsSection, ScoreCard, SummaryCards, SkillListCard, PriorityList, AiRecommendation
│   ├── recommendations/     # CareerRecommendations
│   └── ui/                  # ErrorBanner, LoadingScreen, MatchChart
├── App.jsx                  # container: state + composition (~280 lines)
└── main.jsx
```

## Feature notes

- **Share links**: results are encoded into the URL hash (`#/share/...`).
  Opening such a link restores selections + skill levels and shows the analysis.
- **Persistence**: the assessment is saved to localStorage and restored on the
  next visit.
- **Learning resources**: each skill gap links to curated docs/roadmaps/courses
  (`lib/resources.js` — extend the map to add more skills).
- **Reduced motion**: the count-up score and entrance animations are disabled
  when the user prefers reduced motion.
