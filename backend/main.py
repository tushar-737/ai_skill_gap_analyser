import os

from typing import Dict

from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware

from pydantic import BaseModel

from sqlalchemy.orm import Session
from sqlalchemy import text

from .database import get_db
from . import models


# =====================================================
# FASTAPI APPLICATION
# =====================================================

app = FastAPI(
    title="AI Skill Gap Analyzer API",
    description="AI-powered skill gap analysis and career recommendation system",
    version="1.0.0"
)


# =====================================================
# CORS
# =====================================================

ALLOWED_ORIGINS = [
    origin.strip()
    for origin in os.getenv("ALLOWED_ORIGINS", "").split(",")
    if origin.strip()
] or [
    "http://localhost:5173",
    "http://127.0.0.1:5173",
    "http://localhost:5175",
    "http://127.0.0.1:5175",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# =====================================================
# HOME
# =====================================================

@app.get("/")
def home():
    return {
        "message": "AI Skill Gap Analyzer API is running",
        "status": "success"
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
            "message": "MySQL database connected successfully"
        }

    except Exception as e:

        return {
            "status": "error",
            "message": str(e)
        }


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
            "description": category.description
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
            "description": program.description
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
            "description": domain.description
        }

        for domain in domains
    ]


# =====================================================
# CAREERS
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
            "average_level": career.average_level
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
            "average_level": career.average_level
        }

        for career in careers
    ]


# =====================================================
# SKILLS
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
            "description": skill.description
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
            "description": skill.description
        }

        for skill in skills
    ]


# =====================================================
# CAREER SKILLS
# =====================================================

@app.get("/api/careers/{career_id}/skills")
def get_career_skills(
    career_id: int,
    db: Session = Depends(get_db)
):

    results = (
        db.query(
            models.Skill,
            models.CareerSkillRequirement.required_level
        )
        .join(
            models.CareerSkillRequirement,
            models.Skill.id
            == models.CareerSkillRequirement.skill_id
        )
        .filter(
            models.CareerSkillRequirement.career_id
            == career_id
        )
        .all()
    )

    return [
        {
            "skill_id": skill.id,
            "skill": skill.name,
            "category": skill.category,
            "required_level": required_level
        }

        for skill, required_level in results
    ]


# =====================================================
# CAREERS WITH SKILLS BY DOMAIN
# =====================================================

@app.get("/api/careers/domain/{domain_id}/with-skills")
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

    skill_ids = [
        req.skill_id
        for req in requirements
    ]

    if not skill_ids:

        return [
            {
                "id": career.id,
                "name": career.name,
                "description": career.description,
                "average_level": career.average_level,
                "skills": []
            }

            for career in careers
        ]

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

    for req in requirements:

        skill = skill_map.get(
            req.skill_id
        )

        if not skill:
            continue

        career_skills[
            req.career_id
        ].append(
            {
                "skill_id": skill.id,
                "skill": skill.name,
                "category": skill.category,
                "required_level": req.required_level,
            }
        )

    return [
        {
            "id": career.id,
            "name": career.name,
            "description": career.description,
            "average_level": career.average_level,
            "skills": career_skills.get(
                career.id,
                []
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

    return {
        "education_programs": education_count,
        "domains": domain_count,
        "careers": career_count,
        "skills": skill_count
    }


# =====================================================
# DEBUG DATABASE
# =====================================================

@app.get("/api/debug-db")
def debug_db(
    db: Session = Depends(get_db)
):

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
            "SELECT COUNT(*) AS total FROM careers_v2"
        )
    ).scalar()

    careers = db.execute(
        text(
            """
            SELECT id, name
            FROM careers
            ORDER BY id
            """
        )
    ).mappings().all()

    return {
        "connection": dict(result),
        "career_count": career_count,
        "careers": [
            dict(career)
            for career in careers
        ]
    }


# =====================================================
# SKILL GAP ANALYSIS REQUEST MODEL
# =====================================================

class SkillGapRequest(BaseModel):
    skills: Dict[int, int]


# =====================================================
# SKILL GAP ANALYSIS
# =====================================================

@app.post("/api/analyze")
def analyze_skill_gap(
    request: SkillGapRequest,
    db: Session = Depends(get_db)
):

    """
    Analyze the user's skills against
    all career skill requirements.

    Request example:

    {
        "skills": {
            "1": 80,
            "2": 70,
            "3": 60,
            "7": 75,
            "19": 65
        }
    }

    Key   = skill_id
    Value = user's skill level (0-100)
    """

    careers = (
        db.query(models.Career)
        .order_by(models.Career.id)
        .all()
    )

    results = []

    # -------------------------------------------------
    # Analyze every career
    # -------------------------------------------------

    for career in careers:

        requirements = (
            db.query(
                models.CareerSkillRequirement,
                models.Skill
            )
            .join(
                models.Skill,
                models.Skill.id
                == models.CareerSkillRequirement.skill_id
            )
            .filter(
                models.CareerSkillRequirement.career_id
                == career.id
            )
            .all()
        )

        # Skip careers that have no skill requirements
        if not requirements:
            continue

        total_required = 0
        total_user = 0

        gaps = []

        # -------------------------------------------------
        # Compare each required skill
        # -------------------------------------------------

        for requirement, skill in requirements:

            required_level = requirement.required_level

            # User skill level
            user_level = request.skills.get(
                skill.id,
                0
            )

            # Keep level between 0 and 100
            user_level = max(
                0,
                min(
                    100,
                    int(user_level)
                )
            )

            # Required level
            required_level = max(
                0,
                min(
                    100,
                    int(required_level)
                )
            )

            # Add required level
            total_required += required_level

            # Only count achieved level up to requirement
            total_user += min(
                user_level,
                required_level
            )

            # Calculate skill gap
            gap = max(
                0,
                required_level - user_level
            )

            # Only add missing skills
            if gap > 0:

                gaps.append(
                    {
                        "skill_id": skill.id,
                        "skill": skill.name,
                        "category": skill.category,
                        "user_level": user_level,
                        "required_level": required_level,
                        "gap": gap
                    }
                )

        # -------------------------------------------------
        # Calculate career match
        # -------------------------------------------------

        if total_required > 0:

            match_percentage = (
                total_user /
                total_required
            ) * 100

        else:

            match_percentage = 0

        # -------------------------------------------------
        # Sort gaps
        # Largest gap first
        # -------------------------------------------------

        gaps.sort(
            key=lambda x: x["gap"],
            reverse=True
        )

        results.append(
            {
                "career_id": career.id,
                "career": career.name,
                "description": career.description,
                "match_percentage": round(
                    match_percentage,
                    2
                ),
                "skill_gaps": gaps
            }
        )

    # =================================================
    # SORT CAREERS BY MATCH
    # =================================================

    results.sort(
        key=lambda x: x["match_percentage"],
        reverse=True
    )

    # =================================================
    # TOP RECOMMENDATION
    # =================================================

    top_career = (
        results[0]
        if results
        else None
    )

    # =================================================
    # RESPONSE
    # =================================================

    return {
        "status": "success",
        "total_careers_analyzed": len(results),
        "recommended_career": top_career,
        "recommendations": results
    }