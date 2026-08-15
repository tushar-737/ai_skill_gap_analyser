import os
import json
import re
import io
import logging
import time
from collections import defaultdict, deque
from threading import Lock
from datetime import datetime
from typing import Dict, List, Optional, Tuple

import requests

from fastapi import FastAPI, Depends, HTTPException, UploadFile, File, Form, Header, Request
from fastapi.middleware.cors import CORSMiddleware

from pydantic import BaseModel, Field

from sqlalchemy.orm import Session
from sqlalchemy import text

from .database import get_db
from . import models

logger = logging.getLogger(__name__)


# =====================================================
# FASTAPI APPLICATION
# =====================================================

app = FastAPI(
    title="AI Skill Gap Analyzer API",
    description=(
        "AI-powered skill gap analysis and "
        "career recommendation system"
    ),
    version="2.0.0",
)


# =====================================================
# CORS
# =====================================================

ALLOWED_ORIGINS = [
    origin.strip()
    for origin in os.getenv(
        "ALLOWED_ORIGINS",
        ""
    ).split(",")
    if origin.strip()
]

if not ALLOWED_ORIGINS:

    ALLOWED_ORIGINS = [
        "http://localhost:5173",
        "http://127.0.0.1:5173",
        "http://localhost:5175",
        "http://127.0.0.1:5175",
    ]


app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    # The app uses no cookies or browser credentials; keep cross-origin calls
    # token/header-based and avoid credentialed CORS exposure.
    allow_credentials=False,
    allow_methods=["GET", "POST", "DELETE", "OPTIONS"],
    allow_headers=["Content-Type", "X-Resume-Session"],
)


# =====================================================
# IN-MEMORY REQUEST LIMITS
# =====================================================
# These limits protect AI quota and upload capacity in a single FastAPI
# process. For multi-instance production deployments, use a shared limiter
# such as Redis or an API gateway instead.
RATE_LIMIT_WINDOW_SECONDS = max(1, int(os.getenv("RATE_LIMIT_WINDOW_SECONDS", "60")))
RESUME_ANALYZE_LIMIT = max(1, int(os.getenv("RESUME_ANALYZE_LIMIT", "5")))
AI_ROADMAP_LIMIT = max(1, int(os.getenv("AI_ROADMAP_LIMIT", "15")))
TRUST_PROXY_HEADERS = os.getenv("TRUST_PROXY_HEADERS", "false").lower() == "true"
_rate_limit_hits = defaultdict(deque)
_rate_limit_lock = Lock()


def _client_identifier(request: Request) -> str:
    if TRUST_PROXY_HEADERS:
        forwarded = request.headers.get("x-forwarded-for", "").split(",")[0].strip()
        if forwarded:
            return forwarded
    return request.client.host if request.client else "unknown"


def _enforce_rate_limit(request: Request, bucket: str, limit: int) -> None:
    now = time.monotonic()
    key = f"{bucket}:{_client_identifier(request)}"
    with _rate_limit_lock:
        hits = _rate_limit_hits[key]
        while hits and now - hits[0] >= RATE_LIMIT_WINDOW_SECONDS:
            hits.popleft()
        if len(hits) >= limit:
            retry_after = max(1, int(RATE_LIMIT_WINDOW_SECONDS - (now - hits[0])))
            raise HTTPException(
                status_code=429,
                detail="Too many requests. Please try again shortly.",
                headers={"Retry-After": str(retry_after)},
            )
        hits.append(now)


# =====================================================
# HOME
# =====================================================

@app.get("/")
def home():

    return {
        "message": "AI Skill Gap Analyzer API is running",
        "status": "success",
        "version": "2.0.0",
    }


# =====================================================
# DATABASE TEST
# =====================================================

@app.get("/api/database-test")
def database_test(
    db: Session = Depends(get_db)
):

    try:

        result = db.execute(
            text("SELECT 1")
        )

        result.fetchone()

        return {
            "status": "success",
            "message": (
                "MySQL database connected successfully"
            ),
        }

    except Exception:
        logger.exception("Database connectivity check failed")
        raise HTTPException(
            status_code=503,
            detail="Database service is unavailable.",
        )


# =====================================================
# EDUCATION CATEGORIES
# =====================================================

@app.get("/api/education-categories")
def get_education_categories(
    db: Session = Depends(get_db)
):

    categories = (
        db.query(models.EducationCategory)
        .order_by(models.EducationCategory.name)
        .all()
    )

    return [
        {
            "id": category.id,
            "name": category.name,
            "description": category.description,
        }
        for category in categories
    ]


# =====================================================
# EDUCATION PROGRAMS
# =====================================================

@app.get("/api/education-programs")
def get_education_programs(
    db: Session = Depends(get_db)
):

    programs = (
        db.query(models.EducationProgram)
        .order_by(models.EducationProgram.name)
        .all()
    )

    return [
        {
            "id": program.id,
            "category_id": program.category_id,
            "name": program.name,
            "level": program.level,
            "description": program.description,
        }
        for program in programs
    ]


# =====================================================
# DOMAINS
# =====================================================

@app.get("/api/domains")
def get_domains(
    db: Session = Depends(get_db)
):

    domains = (
        db.query(models.Domain)
        .order_by(models.Domain.name)
        .all()
    )

    return [
        {
            "id": domain.id,
            "name": domain.name,
            "description": domain.description,
        }
        for domain in domains
    ]


# =====================================================
# ALL CAREERS
# =====================================================

@app.get("/api/careers")
def get_careers(
    db: Session = Depends(get_db)
):

    careers = (
        db.query(models.Career)
        .order_by(models.Career.name)
        .all()
    )

    return [
        {
            "id": career.id,
            "domain_id": career.domain_id,
            "name": career.name,
            "description": career.description,
            "average_level": career.average_level,
        }
        for career in careers
    ]


# =====================================================
# CAREERS BY DOMAIN
# =====================================================

@app.get("/api/careers/domain/{domain_id}")
def get_careers_by_domain(
    domain_id: int,
    db: Session = Depends(get_db)
):

    careers = (
        db.query(models.Career)
        .filter(
            models.Career.domain_id == domain_id
        )
        .order_by(models.Career.name)
        .all()
    )

    return [
        {
            "id": career.id,
            "name": career.name,
            "description": career.description,
            "average_level": career.average_level,
        }
        for career in careers
    ]


# =====================================================
# ALL SKILLS
# =====================================================

@app.get("/api/skills")
def get_skills(
    db: Session = Depends(get_db)
):

    skills = (
        db.query(models.Skill)
        .order_by(models.Skill.name)
        .all()
    )

    return [
        {
            "id": skill.id,
            "name": skill.name,
            "category": skill.category,
            "description": skill.description,
        }
        for skill in skills
    ]


# =====================================================
# SKILLS BY CATEGORY
# =====================================================

@app.get("/api/skills/category/{category}")
def get_skills_by_category(
    category: str,
    db: Session = Depends(get_db)
):

    skills = (
        db.query(models.Skill)
        .filter(
            models.Skill.category == category
        )
        .order_by(models.Skill.name)
        .all()
    )

    return [
        {
            "id": skill.id,
            "name": skill.name,
            "category": skill.category,
            "description": skill.description,
        }
        for skill in skills
    ]


# =====================================================
# CAREER REQUIRED SKILLS
# =====================================================

@app.get("/api/careers/{career_id}/skills")
def get_career_skills(
    career_id: int,
    db: Session = Depends(get_db)
):

    results = (
        db.query(
            models.Skill,
            models.CareerSkillRequirement.required_level,
        )
        .join(
            models.CareerSkillRequirement,
            models.Skill.id
            == models.CareerSkillRequirement.skill_id,
        )
        .filter(
            models.CareerSkillRequirement.career_id
            == career_id
        )
        .order_by(
            models.CareerSkillRequirement.required_level.desc()
        )
        .all()
    )

    return [
        {
            "skill_id": skill.id,
            "name": skill.name,
            "category": skill.category,
            "description": skill.description,
            "required_level": required_level,
        }
        for skill, required_level in results
    ]


