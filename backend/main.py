import os
import json
import re
import io
from datetime import datetime
from typing import Dict, List, Optional

import requests

from fastapi import FastAPI, Depends, HTTPException, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware

from pydantic import BaseModel, Field

from sqlalchemy.orm import Session
from sqlalchemy import text

from .database import get_db
from . import models


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
    allow_credentials=True,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
)


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

    except Exception as e:

        return {
            "status": "error",
            "message": str(e),
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

    if match_percentage >= 90:
        return "Excellent"

    if match_percentage >= 75:
        return "Strong"

    if match_percentage >= 60:
        return "Good"

    if match_percentage >= 40:
        return "Needs Improvement"

    return "Beginner"


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
    # ANALYZE CAREERS
    # =================================================

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


        total_required = 0
        total_user = 0

        gaps = []
        strengths = []


        # =============================================
        # ANALYZE EACH SKILL
        # =============================================

        for requirement, skill in (
            career_requirements_list
        ):

            required_level = max(
                0,
                min(
                    100,
                    int(
                        requirement.required_level
                    )
                )
            )


            user_level = request.skills.get(
                skill.id,
                0
            )


            try:

                user_level = int(
                    user_level
                )

            except (
                ValueError,
                TypeError,
            ):

                user_level = 0


            user_level = max(
                0,
                min(
                    100,
                    user_level
                )
            )


            # =========================================
            # SCORE
            # =========================================

            total_required += required_level

            total_user += min(
                user_level,
                required_level
            )


            # =========================================
            # GAP
            # =========================================

            gap = max(
                0,
                required_level - user_level
            )


            # =========================================
            # STRENGTH
            # =========================================

            if gap == 0:

                strengths.append(
                    {
                        "skill_id": skill.id,
                        "skill": skill.name,
                        "category": skill.category,
                        "user_level": user_level,
                        "required_level": required_level,
                        "gap": 0,
                    }
                )


            # =========================================
            # SKILL GAP
            # =========================================

            else:

                gaps.append(
                    {
                        "skill_id": skill.id,
                        "skill": skill.name,
                        "category": skill.category,
                        "user_level": user_level,
                        "required_level": required_level,
                        "gap": gap,
                        "priority": get_priority(
                            gap
                        ),
                    }
                )


        # =============================================
        # MATCH PERCENTAGE
        # =============================================

        if total_required > 0:

            match_percentage = (
                total_user /
                total_required
            ) * 100

        else:

            match_percentage = 0


        match_percentage = round(
            match_percentage,
            2
        )


        # =============================================
        # SORT
        # =============================================

        gaps.sort(
            key=lambda x: (
                x["gap"],
                x["required_level"]
            ),
            reverse=True,
        )


        strengths.sort(
            key=lambda x: (
                x["user_level"],
                x["required_level"]
            ),
            reverse=True,
        )


        # =============================================
        # READINESS
        # =============================================

        readiness = get_readiness(
            match_percentage
        )


        # =============================================
        # RESULT
        # =============================================

        results.append(
            {
                "career_id": career.id,

                "career": career.name,

                "description": career.description,

                "match_percentage": (
                    match_percentage
                ),

                "readiness": readiness,

                "strengths": strengths,

                "skill_gaps": gaps,

                "total_skills": (
                    len(
                        career_requirements_list
                    )
                ),

                "missing_skills": len(
                    gaps
                ),
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

# Debug helper — logs whether Gemini passkey is loaded (without printing the key)
print(f"[Gemini] API key loaded: {'yes' if GEMINI_API_KEY else 'no'} ({len(GEMINI_API_KEY) if GEMINI_API_KEY else 0} chars), model={GEMINI_MODEL}")


class SkillGapItem(BaseModel):
    name: str
    current: int = 0
    required: int = 0
    gap: int = 0


class AiRoadmapRequest(BaseModel):
    career_name: str
    match_score: int = 0
    skill_gaps: List[SkillGapItem] = Field(default_factory=list)
    strong_skills: List[str] = Field(default_factory=list)
    education: Optional[str] = None


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
    if not GEMINI_API_KEY:
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
            return parsed

        return None

    except Exception as e:
        print("GEMINI ROADMAP ERROR:", e)
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
def get_ai_roadmap(payload: AiRoadmapRequest):
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
ALLOWED_RESUME_EXTS = {".pdf", ".docx", ".doc", ".txt"}


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

    # --- DOCX / DOC (docx parsed without lxml: zip + stdlib xml) ---
    if name.endswith(".docx") or name.endswith(".doc"):
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
        # Old .doc (not zip) — fall back to text decode
        try:
            return data.decode("utf-8", errors="ignore")
        except Exception:
            return ""

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
    if not GEMINI_API_KEY:
        return None
    if not resume_text or len(resume_text.strip()) < 20:
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
            return parsed
        return None
    except Exception as e:
        print("GEMINI RESUME ERROR:", e)
        return None


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
    file: UploadFile = File(...),
    target_career_id: Optional[int] = Form(None),
    education: Optional[str] = Form(None),
    db: Session = Depends(get_db),
):
    # --- Validate ---
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

    # --- Extract text ---
    raw_text = _extract_text_from_bytes(data, file.filename).strip()
    if not raw_text or len(raw_text) < 20:
        raise HTTPException(
            status_code=422,
            detail="Could not extract text from resume. If it's a scanned PDF, try exporting to searchable PDF or DOCX.",
        )

    # --- Load known skills from Workbench DB ---
    try:
        known_skills: List[models.Skill] = db.query(models.Skill).order_by(models.Skill.name).all()
    except Exception as e:
        print("DB SKILLS LOAD ERROR:", e)
        known_skills = []

    # --- Try Gemini, fallback to keyword ---
    gemini_result = _call_gemini_resume_extract(raw_text, known_skills)
    if gemini_result and gemini_result.get("skills"):
        raw_skills = gemini_result["skills"]
        source = "gemini"
        summary = gemini_result.get("summary", "")
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

    # --- Persist for Workbench (best-effort, don't fail upload if DB down) ---
    saved_id = None
    try:
        row = models.ResumeAnalysis(
            file_name=file.filename,
            file_size=len(data),
            raw_text=raw_text[:10000],  # cap for DB
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

    return {
        "status": "success",
        "file_name": file.filename,
        "file_size": len(data),
        "text_length": len(raw_text),
        "text_preview": raw_text[:800],
        "extraction_source": source,
        "gemini_used": source == "gemini",
        "summary": summary,
        "extracted_skills": mapped,
        # Frontend can directly do: setSkillLevels({...mapped levels})
        "inferred_levels": {str(m["skill_id"]): m["inferred_level"] for m in mapped if m["skill_id"] is not None},
        "gap_preview": gap_preview,
        "saved_id": saved_id,
        "workbench_hint": "SELECT * FROM resume_analyses ORDER BY created_at DESC LIMIT 5;" if saved_id else "Run backend/workbench/init.sql in MySQL Workbench to enable saving.",
    }


@app.get("/api/resume/history")
def resume_history(
    limit: int = 10,
    db: Session = Depends(get_db),
):
    limit = max(1, min(50, int(limit or 10)))
    try:
        rows = db.query(models.ResumeAnalysis).order_by(models.ResumeAnalysis.created_at.desc()).limit(limit).all()
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
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"History unavailable (run workbench/init.sql): {e}")