"""Curated main-skill profiles used when a career's seed data is noisy.

The Workbench seed / repair scripts dump overlapping libraries (Pandas + NumPy
repeated via aliases) and filler languages (Java, C, C++) onto Data Science
roles. The analyzer should only ask the user to rate the skills that actually
define the job.
"""

from __future__ import annotations

import re
from typing import Dict, Iterable, List, Optional, Sequence, Tuple


MAX_MAIN_SKILLS = 10

# Treat these as the same skill so "Pandas" / "pandas" / "Python Pandas"
# never appear twice on a slider list.
SKILL_ALIASES = {
    "np": "numpy",
    "numpy": "numpy",
    "pd": "pandas",
    "pandas": "pandas",
    "python pandas": "pandas",
    "pandas python": "pandas",
    "sklearn": "scikit-learn",
    "scikit learn": "scikit-learn",
    "scikit-learn": "scikit-learn",
    "ml": "machine learning",
    "machine-learning": "machine learning",
    "dl": "deep learning",
    "powerbi": "power bi",
    "ms excel": "excel",
    "microsoft excel": "excel",
    "eda": "exploratory data analysis",
    "exploratory analysis": "exploratory data analysis",
    "data wrangling": "data cleaning",
    "data munging": "data cleaning",
    "descriptive statistics": "statistics",
    "inferential statistics": "statistics",
    "stats": "statistics",
    "tf": "tensorflow",
    "torch": "pytorch",
    "nlp": "natural language processing",
    "llm": "large language models",
    "llms": "large language models",
    "cv": "computer vision",
    "postgres": "postgresql",
    "js": "javascript",
    "ts": "typescript",
    "node": "node.js",
    "nodejs": "node.js",
}

# Never show these unless the career is actually about them.
ALWAYS_FILLER = {
    "engineering drawing",
    "cad",
    "autocad",
    "solidworks",
    "quality control",
    "vs code",
    "visual studio code",
    "gitlab",
    "github",
    "jupyter notebook",
    "command line",
    "bash",
    "problem solving",
    "communication",
    "communication skills",
    "teamwork",
    "time management",
    "adaptability",
    "critical thinking",
    "decision making",
    "leadership",
}

LANGUAGE_FILLER = {
    "java",
    "c",
    "c++",
    "c#",
    "javascript",
    "typescript",
    "php",
    "kotlin",
    "swift",
    "dart",
    "go",
    "ruby",
}

# Role-defining skills only. Order is the display order.
# Levels are used when we need to re-seed SQL; the live API keeps the DB level
# if the skill already exists on the career.
CORE_SKILLS_BY_CAREER: Dict[str, Tuple[str, ...]] = {
    "data analyst": (
        "Python",
        "SQL",
        "Pandas",
        "Excel",
        "Data Cleaning",
        "Exploratory Data Analysis",
        "Power BI",
        "Statistics",
    ),
    "data scientist": (
        "Python",
        "SQL",
        "Pandas",
        "NumPy",
        "Machine Learning",
        "Statistics",
        "Scikit-learn",
        "Model Evaluation",
        "Feature Engineering",
        "Matplotlib",
    ),
    "business intelligence analyst": (
        "SQL",
        "Excel",
        "Power BI",
        "Tableau",
        "Data Analysis",
        "Dashboard Design",
        "Data Storytelling",
        "Python",
    ),
    "data visualization specialist": (
        "Tableau",
        "Power BI",
        "Python",
        "Matplotlib",
        "Seaborn",
        "Dashboard Design",
        "Data Storytelling",
        "Plotly",
    ),
    "quantitative analyst": (
        "Python",
        "R",
        "SQL",
        "Statistics",
        "Probability",
        "Regression Analysis",
        "Linear Algebra",
        "Time Series Analysis",
    ),
    "machine learning engineer": (
        "Python",
        "Machine Learning",
        "Scikit-learn",
        "NumPy",
        "Pandas",
        "Feature Engineering",
        "Model Evaluation",
        "SQL",
    ),
    "ai engineer": (
        "Python",
        "Artificial Intelligence",
        "Machine Learning",
        "Deep Learning",
        "PyTorch",
        "TensorFlow",
        "Generative AI",
        "Prompt Engineering",
    ),
    "nlp engineer": (
        "Python",
        "Natural Language Processing",
        "Transformers",
        "Large Language Models",
        "Deep Learning",
        "PyTorch",
        "Machine Learning",
        "NumPy",
    ),
    "computer vision engineer": (
        "Python",
        "Computer Vision",
        "Deep Learning",
        "PyTorch",
        "OpenCV",
        "TensorFlow",
        "Machine Learning",
        "NumPy",
    ),
    "deep learning engineer": (
        "Python",
        "Deep Learning",
        "Neural Networks",
        "PyTorch",
        "TensorFlow",
        "Linear Algebra",
        "NumPy",
        "Machine Learning",
    ),
    "data engineer": (
        "Python",
        "SQL",
        "ETL",
        "PostgreSQL",
        "Spark",
        "Airflow",
        "Docker",
        "AWS",
    ),
}