# =====================================================
# CAREERS WITH SKILLS BY DOMAIN
# =====================================================

@app.get(
    "/api/careers/domain/{domain_id}/with-skills"
)
def get_careers_with_skills_by_domain(
    domain_id: int,
    db: Session = Depends(get_db)
):

    careers = (
        db.query(models.Career)
        .filter(
            models.Career.domain_id == domain_id
        )
        .order_by(models.Career.name)
        .all()
    )

    if not careers:
        return []


    career_ids = [
        career.id
        for career in careers
    ]


    requirements = (
        db.query(
            models.CareerSkillRequirement
        )
        .filter(
            models.CareerSkillRequirement.career_id.in_(
                career_ids
            )
        )
        .all()
    )


    if not requirements:

        return [
            {
                "id": career.id,
                "name": career.name,
                "description": career.description,
                "average_level": career.average_level,
                "skills": [],
            }
            for career in careers
        ]


    skill_ids = list(
        {
            requirement.skill_id
            for requirement in requirements
        }
    )


    skills = (
        db.query(models.Skill)
        .filter(
            models.Skill.id.in_(skill_ids)
        )
        .all()
    )


    skill_map = {
        skill.id: skill
        for skill in skills
    }


    career_skills = {
        career_id: []
        for career_id in career_ids
    }


    for requirement in requirements:

        skill = skill_map.get(
            requirement.skill_id
        )

        if not skill:
            continue

        career_skills[
            requirement.career_id
        ].append(
            {
                "skill_id": skill.id,
                "skill": skill.name,
                "category": skill.category,
                "description": skill.description,
                "required_level": (
                    requirement.required_level
                ),
            }
        )


    for career_id in career_skills:

        career_skills[career_id].sort(
            key=lambda x: x["required_level"],
            reverse=True,
        )


    return [
        {
            "id": career.id,
            "name": career.name,
            "description": career.description,
            "average_level": career.average_level,
            "skills": career_skills.get(
                career.id,
                [],
            ),
        }
        for career in careers
    ]


# =====================================================
# STATISTICS
# =====================================================

@app.get("/api/statistics")
def get_statistics(
    db: Session = Depends(get_db)
):

    education_count = (
        db.query(
            models.EducationProgram
        ).count()
    )

    domain_count = (
        db.query(
            models.Domain
        ).count()
    )

    career_count = (
        db.query(
            models.Career
        ).count()
    )

    skill_count = (
        db.query(
            models.Skill
        ).count()
    )

    requirement_count = (
        db.query(
            models.CareerSkillRequirement
        ).count()
    )

    return {
        "education_programs": education_count,
        "domains": domain_count,
        "careers": career_count,
        "skills": skill_count,
        "career_skill_requirements": (
            requirement_count
        ),
    }


# =====================================================
# DEBUG DATABASE — gated by DEBUG env
# Never expose DB host/uuid in production
# =====================================================

@app.get("/api/debug-db")
def debug_db(
    db: Session = Depends(get_db)
):

    if os.getenv("DEBUG", "false").lower() != "true":
        raise HTTPException(
            status_code=404,
            detail="Not found",
        )

    try:

        result = db.execute(
            text(
                """
                SELECT
                    DATABASE() AS database_name,
                    @@hostname AS hostname,
                    @@port AS port,
                    @@server_uuid AS server_uuid
                """
            )
        ).mappings().first()


        career_count = db.execute(
            text(
                """
                SELECT COUNT(*) AS total
                FROM careers_v2
                """
            )
        ).scalar()


        careers = db.execute(
            text(
                """
                SELECT id, name
                FROM careers_v2
                ORDER BY id
                """
            )
        ).mappings().all()


        return {
            "status": "success",

            "connection": dict(result)
            if result
            else {},

            "career_count": career_count,

            "careers": [
                dict(career)
                for career in careers
            ],
        }


    except Exception as e:

        return {
            "status": "error",
            "message": str(e),
        }


# =====================================================
# SKILL GAP REQUEST
# =====================================================

class SkillGapRequest(BaseModel):

    skills: Dict[
        int,
        int
    ] = Field(
        default_factory=dict
    )

    # Optional signals used by the weighted recommendation engine.
    # Both are backward compatible: when absent, their weight drops out
    # and the score renormalizes over the remaining signals.
    education: Optional[str] = Field(
        default=None,
        max_length=200,
    )

    resume_skill_ids: Optional[
        List[int]
    ] = Field(
        default=None,
        max_length=500,
    )


# =====================================================
# PRIORITY CALCULATOR
# =====================================================

def get_priority(gap: int):

    if gap <= 0:
        return "None"

    if gap <= 10:
        return "Low"

    if gap <= 30:
        return "Medium"

    if gap <= 50:
        return "High"

    return "Critical"


# =====================================================
# READINESS CALCULATOR
# =====================================================

def get_readiness(match_percentage: float):
    """Keep API readiness labels aligned with frontend/lib/scoring.js."""
    if match_percentage >= 80:
        return "Highly Ready"

    if match_percentage >= 60:
        return "Career Ready"

    if match_percentage >= 40:
        return "Developing"

    return "Beginner"


# =====================================================
# WEIGHTED CAREER-MATCH ENGINE (P3/P4)
# =====================================================
#
# Career Match is no longer a plain average of skill gaps.
# It is a weighted combination of up to four signals:
#
#   Career Match =
#       0.70 * importance-weighted skill coverage
#     + 0.10 * strengths ratio (share of skills fully met)
#     + 0.10 * education compatibility (education <-> domain)
#     + 0.10 * resume evidence (resume-backed skills)
#
# Importance weighting: a skill's weight is required_level^2, so
# skills the career demands most dominate the score quadratically.
# Any signal that was not provided (education / resume) is dropped
# and the remaining weights are renormalized, so older clients that
# only send {skills} keep working with a well-defined score.

ENGINE_WEIGHTS = {
    "skill_coverage": 0.70,
    "strengths": 0.10,
    "education": 0.10,
    "resume_evidence": 0.10,
}

ENGINE_FORMULA = (
    "0.70*skill_coverage + 0.10*strengths + 0.10*education "
    "+ 0.10*resume_evidence (signals that are not provided are "
    "dropped and the weights renormalized)"
)


EDUCATION_DOMAIN_AFFINITY: Dict[str, Dict[str, List[str]]] = {
    "Artificial Intelligence & Data Science": {
        "core": ["data science", "computer", "information technology",
                 "artificial intelligence", "machine learning", "statistics",
                 "bca", "mca"],
        "broad": ["b.tech", "m.tech", "engineering", "mathematics",
                  "physics", "science"],
    },
    "Software Development": {
        "core": ["computer", "software", "information technology",
                 "bca", "mca"],
        "broad": ["b.tech", "m.tech", "electronics", "engineering", "science"],
    },
    "Cloud & DevOps": {
        "core": ["computer", "information technology", "cloud",
                 "bca", "mca", "network"],
        "broad": ["b.tech", "m.tech", "electronics", "electrical",
                  "engineering"],
    },
    "Cybersecurity": {
        "core": ["cyber", "security", "computer", "information technology",
                 "bca", "mca", "network"],
        "broad": ["b.tech", "m.tech", "electronics", "engineering"],
    },
    "UI/UX & Product Design": {
        "core": ["design", "b.des", "fine arts", "bfa", "architecture",
                 "animation"],
        "broad": ["computer", "arts", "media"],
    },
    "Digital Marketing": {
        "core": ["marketing", "bba", "mba", "pgdm", "business"],
        "broad": ["commerce", "communication", "journalism", "arts", "media"],
    },
    "Finance & Accounting": {
        "core": ["commerce", "b.com", "m.com", "finance", "accounting",
                 "economics", "chartered accountant"],
        "broad": ["business", "bba", "mba", "mathematics", "statistics"],
    },
    "Mechanical & Core Engineering": {
        "core": ["mechanical", "civil", "electrical", "automobile",
                 "production"],
        "broad": ["engineering", "b.tech", "m.tech", "diploma"],
    },
    "Healthcare & Life Sciences": {
        "core": ["mbbs", "pharm", "nursing", "biotech", "medicine",
                 "health", "physiotherapy", "dental"],
        "broad": ["biology", "life science", "science", "chemistry"],
    },
    "Content & Media": {
        "core": ["journalism", "mass communication", "media", "literature"],
        "broad": ["english", "arts", "communication", "design", "marketing"],
    },
}


