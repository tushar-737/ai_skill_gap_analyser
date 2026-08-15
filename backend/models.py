from datetime import datetime

from sqlalchemy import (
    Column,
    Integer,
    String,
    Text,
    ForeignKey,
    DateTime,
    JSON,
    UniqueConstraint,
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

    # Prevent duplicate programs such as:
    # BCA
    # BCA
    # BCA
    __table_args__ = (
        UniqueConstraint(
            "name",
            name="uq_education_program_name"
        ),
    )

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

    # Every career path must be unique.
    #
    # Example:
    # Data Scientist
    # Data Scientist   <-- NOT allowed
    #
    __table_args__ = (
        UniqueConstraint(
            "name",
            name="uq_career_name"
        ),
    )

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    # Each career has one PRIMARY domain.
    #
    # We are intentionally keeping this as one-to-many
    # instead of introducing a many-to-many relationship.
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

    # Canonical skill name.
    #
    # Examples:
    # Python
    # Pandas
    # NumPy
    #
    # These must remain separate skills.
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

    # A career can have a particular skill ONLY ONCE.
    #
    # Prevents bad data such as:
    #
    # Data Scientist → Python → 90
    # Data Scientist → Python → 80
    # Data Scientist → Python → 75
    #
    # Only one Data Scientist → Python mapping is allowed.
    __table_args__ = (
        UniqueConstraint(
            "career_id",
            "skill_id",
            name="uq_career_skill"
        ),
    )

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    career_id = Column(
        Integer,
        ForeignKey("careers_v2.id"),
        nullable=False,
        index=True
    )

    skill_id = Column(
        Integer,
        ForeignKey("skills_v2.id"),
        nullable=False,
        index=True
    )

    # Required skill level from 0-100.
    #
    # Example:
    # Python → 90
    # SQL → 80
    # Excel → 70
    required_level = Column(
        Integer,
        nullable=False,
        default=50
    )


# =====================================================
# RESUME ANALYSIS
# =====================================================

class ResumeAnalysis(Base):

    __tablename__ = "resume_analyses"

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    # Original uploaded filename
    file_name = Column(
        String(255),
        nullable=False
    )

    # File size in bytes
    file_size = Column(Integer)

    # -------------------------------------------------
    # Browser/session owner identifier
    # -------------------------------------------------
    #
    # Used to isolate resume history between browser
    # sessions.
    #
    # This is NOT authentication.
    #
    owner_token = Column(
        String(64),
        index=True,
        nullable=True
    )

    # Original extracted resume text
    raw_text = Column(Text)

    # -------------------------------------------------
    # Extracted skills
    # -------------------------------------------------
    #
    # Example:
    #
    # {
    #     "skills": [
    #         {
    #             "skill_id": 12,
    #             "name": "Python",
    #             "inferred_level": 80,
    #             "evidence": "Developed ML projects..."
    #         }
    #     ]
    # }
    #
    extracted_skills = Column(JSON)

    # -------------------------------------------------
    # Target career
    # -------------------------------------------------
    #
    # Optional because a resume can be uploaded before
    # a career is selected.
    #
    target_career_id = Column(
        Integer,
        ForeignKey("careers_v2.id"),
        nullable=True,
        index=True
    )

    # How the resume was analyzed:
    #
    # keyword
    # gemini
    # hybrid
    #
    extraction_source = Column(
        String(20),
        default="keyword"
    )

    # Creation timestamp
    created_at = Column(
        DateTime,
        default=datetime.utcnow,
        nullable=False
    )