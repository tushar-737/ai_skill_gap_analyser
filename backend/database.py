import os

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base


# =====================================================
# LOAD ENVIRONMENT VARIABLES — robust for Workbench + uvicorn
# Looks for backend/.env when running from repo root, and also
# tries the current working directory's .env as fallback.
# =====================================================

# Try backend/.env first (when `uvicorn backend.main:app` from repo root)
_here = os.path.dirname(__file__)
_backend_env = os.path.join(_here, ".env")
if os.path.exists(_backend_env):
    load_dotenv(dotenv_path=_backend_env, override=False)

# Also try CWD .env (when running from backend/ dir or custom setup)
load_dotenv(override=False)


# =====================================================
# MYSQL DATABASE CONFIGURATION
# =====================================================

DB_USER = os.getenv("DB_USER", "root")
DB_PASSWORD = os.getenv("DB_PASSWORD", "1234")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "3306")
DB_NAME = os.getenv("DB_NAME", "ai_skill_gap")


DATABASE_URL = (
    f"mysql+pymysql://"
    f"{DB_USER}:{DB_PASSWORD}"
    f"@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)


# =====================================================
# DATABASE ENGINE
# =====================================================

engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
    pool_recycle=3600,
)


# =====================================================
# SESSION
# =====================================================

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)


# =====================================================
# BASE MODEL
# =====================================================

Base = declarative_base()


# =====================================================
# DATABASE SESSION
# =====================================================

def get_db():
    db = SessionLocal()

    try:
        yield db

    finally:
        db.close()