def education_compatibility(
    education: Optional[str],
    domain_name: Optional[str],
) -> Optional[float]:
    """0-1 affinity between the user's education and a career's domain.

    Returns None when education is unknown so callers can drop the
    signal and renormalize weights. 1.0 = direct hit, 0.6 = adjacent
    field, 0.25 = unrelated, 0.5 = domain has no affinity profile.
    """
    if not education or not education.strip():
        return None

    text = education.lower()
    affinity = EDUCATION_DOMAIN_AFFINITY.get(domain_name or "")
    if not affinity:
        return 0.5

    if any(keyword in text for keyword in affinity["core"]):
        return 1.0
    if any(keyword in text for keyword in affinity["broad"]):
        return 0.6
    return 0.25


def _human_join(items: List[str]) -> str:
    """'A', 'B', 'C' -> 'A, B and C'."""
    if len(items) <= 1:
        return items[0] if items else ""
    return ", ".join(items[:-1]) + " and " + items[-1]


def build_career_explanation(
    career_name: str,
    strengths: List[dict],
    gaps: List[dict],
    match_percentage: int,
    readiness: str,
) -> str:
    """Deterministic 'Why this career?' narrative (P4).

    Built purely from the user's strengths and gaps so every claim in
    the text is traceable to the data — no AI call required.
    """
    top_strengths = [
        s["skill"]
        for s in sorted(
            strengths,
            key=lambda x: (x["user_level"], x["required_level"]),
            reverse=True,
        )[:3]
    ]
    top_gaps = [
        g["skill"]
        for g in sorted(
            gaps,
            key=lambda x: (x["required_level"], x["gap"]),
            reverse=True,
        )[:2]
    ]

    parts = []
    if top_strengths:
        parts.append(
            f"You already have strong {_human_join(top_strengths)} skills."
        )
    else:
        parts.append(
            "You have not yet built up the core skills for this role."
        )

    if top_gaps:
        verb = "is" if len(top_gaps) == 1 else "are"
        pronoun = "this skill" if len(top_gaps) == 1 else "these skills"
        parts.append(
            f"However, your {_human_join(top_gaps)} {verb} below the "
            f"required level. Improving {pronoun} would significantly "
            f"increase your readiness as a {career_name}."
        )
    elif top_strengths:
        parts.append(
            f"You meet every core requirement — with a {match_percentage}% "
            f"match you are {readiness.lower()} for a {career_name} role."
        )

    return " ".join(parts)


def compute_career_score(
    skill_rows: List[Tuple[int, str, Optional[str], int]],
    user_skills: Optional[Dict[int, int]],
    career_name: str = "this career",
    education: Optional[str] = None,
    domain_name: Optional[str] = None,
    resume_skill_ids: Optional[set] = None,
) -> dict:
    """Score one career against a user's skill levels.

    skill_rows: (skill_id, skill_name, category, required_level) tuples.
    Returns match_percentage, readiness, strengths, skill_gaps,
    learning_order, critical_gaps, score_breakdown and explanation.
    """
    user_skills = user_skills or {}
    strengths: List[dict] = []
    gaps: List[dict] = []

    weighted_num = 0.0
    weighted_den = 0.0
    skills_met = 0
    resume_hits = 0

    for skill_id, name, category, raw_required in skill_rows:
        try:
            required_level = int(raw_required or 0)
        except (ValueError, TypeError):
            required_level = 0
        required_level = max(0, min(100, required_level))

        try:
            user_level = int(user_skills.get(skill_id, 0))
        except (ValueError, TypeError):
            user_level = 0
        user_level = max(0, min(100, user_level))

        # Importance-weighted coverage: weight = required_level^2 so the
        # skills a career demands hardest dominate the coverage signal.
        if required_level > 0:
            importance = required_level * required_level
            weighted_num += min(user_level, required_level) * required_level
            weighted_den += importance

        gap = max(0, required_level - user_level)

        if resume_skill_ids and skill_id in resume_skill_ids and user_level > 0:
            resume_hits += 1

        if gap == 0:
            skills_met += 1
            strengths.append(
                {
                    "skill_id": skill_id,
                    "skill": name,
                    "category": category,
                    "user_level": user_level,
                    "required_level": required_level,
                    "gap": 0,
                }
            )
        else:
            gaps.append(
                {
                    "skill_id": skill_id,
                    "skill": name,
                    "category": category,
                    "user_level": user_level,
                    "required_level": required_level,
                    "gap": gap,
                    "priority": get_priority(gap),
                }
            )

    total_skills = len(skill_rows)

    # ---- Signals ----------------------------------------------------
    coverage = (weighted_num / weighted_den) if weighted_den else 0.0
    strengths_ratio = (skills_met / total_skills) if total_skills else 0.0
    education_score = education_compatibility(education, domain_name)
    resume_score = (
        (resume_hits / total_skills)
        if (resume_skill_ids and total_skills)
        else None
    )

    # ---- Weighted combination with renormalization -------------------
    parts = [
        (coverage, ENGINE_WEIGHTS["skill_coverage"]),
        (strengths_ratio, ENGINE_WEIGHTS["strengths"]),
    ]
    if education_score is not None:
        parts.append((education_score, ENGINE_WEIGHTS["education"]))
    if resume_score is not None:
        parts.append((resume_score, ENGINE_WEIGHTS["resume_evidence"]))

    total_weight = sum(weight for _, weight in parts)
    final = (
        sum(value * weight for value, weight in parts) / total_weight
        if total_weight
        else 0.0
    )
    match_percentage = round(final * 100)
    readiness = get_readiness(match_percentage)

    # ---- Ordered outputs ---------------------------------------------
    gaps.sort(
        key=lambda x: (x["gap"], x["required_level"]),
        reverse=True,
    )
    strengths.sort(
        key=lambda x: (x["user_level"], x["required_level"]),
        reverse=True,
    )

    # Recommended learning order: most-demanded skills first, so the
    # learning path front-loads what the career values most.
    learning_order = [
        {
            "step": index,
            "skill": gap["skill"],
            "category": gap["category"],
            "user_level": gap["user_level"],
            "required_level": gap["required_level"],
            "gap": gap["gap"],
            "priority": gap["priority"],
            "reason": (
                f"Required at {gap['required_level']}% — "
                f"close a {gap['gap']}-point gap"
            ),
        }
        for index, gap in enumerate(
            sorted(
                gaps,
                key=lambda x: (x["required_level"], x["gap"]),
                reverse=True,
            ),
            start=1,
        )
    ]

    critical_gaps = [
        gap
        for gap in gaps
        if gap["priority"] in ("Critical", "High")
    ]

    explanation = build_career_explanation(
        career_name or "this career",
        strengths,
        gaps,
        match_percentage,
        readiness,
    )

    return {
        "match_percentage": match_percentage,
        "readiness": readiness,
        "strengths": strengths,
        "skill_gaps": gaps,
        "learning_order": learning_order,
        "critical_gaps": critical_gaps,
        "total_skills": total_skills,
        "missing_skills": len(gaps),
        "score_breakdown": {
            "skill_coverage": round(coverage * 100, 1),
            "strengths": round(strengths_ratio * 100, 1),
            "education": (
                round(education_score * 100, 1)
                if education_score is not None
                else None
            ),
            "resume_evidence": (
                round(resume_score * 100, 1)
                if resume_score is not None
                else None
            ),
            "weights": dict(ENGINE_WEIGHTS),
            "formula": ENGINE_FORMULA,
        },
        "explanation": explanation,
    }


