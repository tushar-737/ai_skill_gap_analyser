"""Main skills for the Data Science field.

Only the unique skills the user asked for. Composite names
(Statistics & Probability, Pandas & NumPy, Data Visualization)
and ML sub-topics (Supervised / Unsupervised / Feature Engineering)
are treated as duplicates of the main skills and are not shown.
"""

from __future__ import annotations

import re
from typing import Dict, Iterable, List, Optional, Sequence, Tuple


MAX_MAIN_SKILLS = 10

SKILL_ALIASES = {
    "np": "numpy",
    "numpy": "numpy",
    "pd": "pandas",
    "pandas": "pandas",
    "python pandas": "pandas",
    "pandas numpy": "pandas",
    "pandas & numpy": "pandas",
    "sklearn": "scikit-learn",
    "scikit learn": "scikit-learn",
    "scikit-learn": "scikit-learn",
    "ml": "machine learning",
    "machine-learning": "machine learning",
    "dl": "deep learning",
    "stats": "statistics",
    "statistics probability": "statistics",
    "statistics & probability": "statistics",
    "descriptive statistics": "statistics",
    "inferential statistics": "statistics",
    "probability": "statistics",
    "nlp": "natural language processing",
    "eda": "data analysis",
    "exploratory data analysis": "data analysis",
    "data wrangling": "data analysis",
    "data cleaning": "data analysis",
    "data visualization": "matplotlib",
}

DATA_SCIENCE_MAIN = (
    "Python",
    "R",
    "SQL",
    "Statistics",
    "Pandas",
    "NumPy",
    "Data Analysis",
    "Matplotlib",
)

DATA_SCIENTIST_MAIN = DATA_SCIENCE_MAIN + (
    "Machine Learning",
    "Scikit-learn",
)

AI_ML_MAIN = (
    "Python",
    "SQL",
    "Statistics",
    "Pandas",
    "NumPy",
    "Machine Learning",
    "Deep Learning",
    "Natural Language Processing",
)

CORE_SKILLS_BY_CAREER: Dict[str, Tuple[str, ...]] = {
    "data analyst": DATA_SCIENCE_MAIN,
    "data scientist": DATA_SCIENTIST_MAIN,
    "business intelligence analyst": DATA_SCIENCE_MAIN,
    "data visualization specialist": DATA_SCIENCE_MAIN,
    "quantitative analyst": DATA_SCIENCE_MAIN,
    "machine learning engineer": AI_ML_MAIN,
    "ai engineer": AI_ML_MAIN,
    "nlp engineer": AI_ML_MAIN,
    "computer vision engineer": AI_ML_MAIN,
    "deep learning engineer": AI_ML_MAIN,
}


def normalize_skill_name(name: Optional[str]) -> str:
    cleaned = re.sub(r"[\s_\-./]+", " ", (name or "").strip().lower())
    cleaned = cleaned.replace("&amp;", "&").replace("&", " ").replace("+", " ")
    cleaned = re.sub(r"[()]+", "", cleaned)
    cleaned = re.sub(r"\s+", " ", cleaned).strip()
    return SKILL_ALIASES.get(cleaned, cleaned)


def normalize_career_name(name: Optional[str]) -> str:
    return re.sub(r"[\s_\-]+", " ", (name or "").strip().lower())


def _field_text(career_name: Optional[str], domain_name: Optional[str]) -> str:
    return f"{career_name or ''} {domain_name or ''}".lower()


def core_skills_for(
    career_name: Optional[str],
    domain_name: Optional[str] = None,
) -> Optional[Tuple[str, ...]]:
    career = normalize_career_name(career_name)
    if career in CORE_SKILLS_BY_CAREER:
        return CORE_SKILLS_BY_CAREER[career]
    for key, skills in CORE_SKILLS_BY_CAREER.items():
        if key in career:
            return skills

    text = _field_text(career_name, domain_name)
    if any(
        token in text
        for token in (
            "machine learning",
            "artificial intelligence",
            "deep learning",
            "nlp",
        )
    ) or re.search(r"\bai\b", text):
        return AI_ML_MAIN
    if any(
        token in text
        for token in (
            "data science",
            "analytics",
            "data analyst",
            "data scientist",
            "quantitative",
            "business intelligence",
        )
    ):
        return DATA_SCIENCE_MAIN
    return None


def _skill_label(item: dict) -> str:
    return item.get("name") or item.get("skill") or item.get("skill_name") or ""


def _required_level(item: dict) -> int:
    try:
        return int(item.get("required_level") or 0)
    except (TypeError, ValueError):
        return 0


def dedupe_skills(skills: Iterable[dict]) -> List[dict]:
    best: Dict[str, dict] = {}
    for item in skills:
        key = normalize_skill_name(_skill_label(item))
        if not key:
            continue
        previous = best.get(key)
        if previous is None or _required_level(item) > _required_level(previous):
            best[key] = item
    return list(best.values())


def select_main_skills(
    career_name: Optional[str],
    skills: Sequence[dict],
    domain_name: Optional[str] = None,
    max_skills: int = MAX_MAIN_SKILLS,
) -> List[dict]:
    unique = dedupe_skills(skills)
    core = core_skills_for(career_name, domain_name)

    if not core:
        extras = {
            "java", "c", "c++", "c#", "javascript",
            "engineering drawing", "cad", "quality control",
        }
        unique = [
            item
            for item in unique
            if normalize_skill_name(_skill_label(item)) not in extras
        ]
        unique.sort(key=_required_level, reverse=True)
        return unique[:max_skills]

    rank = {normalize_skill_name(name): index for index, name in enumerate(core)}
    selected = []
    used = set()
    for item in unique:
        key = normalize_skill_name(_skill_label(item))
        if key not in rank or key in used:
            continue
        used.add(key)
        selected.append((rank[key], item))
    selected.sort(key=lambda pair: pair[0])
    return [item for _, item in selected[:max_skills]]
