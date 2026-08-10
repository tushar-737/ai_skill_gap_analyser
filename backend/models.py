from sqlalchemy import Column, Integer, String, Text, ForeignKey
from .database import Base


# =====================================================
# EDUCATION CATEGORY
# =====================================================

class EducationCategory(Base):

    __tablename__ = "education_categories"

    id = Column(Integer, primary_key=True, index=True)

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

    id = Column(Integer, primary_key=True, index=True)

    category_id = Column(
        Integer,
        ForeignKey("education_categories.id")
    )

    name = Column(String(150), nullable=False)

    level = Column(String(50))

    description = Column(Text)


# =====================================================
# DOMAIN
# =====================================================

class Domain(Base):

    __tablename__ = "domains"

    id = Column(Integer, primary_key=True, index=True)

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

    id = Column(Integer, primary_key=True, index=True)

    domain_id = Column(
        Integer,
        ForeignKey("domains.id")
    )

    name = Column(String(150), nullable=False)

    description = Column(Text)

    average_level = Column(String(50))


# =====================================================
# SKILL
# =====================================================

class Skill(Base):

    __tablename__ = "skills_v2"

    id = Column(Integer, primary_key=True, index=True)

    name = Column(
        String(150),
        unique=True,
        nullable=False
    )

    category = Column(String(100))

    description = Column(Text)


# =====================================================
# CAREER SKILL REQUIREMENT
# =====================================================

class CareerSkillRequirement(Base):

    __tablename__ = "career_skill_requirements"

    id = Column(Integer, primary_key=True, index=True)

    career_id = Column(
        Integer,
        ForeignKey("careers_v2.id")
    )

    skill_id = Column(
        Integer,
        ForeignKey("skills_v2.id")
    )

    required_level = Column(
        Integer,
        nullable=False,
        default=50
    )