# =====================================================
# SKILL GAP ANALYSIS
# =====================================================

@app.post("/api/analyze")
def analyze_skill_gap(
    request: SkillGapRequest,
    db: Session = Depends(get_db)
):

    # =================================================
    # LOAD CAREERS
    # =================================================

    careers = (
        db.query(models.Career)
        .order_by(models.Career.id)
        .all()
    )


    # =================================================
    # LOAD ALL REQUIREMENTS
    # =================================================

    requirements = (
        db.query(
            models.CareerSkillRequirement,
            models.Skill,
        )
        .join(
            models.Skill,
            models.Skill.id
            == models.CareerSkillRequirement.skill_id,
        )
        .all()
    )


    # =================================================
    # GROUP REQUIREMENTS BY CAREER
    # =================================================

    career_requirements = {}

    for requirement, skill in requirements:

        if requirement.career_id not in career_requirements:

            career_requirements[
                requirement.career_id
            ] = []

        career_requirements[
            requirement.career_id
        ].append(
            (
                requirement,
                skill,
            )
        )


    # =================================================
    # ANALYZE CAREERS — weighted engine (P3)
    # =================================================

    # Domain names power the education-compatibility signal.
    domains_map = {
        domain.id: domain.name
        for domain in db.query(models.Domain).all()
    }

    user_resume_ids = (
        set(request.resume_skill_ids)
        if request.resume_skill_ids
        else None
    )

    results = []

    for career in careers:

        career_requirements_list = (
            career_requirements.get(
                career.id,
                []
            )
        )

        # Skip careers without skills
        if not career_requirements_list:
            continue

        skill_rows = [
            (
                skill.id,
                skill.name,
                skill.category,
                requirement.required_level,
            )
            for requirement, skill in (
                career_requirements_list
            )
        ]

        scored = compute_career_score(
            skill_rows,
            request.skills,
            career_name=career.name,
            education=request.education,
            domain_name=domains_map.get(
                career.domain_id
            ),
            resume_skill_ids=user_resume_ids,
        )

        results.append(
            {
                "career_id": career.id,
                "career": career.name,
                "description": career.description,
                **scored,
            }
        )


    # =================================================
    # SORT CAREERS BY MATCH
    # =================================================

    results.sort(
        key=lambda x: x[
            "match_percentage"
        ],
        reverse=True,
    )


    # =================================================
    # TOP CAREER
    # =================================================

    top_career = (
        results[0]
        if results
        else None
    )


    # =================================================
    # ALTERNATIVE CAREERS
    # =================================================

    alternative_careers = (
        results[1:6]
        if len(results) > 1
        else []
    )


    # =================================================
    # RESPONSE
    # =================================================

    return {
        "status": "success",

        "total_careers_analyzed": len(
            results
        ),

        "recommended_career": top_career,

        "alternative_careers": (
            alternative_careers
        ),

        "recommendations": results,
    }


# =====================================================
# AI-GENERATED LEARNING ROADMAP
# =====================================================
#
# Calls Google Gemini (free-tier friendly) to turn a user's
# skill gaps into a personalized, phased learning roadmap
# with resource suggestions. If no GEMINI_API_KEY is set, or
# the call fails for any reason, we fall back to a rule-based
# roadmap so the endpoint always returns something usable —
# the frontend doesn't need to know which path was taken.

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-2.0-flash")
GEMINI_URL = (
    f"https://generativelanguage.googleapis.com/v1beta/models/"
    f"{GEMINI_MODEL}:generateContent"
)

# Groq (OpenAI-compatible, faster + higher free quota)
GROQ_API_KEY = os.getenv("GROQ_API_KEY", "")
GROQ_MODEL = os.getenv("GROQ_MODEL", "llama-3.3-70b-versatile")
GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"
AI_PROVIDER = os.getenv("AI_PROVIDER", "auto").lower().strip()  # auto | groq | gemini | keyword

# Debug helper — logs which AI keys are loaded (without printing the key)
print(f"[AI] provider={AI_PROVIDER} | Gemini: {'yes' if GEMINI_API_KEY else 'no'} ({len(GEMINI_API_KEY) if GEMINI_API_KEY else 0} chars, {GEMINI_MODEL}) | Groq: {'yes' if GROQ_API_KEY else 'no'} ({len(GROQ_API_KEY) if GROQ_API_KEY else 0} chars, {GROQ_MODEL})")

# Simple in-memory cache + last-error tracking for quota UX
# (resets on server restart — fine for free-tier demo)
_last_gemini_resume_error: Optional[str] = None
_last_gemini_roadmap_error: Optional[str] = None
_resume_cache: Dict[str, tuple] = {}  # key -> (response_dict, timestamp)


class SkillGapItem(BaseModel):
    name: str = Field(min_length=1, max_length=150)
    current: int = Field(default=0, ge=0, le=100)
    required: int = Field(default=0, ge=0, le=100)
    gap: int = Field(default=0, ge=0, le=100)


class AiRoadmapRequest(BaseModel):
    career_name: str = Field(min_length=1, max_length=150)
    match_score: int = Field(default=0, ge=0, le=100)
    # Bound untrusted input before it is included in an AI-provider prompt.
    skill_gaps: List[SkillGapItem] = Field(default_factory=list, max_length=10)
    strong_skills: List[str] = Field(default_factory=list, max_length=20)
    education: Optional[str] = Field(default=None, max_length=200)


ROADMAP_JSON_SCHEMA = {
    "type": "object",
    "properties": {
        "summary": {"type": "string"},
        "steps": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "title": {"type": "string"},
                    "description": {"type": "string"},
                    "skills": {
                        "type": "array",
                        "items": {"type": "string"},
                    },
                    "resources": {
                        "type": "array",
                        "items": {
                            "type": "object",
                            "properties": {
                                "name": {"type": "string"},
                                "type": {"type": "string"},
                            },
                            "required": ["name", "type"],
                        },
                    },
                },
                "required": ["title", "description"],
            },
        },
    },
    "required": ["summary", "steps"],
}


def build_roadmap_prompt(payload: AiRoadmapRequest) -> str:
    gaps_text = "\n".join(
        f"- {g.name}: currently {g.current}%, needs {g.required}% "
        f"(gap of {g.gap} points)"
        for g in payload.skill_gaps
    ) or "- No major skill gaps."

    strengths_text = ", ".join(payload.strong_skills) or "None yet."

    return (
        "You are a career mentor helping a student close their "
        "skill gaps for a target job role.\n\n"
        f"Target career: {payload.career_name}\n"
        f"Education background: {payload.education or 'Not specified'}\n"
        f"Current overall readiness match score: {payload.match_score}%\n\n"
        f"Skills already strong: {strengths_text}\n\n"
        f"Skill gaps to close (ordered by priority):\n{gaps_text}\n\n"
        "Write a short encouraging summary (2-3 sentences), then a "
        "phased learning roadmap (3-5 phases) that tackles the "
        "highest-priority gaps first. For each phase give a title, "
        "a short description, which skills it covers, and 2-3 "
        "concrete learning resources (name + type, e.g. 'course', "
        "'book', 'project', 'documentation' — do not invent fake "
        "URLs). Keep it practical and specific to the skill gaps "
        "listed above."
    )