def normalize_skill_name(name: Optional[str]) -> str:
    cleaned = re.sub(r"[\s_\-./]+", " ", (name or "").strip().lower())
    cleaned = re.sub(r"[()]+", "", cleaned).strip()
    return SKILL_ALIASES.get(cleaned, cleaned)


def normalize_career_name(name: Optional[str]) -> str:
    return re.sub(r"[\s_\-]+", " ", (name or "").strip().lower())


def core_skills_for(career_name: Optional[str]) -> Optional[Tuple[str, ...]]:
    return CORE_SKILLS_BY_CAREER.get(normalize_career_name(career_name))


def _skill_label(item: dict) -> str:
    return (
        item.get("name")
        or item.get("skill")
        or item.get("skill_name")
        or ""
    )


def _required_level(item: dict) -> int:
    try:
        return int(item.get("required_level") or 0)
    except (TypeError, ValueError):
        return 0


def dedupe_skills(skills: Iterable[dict]) -> List[dict]:
    """Keep one row per canonical skill name (highest required level wins)."""
    best: Dict[str, dict] = {}
    for item in skills:
        key = normalize_skill_name(_skill_label(item))
        if not key:
            continue
        previous = best.get(key)
        if previous is None or _required_level(item) > _required_level(previous):
            best[key] = item
    return list(best.values())


def _career_owns_language(career_name: str, language: str) -> bool:
    career = normalize_career_name(career_name)
    if language == "c++":
        return "c++" in career
    if language == "c#":
        return "c#" in career
    if language == "c":
        return bool(re.search(r"\bc\b", career)) and "c++" not in career and "c#" not in career
    if language == "java":
        return "java" in career and "javascript" not in career
    if language in {"javascript", "typescript"}:
        return any(
            token in career
            for token in (
                "javascript",
                "frontend",
                "front end",
                "react",
                "node",
                "full stack",
                "fullstack",
                "web",
            )
        )
    return language in career


def _is_filler(skill_key: str, career_name: str, domain_name: str) -> bool:
    domain = normalize_career_name(domain_name)
    if skill_key in ALWAYS_FILLER:
        if skill_key in {"engineering drawing", "cad", "autocad", "solidworks"}:
            career = normalize_career_name(career_name)
            return not (
                domain == "engineering"
                or any(
                    token in career
                    for token in (
                        "civil",
                        "mechanical",
                        "electrical",
                        "electronics",
                        "industrial",
                    )
                )
            )
        return True
    if skill_key in LANGUAGE_FILLER:
        return not _career_owns_language(career_name, skill_key)
    return False


def select_main_skills(
    career_name: Optional[str],
    skills: Sequence[dict],
    domain_name: Optional[str] = None,
    max_skills: int = MAX_MAIN_SKILLS,
) -> List[dict]:
    """Return the unique, role-defining skills for a career.

    Data Science / ML roles use an explicit allow-list so extra libraries and
    dumped languages never reach the rater. Other careers are de-duplicated
    and trimmed to the highest-priority skills.
    """
    unique = dedupe_skills(skills)
    core = core_skills_for(career_name)

    if core:
        rank = {normalize_skill_name(name): index for index, name in enumerate(core)}
        selected = []
        for item in unique:
            key = normalize_skill_name(_skill_label(item))
            if key in rank:
                selected.append((rank[key], item))
        selected.sort(key=lambda pair: pair[0])
        return [item for _, item in selected[:max_skills]]

    filtered = [
        item
        for item in unique
        if not _is_filler(
            normalize_skill_name(_skill_label(item)),
            career_name or "",
            domain_name or "",
        )
    ]
    filtered.sort(key=_required_level, reverse=True)
    return filtered[:max_skills]
