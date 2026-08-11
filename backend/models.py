from datetime import datetime

from sqlalchemy import (
    Column,
    Integer,
    String,
    Text,
    ForeignKey,
    DateTime,
    JSON,
)

from .database import Base


# =====================================================
# EDUCATION CATEGORY
# =====================================================

class EducationCategory(Base):

    __tablename__ = "education_categories"

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    name = Column(
        String(100),
        unique=True,
        nullable=False
    )

    description = Column(Text)


# =====================================================
# EDUCATION PROGRAM
# =====================================================

class EducationProgram(Base):

    __tablename__ = "education_programs"

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    category_id = Column(
        Integer,
        ForeignKey("education_categories.id"),
        nullable=True
    )

    name = Column(
        String(150),
        nullable=False
    )

    level = Column(
        String(50)
    )

    description = Column(Text)


# =====================================================
# DOMAIN
# =====================================================

class Domain(Base):

    __tablename__ = "domains"

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    name = Column(
        String(150),
        unique=True,
        nullable=False
    )

    description = Column(Text)


# =====================================================
# CAREER
# =====================================================

class Career(Base):

    __tablename__ = "careers_v2"

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    domain_id = Column(
        Integer,
        ForeignKey("domains.id"),
        nullable=True
    )

    name = Column(
        String(150),
        nullable=False
    )

    description = Column(Text)

    average_level = Column(
        String(50)
    )


# =====================================================
# SKILL
# =====================================================

class Skill(Base):

    __tablename__ = "skills_v2"

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    name = Column(
        String(150),
        unique=True,
        nullable=False
    )

    category = Column(
        String(100)
    )

    description = Column(Text)


# =====================================================
# CAREER SKILL REQUIREMENT
# =====================================================

class CareerSkillRequirement(Base):

    __tablename__ = "career_skill_requirements"

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    career_id = Column(
        Integer,
        ForeignKey("careers_v2.id"),
        nullable=False
    )

    skill_id = Column(
        Integer,
        ForeignKey("skills_v2.id"),
        nullable=False
    )

    required_level = Column(
        Integer,
        nullable=False,
        default=50
    )


# =====================================================
# RESUME ANALYSIS — stores uploaded resume parses
# Uses JSON for extracted_skills so it works in MySQL 5.7+
# Workbench: forward-engineer via workbench/init.sql
# =====================================================

class ResumeAnalysis(Base):

    __tablename__ = "resume_analyses"

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    file_name = Column(
        String(255),
        nullable=False
    )

    file_size = Column(Integer)

    # Opaque client-generated identifier used to isolate each browser's history.
    # It is not an authentication substitute for a multi-user production app.
    owner_token = Column(String(64), index=True, nullable=True)

    raw_text = Column(Text)

    # { skills: [{ skill_id, name, inferred_level, evidence }], ... }
    extracted_skills = Column(JSON)

    # Optional: which career the user was targeting at upload time
    target_career_id = Column(
        Integer,
        ForeignKey("careers_v2.id"),
        nullable=True
    )

    # How the extraction was done: "gemini" | "keyword" | "hybrid"
    extraction_source = Column(String(20), default="keyword")

    created_at = Column(
        DateTime,
        default=datetime.utcnow,
        nullable=False
    )