def call_gemini_roadmap(payload: AiRoadmapRequest) -> Optional[dict]:
    global _last_gemini_roadmap_error
    if not GEMINI_API_KEY:
        _last_gemini_roadmap_error = "no_key"
        return None

    try:
        response = requests.post(
            GEMINI_URL,
            params={"key": GEMINI_API_KEY},
            json={
                "contents": [
                    {
                        "parts": [
                            {"text": build_roadmap_prompt(payload)}
                        ]
                    }
                ],
                "generationConfig": {
                    "response_mime_type": "application/json",
                    "response_schema": ROADMAP_JSON_SCHEMA,
                },
            },
            timeout=20,
        )

        response.raise_for_status()
        data = response.json()

        text_out = data["candidates"][0]["content"]["parts"][0]["text"]
        parsed = json.loads(text_out)

        if "summary" in parsed and "steps" in parsed:
            parsed["source"] = "ai"
            _last_gemini_roadmap_error = None
            return parsed

        return None

    except Exception as e:
        msg = str(e)
        _last_gemini_roadmap_error = msg
        print("GEMINI ROADMAP ERROR:", e)
        return None


_last_groq_roadmap_error: Optional[str] = None

def _call_groq_roadmap(payload: AiRoadmapRequest) -> Optional[dict]:
    global _last_groq_roadmap_error
    if not GROQ_API_KEY:
        _last_groq_roadmap_error = "no_key"
        return None
    try:
        prompt = build_roadmap_prompt(payload)
        resp = requests.post(
            GROQ_URL,
            headers={"Authorization": f"Bearer {GROQ_API_KEY}", "Content-Type": "application/json"},
            json={
                "model": GROQ_MODEL,
                "messages": [
                    {"role": "system", "content": "You are a career mentor. Return ONLY valid JSON matching: {\"summary\": \"...\", \"steps\": [{\"title\": \"...\", \"description\": \"...\", \"skills\": [...], \"resources\": [{\"name\": \"...\", \"type\": \"...\"}]}]}"},
                    {"role": "user", "content": prompt},
                ],
                "temperature": 0.3,
                "max_tokens": 900,
                "response_format": {"type": "json_object"},
            },
            timeout=20,
        )
        resp.raise_for_status()
        data = resp.json()
        content = data["choices"][0]["message"]["content"]
        parsed = json.loads(content)
        if "summary" in parsed and "steps" in parsed:
            parsed["source"] = "groq"
            _last_groq_roadmap_error = None
            return parsed
        return None
    except Exception as e:
        _last_groq_roadmap_error = str(e)
        print("GROQ ROADMAP ERROR:", e)
        return None


def _call_ai_roadmap(payload: AiRoadmapRequest) -> Optional[dict]:
    order = []
    if AI_PROVIDER == "groq":
        order = ["groq", "gemini"]
    elif AI_PROVIDER == "gemini":
        order = ["gemini", "groq"]
    elif AI_PROVIDER == "keyword":
        return None
    else:  # auto
        order = ["groq", "gemini"]
    for p in order:
        if p == "groq" and GROQ_API_KEY:
            r = _call_groq_roadmap(payload)
            if r:
                return r
        if p == "gemini" and GEMINI_API_KEY:
            r = call_gemini_roadmap(payload)
            if r:
                return r
    return None


def fallback_roadmap(payload: AiRoadmapRequest) -> dict:
    # Rule-based backup — same shape as the AI response, so the
    # frontend renders identically either way.

    if payload.match_score >= 80:
        summary = (
            f"You're well prepared for {payload.career_name}. "
            "Focus now on advanced, real-world practice."
        )
    elif payload.match_score >= 60:
        summary = (
            f"You have a solid foundation for {payload.career_name}. "
            "Closing your remaining gaps will make you job-ready."
        )
    elif payload.match_score >= 40:
        summary = (
            f"You're building the right foundation for "
            f"{payload.career_name}. Prioritize the largest gaps first."
        )
    else:
        summary = (
            f"You're at the start of your path toward "
            f"{payload.career_name}. Focus on fundamentals before "
            "moving to advanced topics."
        )

    steps = []
    top_gaps = payload.skill_gaps[:5]

    for i, gap in enumerate(top_gaps, start=1):
        steps.append(
            {
                "title": f"Phase {i}: {gap.name}",
                "description": (
                    f"Close a {gap.gap}-point gap in {gap.name} "
                    f"(currently {gap.current}%, target {gap.required}%)."
                ),
                "skills": [gap.name],
                "resources": [
                    {"name": f"{gap.name} official documentation", "type": "documentation"},
                    {"name": f"A beginner-to-intermediate {gap.name} course", "type": "course"},
                    {"name": f"A small hands-on project using {gap.name}", "type": "project"},
                ],
            }
        )

    if not steps:
        steps.append(
            {
                "title": "Maintain and specialize",
                "description": (
                    "You've covered the required skills — deepen "
                    "expertise with advanced projects and internships."
                ),
                "skills": payload.strong_skills[:5],
                "resources": [
                    {"name": "An advanced/specialization course in your field", "type": "course"},
                    {"name": "A portfolio project solving a real problem", "type": "project"},
                ],
            }
        )

    return {"summary": summary, "steps": steps, "source": "fallback"}


@app.post("/api/ai/roadmap")
def get_ai_roadmap(payload: AiRoadmapRequest, request: Request):
    _enforce_rate_limit(request, "ai-roadmap", AI_ROADMAP_LIMIT)
    roadmap = _call_ai_roadmap(payload)

    if roadmap is None:
        # _call_ai_roadmap already tried groq->gemini; if still None, fallback
        # Keep old direct call as ultimate fallback for error tracking
        if not roadmap:
            roadmap = call_gemini_roadmap(payload)
        if roadmap is None:
            roadmap = fallback_roadmap(payload)

    return roadmap


# =====================================================
# RESUME UPLOAD & ANALYSIS — Passkey-protected Gemini
# =====================================================
#
# Flow:
# 1) User uploads PDF/DOCX/TXT via frontend dropzone (multipart)
# 2) Backend extracts raw_text (pypdf / python-docx / plain)
# 3) If GEMINI_API_KEY (your passkey) is set, we call Gemini to
#    extract structured skills + inferred levels 0-100.
#    Otherwise we fall back to keyword matching against skills_v2.
# 4) Result is mapped to { skill_id, name, inferred_level } so the
#    frontend can auto-fill the SkillsRater sliders.
# 5) Optionally persisted to `resume_analyses` for Workbench.
#    Workbench users can then `SELECT * FROM resume_analyses`.

MAX_RESUME_BYTES = 5 * 1024 * 1024  # 5 MB
ALLOWED_RESUME_EXTS = {".pdf", ".docx", ".txt"}
MAX_DOCX_UNCOMPRESSED_BYTES = 20 * 1024 * 1024
MAX_DOCX_ARCHIVE_ENTRIES = 2_000
RESUME_SESSION_HEADER = "X-Resume-Session"
STORE_RESUME_TEXT = os.getenv("STORE_RESUME_TEXT", "false").lower() == "true"


def _require_resume_session(session_token: Optional[str]) -> str:
    """Validate the opaque per-browser token used for resume history isolation."""
    token = (session_token or "").strip()
    if not re.fullmatch(r"[a-f0-9-]{32,64}", token, re.IGNORECASE):
        raise HTTPException(
            status_code=400,
            detail=f"A valid {RESUME_SESSION_HEADER} header is required.",
        )
    return token


def _validate_resume_content(data: bytes, filename: str) -> None:
    """Validate the file signature and DOCX archive bounds before parsing it."""
    name = (filename or "").lower()
    if name.endswith(".pdf"):
        if not data.startswith(b"%PDF-"):
            raise HTTPException(status_code=422, detail="The uploaded file is not a valid PDF.")
        return

    if name.endswith(".docx"):
        import zipfile

        try:
            with zipfile.ZipFile(io.BytesIO(data)) as archive:
                entries = archive.infolist()
                if len(entries) > MAX_DOCX_ARCHIVE_ENTRIES:
                    raise HTTPException(status_code=422, detail="DOCX contains too many archive entries.")
                if sum(entry.file_size for entry in entries) > MAX_DOCX_UNCOMPRESSED_BYTES:
                    raise HTTPException(status_code=422, detail="DOCX expands beyond the allowed size.")
                if "word/document.xml" not in archive.namelist():
                    raise HTTPException(status_code=422, detail="The uploaded file is not a valid DOCX document.")
        except HTTPException:
            raise
        except (zipfile.BadZipFile, zipfile.LargeZipFile):
            raise HTTPException(status_code=422, detail="The uploaded file is not a valid DOCX document.")


def _extract_text_from_bytes(data: bytes, filename: str) -> str:
    name = (filename or "").lower()
    # --- PDF ---
    if name.endswith(".pdf"):
        try:
            from pypdf import PdfReader

            reader = PdfReader(io.BytesIO(data))
            parts = []
            for page in reader.pages:
                try:
                    parts.append(page.extract_text() or "")
                except Exception:
                    continue
            text_out = "\n".join(parts).strip()
            if text_out:
                return text_out
        except Exception as e:
            print("PDF EXTRACT ERROR:", e)
        # fallback: try to decode as text (scanned PDFs will be empty)
        try:
            return data.decode("utf-8", errors="ignore")
        except Exception:
            return ""

    # --- DOCX (parsed without lxml: zip + stdlib xml) ---
    if name.endswith(".docx"):
        # Try python-docx first if available (needs lxml), else fallback to zip+xml
        try:
            import docx  # type: ignore

            doc = docx.Document(io.BytesIO(data))
            txt = "\n".join(p.text for p in doc.paragraphs).strip()
            if txt:
                return txt
        except Exception as e:
            print("DOCX (python-docx) Extract note:", e)
        # Fallback: unzip .docx and parse word/document.xml with stdlib
        try:
            import zipfile
            import xml.etree.ElementTree as ET

            with zipfile.ZipFile(io.BytesIO(data)) as z:
                xml_bytes = z.read("word/document.xml")
            # Word uses w:t for text nodes
            root = ET.fromstring(xml_bytes)
            ns = {"w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main"}
            texts = [node.text for node in root.findall(".//w:t", ns) if node.text]
            txt = "\n".join(texts).strip()
            if txt:
                return txt
        except Exception as e:
            print("DOCX (zip) Extract note:", e)
    # --- TXT / fallback ---
    try:
        return data.decode("utf-8", errors="ignore").strip()
    except Exception:
        return data.decode("latin-1", errors="ignore").strip()


RESUME_SKILLS_JSON_SCHEMA = {
    "type": "object",
    "properties": {
        "skills": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "name": {"type": "string"},
                    "inferred_level": {"type": "integer"},
                    "evidence": {"type": "string"},
                },
                "required": ["name", "inferred_level"],
            },
        },
        "summary": {"type": "string"},
    },
    "required": ["skills"],
}


def _call_gemini_resume_extract(
    resume_text: str,
    known_skills: List[models.Skill],
) -> Optional[dict]:
    """Ask Gemini to map resume text -> skills with inferred 0-100 levels."""
    global _last_gemini_resume_error
    if not GEMINI_API_KEY:
        _last_gemini_resume_error = "no_key"
        return None
    if not resume_text or len(resume_text.strip()) < 20:
        _last_gemini_resume_error = "text_too_short"
        return None

    # Build known-skills hint (limit to 80 to keep prompt small)
    skill_names = [s.name for s in known_skills[:80]]
    skills_hint = ", ".join(skill_names) if skill_names else "Python, JavaScript, SQL, React, etc."

    # Truncate resume for token limits
    truncated = resume_text[:8000]

    prompt = (
        "You are a resume parser for a skill-gap analyzer. Extract the candidate's "
        "technical and soft skills from the resume text below. For each skill, estimate "
        "a proficiency level 0-100 based on evidence (projects, years, keywords like "
        "'expert', '3 years', etc.). Only return skills that are explicitly or strongly "
        "implied in the resume.\n\n"
        f"Known skills in our system (prefer these names when possible): {skills_hint}\n\n"
        f"Resume text:\n'''{truncated}'''\n\n"
        "Return JSON with: { skills: [{ name, inferred_level (0-100), evidence (short phrase from resume) }], summary (1 sentence about the candidate) }"
    )

    try:
        resp = requests.post(
            GEMINI_URL,
            params={"key": GEMINI_API_KEY},
            json={
                "contents": [{"parts": [{"text": prompt}]}],
                "generationConfig": {
                    "response_mime_type": "application/json",
                    "response_schema": RESUME_SKILLS_JSON_SCHEMA,
                },
            },
            timeout=25,
        )
        resp.raise_for_status()
        data = resp.json()
        text_out = data["candidates"][0]["content"]["parts"][0]["text"]
        parsed = json.loads(text_out)
        if "skills" in parsed and isinstance(parsed["skills"], list):
            parsed["source"] = "gemini"
            _last_gemini_resume_error = None
            return parsed
        return None
    except Exception as e:
        _last_gemini_resume_error = str(e)
        print("GEMINI RESUME ERROR:", e)
        return None


# --- Groq resume extract (OpenAI-compatible, no lxml, faster quota) ---
_last_groq_resume_error: Optional[str] = None

def _call_groq_resume_extract(
    resume_text: str,
    known_skills: List[models.Skill],
) -> Optional[dict]:
    global _last_groq_resume_error
    if not GROQ_API_KEY:
        _last_groq_resume_error = "no_key"
        return None
    if not resume_text or len(resume_text.strip()) < 20:
        _last_groq_resume_error = "text_too_short"
        return None

    skill_names = [s.name for s in known_skills[:80]]
    skills_hint = ", ".join(skill_names) if skill_names else "Python, JavaScript, SQL, React, etc."
    truncated = resume_text[:8000]

    prompt = (
        "You are a resume parser for a skill-gap analyzer. Extract candidate skills from the resume below. "
        "For each skill estimate proficiency 0-100 based on evidence. Only include skills explicitly or strongly implied. "
        f"Prefer these known skill names when possible: {skills_hint}\n\n"
        f"Resume text:\n'''{truncated}'''\n\n"
        "Return ONLY valid JSON: {\"skills\": [{\"name\": \"Python\", \"inferred_level\": 80, \"evidence\": \"3 years Python\"}], \"summary\": \"One sentence summary\"}"
    )

    try:
        resp = requests.post(
            GROQ_URL,
            headers={
                "Authorization": f"Bearer {GROQ_API_KEY}",
                "Content-Type": "application/json",
            },
            json={
                "model": GROQ_MODEL,
                "messages": [
                    {"role": "system", "content": "You are a JSON-only resume parser. Return valid JSON only."},
                    {"role": "user", "content": prompt},
                ],
                "temperature": 0.2,
                "max_tokens": 800,
                "response_format": {"type": "json_object"},
            },
            timeout=25,
        )
        resp.raise_for_status()
        data = resp.json()
        content = data["choices"][0]["message"]["content"]
        parsed = json.loads(content)
        if "skills" in parsed and isinstance(parsed["skills"], list):
            parsed["source"] = "groq"
            _last_groq_resume_error = None
            return parsed
        return None
    except Exception as e:
        _last_groq_resume_error = str(e)
        print("GROQ RESUME ERROR:", e)
        return None


def _call_ai_resume_extract(
    resume_text: str,
    known_skills: List[models.Skill],
) -> Tuple[Optional[dict], Optional[str]]:
    """Try providers in order based on AI_PROVIDER; returns (result, source_or_error)."""
    # auto: groq -> gemini -> keyword
    order = []
    if AI_PROVIDER == "groq":
        order = ["groq", "gemini"]
    elif AI_PROVIDER == "gemini":
        order = ["gemini", "groq"]
    elif AI_PROVIDER == "keyword":
        return (None, "keyword_forced")
    else:  # auto
        order = ["groq", "gemini"]

    for provider in order:
        if provider == "groq" and GROQ_API_KEY:
            r = _call_groq_resume_extract(resume_text, known_skills)
            if r and r.get("skills"):
                return (r, "groq")
            # if groq failed with quota, continue to next provider
            if _last_groq_resume_error and "429" in _last_groq_resume_error:
                continue
            # if groq returned None but not quota, still try gemini
        if provider == "gemini" and GEMINI_API_KEY:
            r = _call_gemini_resume_extract(resume_text, known_skills)
            if r and r.get("skills"):
                return (r, "gemini")

    return (None, _last_groq_resume_error or _last_gemini_resume_error or "no_ai")


def _keyword_extract(
    resume_text: str,
    known_skills: List[models.Skill],
) -> dict:
    """Fallback: simple case-insensitive substring match against skills_v2."""
    lower = resume_text.lower()
    out = []
    for skill in known_skills:
        name = skill.name or ""
        if not name:
            continue
        # allow multi-word match: must find whole phrase case-insensitive
        # For short names like "R", require word boundaries to avoid false positives
        n = name.lower().strip()
        if len(n) <= 1:
            continue
        # Special aliases: handle "Node.js" -> "node"
        found = False
        if n in lower:
            # For very short tokens, enforce word boundary
            if len(n) <= 2:
                found = bool(re.search(rf"\b{re.escape(n)}\b", lower))
            else:
                found = True
        # Also check aliases
        if not found:
            aliases = {
                "js": "javascript",
                "ts": "typescript",
                "nodejs": "node.js",
                "node": "node.js",
                "powerbi": "power bi",
                "ml": "machine learning",
            }
            # if alias matches, map to canonical
            if n in aliases.values():
                alias_keys = [k for k, v in aliases.items() if v == n]
                for ak in alias_keys:
                    if ak in lower:
                        found = True
                        break
        if found:
            # Infer level by frequency + context clues
            count = lower.count(n)
            # Base 60, +5 per extra mention up to 75, check for "expert/advanced/lead"
            level = 60 + min((count - 1) * 5, 15)
            if re.search(rf"{re.escape(n)}.*(expert|advanced|lead|senior|proficient)", lower[:2000]):
                level = min(85, level + 10)
            if re.search(rf"(expert|advanced).* {re.escape(n)}", lower[:2000]):
                level = min(85, level + 10)
            out.append({
                "name": skill.name,
                "inferred_level": min(95, level),
                "evidence": f"Found '{skill.name}' in resume",
                "skill_id": skill.id,
                "category": skill.category,
            })
        # Also handle alias hits where resume has alias but skill is canonical
    # If nothing found, return empty but keep source marker
    return {"skills": out, "source": "keyword"}


@app.post("/api/resume/analyze")
async def analyze_resume(
    request: Request,
    file: UploadFile = File(...),
    target_career_id: Optional[int] = Form(None),
    education: Optional[str] = Form(None),
    resume_session: Optional[str] = Header(None, alias=RESUME_SESSION_HEADER),
    db: Session = Depends(get_db),
):
    # --- Validate ---
    _enforce_rate_limit(request, "resume-analyze", RESUME_ANALYZE_LIMIT)
    owner_token = _require_resume_session(resume_session)
    if not file or not file.filename:
        raise HTTPException(status_code=400, detail="No file uploaded")

    ext = os.path.splitext(file.filename)[1].lower()
    if ext not in ALLOWED_RESUME_EXTS:
        raise HTTPException(
            status_code=400,
            detail=f"Unsupported file type {ext}. Use PDF, DOCX or TXT.",
        )

    data = await file.read()
    if not data:
        raise HTTPException(status_code=400, detail="Empty file")
    if len(data) > MAX_RESUME_BYTES:
        raise HTTPException(status_code=400, detail="File too large (max 5 MB)")

    _validate_resume_content(data, file.filename)

    # --- Extract text ---
    raw_text = _extract_text_from_bytes(data, file.filename).strip()
    if not raw_text or len(raw_text) < 20:
        raise HTTPException(
            status_code=422,
            detail="Could not extract text from resume. If it's a scanned PDF, try exporting to searchable PDF or DOCX.",
        )

    # --- Cache check (5 min) — avoid re-calling Gemini for same file ---
    cache_key = f"{owner_token}_{hash(raw_text[:2000])}_{target_career_id}_{file.filename}"
    now_ts = datetime.utcnow().timestamp()
    if cache_key in _resume_cache:
        cached_resp, ts = _resume_cache[cache_key]
        if now_ts - ts < 300:
            # Return cached response (update file_size in case)
            return cached_resp

    # --- Load known skills from Workbench DB ---
    try:
        known_skills: List[models.Skill] = db.query(models.Skill).order_by(models.Skill.name).all()
    except Exception as e:
        print("DB SKILLS LOAD ERROR:", e)
        known_skills = []

    # --- Try AI (Groq -> Gemini), fallback to keyword ---
    ai_result, ai_source = _call_ai_resume_extract(raw_text, known_skills)
    if ai_result and ai_result.get("skills"):
        raw_skills = ai_result["skills"]
        source = ai_result.get("source", ai_source or "groq")
        summary = ai_result.get("summary", "")
    else:
        kw = _keyword_extract(raw_text, known_skills)
        raw_skills = kw["skills"]
        source = kw["source"]
        summary = f"Keyword-matched {len(raw_skills)} skills from resume."

    # --- Map to canonical skill_ids and clamp levels ---
    # Build name -> skill lookup (case-insensitive)
    name_to_skill = {s.name.lower(): s for s in known_skills}
    # also alias map
    alias_to_canonical = {
        "js": "javascript", "ts": "typescript", "nodejs": "node.js",
        "node": "node.js", "tailwind css": "tailwind", "ml": "machine learning",
        "dl": "deep learning", "powerbi": "power bi", "scikit-learn": "machine learning",
    }

    mapped = []
    seen = set()
    for item in raw_skills:
        raw_name = (item.get("name") or "").strip()
        if not raw_name:
            continue
        key = raw_name.lower().strip()
        # resolve alias
        if key in alias_to_canonical:
            key = alias_to_canonical[key]
        skill = name_to_skill.get(key)
        # fuzzy: try to find by lower contains if exact not found
        if not skill:
            # try direct lower match among known
            for k, v in name_to_skill.items():
                if k == key or key in k or k in key:
                    skill = v
                    break
        if not skill:
            # unknown skill not in DB — still return but without skill_id
            level = int(item.get("inferred_level") or 60)
            level = max(0, min(100, level))
            mapped.append({
                "skill_id": None,
                "name": raw_name,
                "category": None,
                "inferred_level": level,
                "evidence": item.get("evidence", ""),
            })
            continue
        if skill.id in seen:
            continue
        seen.add(skill.id)
        level = int(item.get("inferred_level") or 60)
        level = max(0, min(100, level))
        mapped.append({
            "skill_id": skill.id,
            "name": skill.name,
            "category": skill.category,
            "inferred_level": level,
            "evidence": item.get("evidence", "")[:120],
        })

    # If Gemini returned none but keyword also none, still provide empty list
    # Sort by inferred_level desc so strongest first
    mapped.sort(key=lambda x: x["inferred_level"], reverse=True)

    # --- Also compute career gap if target_career_id provided ---
    gap_preview = None
    if target_career_id:
        try:
            career = db.query(models.Career).filter(models.Career.id == int(target_career_id)).first()
            if career:
                reqs = (
                    db.query(models.Skill, models.CareerSkillRequirement.required_level)
                    .join(models.CareerSkillRequirement, models.Skill.id == models.CareerSkillRequirement.skill_id)
                    .filter(models.CareerSkillRequirement.career_id == career.id)
                    .all()
                )
                # build dict skill_id -> inferred
                inferred_map = {m["skill_id"]: m["inferred_level"] for m in mapped if m["skill_id"] is not None}
                total_req = 0
                total_have = 0
                gaps = []
                for skill, req in reqs:
                    have = inferred_map.get(skill.id, 0)
                    total_req += max(0, min(100, int(req)))
                    total_have += min(have, int(req))
                    gaps.append({
                        "skill_id": skill.id,
                        "name": skill.name,
                        "required_level": int(req),
                        "inferred_level": have,
                        "gap": max(0, int(req) - have),
                    })
                match = round((total_have / total_req * 100) if total_req else 0, 2)
                gaps.sort(key=lambda x: x["gap"], reverse=True)
                gap_preview = {
                    "career_id": career.id,
                    "career_name": career.name,
                    "match_percentage": match,
                    "gaps": gaps[:5],
                }
        except Exception as e:
            print("GAP PREVIEW ERROR:", e)

    # --- Career recommendations from resume (P1: completes the pipeline ---
    #     upload -> extract text -> extract skills -> match to DB ->
    #     estimate levels -> CAREER RECOMMENDATION) -----------------------
    #     Uses the same weighted engine as /api/analyze, fed with the
    #     resume-inferred skill levels, so both flows agree.
    career_recommendations = []
    try:
        all_careers = db.query(models.Career).all()
        domains_map = {
            domain.id: domain.name
            for domain in db.query(models.Domain).all()
        }
        req_rows = (
            db.query(
                models.CareerSkillRequirement,
                models.Skill,
            )
            .join(
                models.Skill,
                models.Skill.id
                == models.CareerSkillRequirement.skill_id,
            )
            .all()
        )
        reqs_by_career = defaultdict(list)
        for requirement, skill in req_rows:
            reqs_by_career[requirement.career_id].append(
                (
                    skill.id,
                    skill.name,
                    skill.category,
                    requirement.required_level,
                )
            )

        inferred_levels = {
            m["skill_id"]: m["inferred_level"]
            for m in mapped
            if m["skill_id"] is not None
        }
        resume_ids = set(inferred_levels.keys()) or None

        scored_careers = []
        for career in all_careers:
            rows = reqs_by_career.get(career.id)
            if not rows:
                continue
            scored = compute_career_score(
                rows,
                inferred_levels,
                career_name=career.name,
                education=education,
                domain_name=domains_map.get(career.domain_id),
                resume_skill_ids=resume_ids,
            )
            scored_careers.append(
                {
                    "career_id": career.id,
                    "career": career.name,
                    "domain": domains_map.get(career.domain_id),
                    "match_percentage": scored["match_percentage"],
                    "readiness": scored["readiness"],
                    "explanation": scored["explanation"],
                    "top_gaps": scored["skill_gaps"][:3],
                    "total_skills": scored["total_skills"],
                    "missing_skills": scored["missing_skills"],
                }
            )

        scored_careers.sort(
            key=lambda x: x["match_percentage"],
            reverse=True,
        )
        career_recommendations = scored_careers[:5]
    except Exception as e:
        print("RESUME CAREER RECOMMENDATION ERROR:", e)

    # --- Persist for Workbench (best-effort, don't fail upload if DB down) ---
    saved_id = None
    try:
        row = models.ResumeAnalysis(
            file_name=file.filename,
            file_size=len(data),
            owner_token=owner_token,
            # Resume text is sensitive. Persist it only when explicitly enabled.
            raw_text=raw_text[:10000] if STORE_RESUME_TEXT else None,
            extracted_skills={"skills": mapped, "summary": summary, "source": source},
            target_career_id=int(target_career_id) if target_career_id else None,
            extraction_source=source,
        )
        db.add(row)
        db.commit()
        db.refresh(row)
        saved_id = row.id
    except Exception as e:
        print("RESUME SAVE ERROR (Workbench table maybe missing — run workbench/init.sql):", e)
        try:
            db.rollback()
        except Exception:
            pass

    # --- Quota/attempt info for frontend banner ---
    gemini_attempted = bool(GEMINI_API_KEY or GROQ_API_KEY)
    fallback_reason = None
    # Prefer the most recent error from whichever provider was tried
    gemini_error = _last_groq_resume_error or _last_gemini_resume_error
    if AI_PROVIDER == "gemini":
        gemini_error = _last_gemini_resume_error
    elif AI_PROVIDER == "groq":
        gemini_error = _last_groq_resume_error
    if gemini_attempted and source == "keyword" and gemini_error:
        low = gemini_error.lower()
        if "429" in gemini_error or "too many requests" in low or "quota" in low or "resource_exhausted" in low:
            fallback_reason = "quota"
        elif "api_key" in low or "api key" in low or "permission" in low or "invalid" in low:
            fallback_reason = "invalid_key"
        else:
            fallback_reason = "error"

    response = {
        "status": "success",
        "file_name": file.filename,
        "file_size": len(data),
        "text_length": len(raw_text),
        "text_preview": raw_text[:800],
        "extraction_source": source,
        "gemini_used": source in ("gemini", "groq"),
        "ai_used": source in ("gemini", "groq"),
        "gemini_attempted": gemini_attempted,
        "fallback_reason": fallback_reason,
        "gemini_error": gemini_error if fallback_reason else None,
        "summary": summary,
        "extracted_skills": mapped,
        # Frontend can directly do: setSkillLevels({...mapped levels})
        "inferred_levels": {str(m["skill_id"]): m["inferred_level"] for m in mapped if m["skill_id"] is not None},
        "gap_preview": gap_preview,
        # P1: top-5 careers ranked by the weighted engine using
        # resume-inferred skill levels (edu + resume evidence signals on)
        "career_recommendations": career_recommendations,
        "saved_id": saved_id,
        "workbench_hint": "SELECT * FROM resume_analyses ORDER BY created_at DESC LIMIT 5;" if saved_id else "Run backend/workbench/init.sql in MySQL Workbench to enable saving.",
    }

    # Cache for 5 min to prevent quota burn on re-uploads
    try:
        _resume_cache[cache_key] = (response, datetime.utcnow().timestamp())
        # keep cache small
        if len(_resume_cache) > 50:
            # drop oldest
            oldest = min(_resume_cache, key=lambda k: _resume_cache[k][1])
            _resume_cache.pop(oldest, None)
    except Exception:
        pass

    return response


@app.get("/api/resume/history")
def resume_history(
    limit: int = 10,
    resume_session: Optional[str] = Header(None, alias=RESUME_SESSION_HEADER),
    db: Session = Depends(get_db),
):
    """Return only uploads belonging to the current opaque browser session."""
    owner_token = _require_resume_session(resume_session)
    limit = max(1, min(50, int(limit or 10)))
    try:
        rows = (
            db.query(models.ResumeAnalysis)
            .filter(models.ResumeAnalysis.owner_token == owner_token)
            .order_by(models.ResumeAnalysis.created_at.desc())
            .limit(limit)
            .all()
        )
        return [
            {
                "id": r.id,
                "file_name": r.file_name,
                "file_size": r.file_size,
                "target_career_id": r.target_career_id,
                "extraction_source": r.extraction_source,
                "created_at": r.created_at.isoformat() if r.created_at else None,
                "extracted_skills": r.extracted_skills,
            }
            for r in rows
        ]
    except Exception:
        logger.exception("Could not load resume history")
        raise HTTPException(status_code=503, detail="Resume history is unavailable.")


@app.delete("/api/resume/history/{analysis_id}")
def delete_resume_history_item(
    analysis_id: int,
    resume_session: Optional[str] = Header(None, alias=RESUME_SESSION_HEADER),
    db: Session = Depends(get_db),
):
    """Delete one upload owned by the current browser session, never global history."""
    owner_token = _require_resume_session(resume_session)
    try:
        row = (
            db.query(models.ResumeAnalysis)
            .filter(
                models.ResumeAnalysis.id == analysis_id,
                models.ResumeAnalysis.owner_token == owner_token,
            )
            .first()
        )
        if row is None:
            raise HTTPException(status_code=404, detail="Resume analysis not found.")
        db.delete(row)
        db.commit()
        return {"status": "success", "deleted": 1}
    except HTTPException:
        raise
    except Exception:
        db.rollback()
        logger.exception("Could not delete resume history item")
        raise HTTPException(status_code=503, detail="Resume history is unavailable.")
