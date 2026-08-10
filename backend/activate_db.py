"""
One-command DB activator — for MySQL Workbench users who want code-only setup.

Usage:
  # From repo root (recommended, venv active):
  python -m backend.activate_db

  # Or directly:
  python backend/activate_db.py

What it does:
  - Loads backend/.env (via database.py) for DB_USER/PASSWORD/HOST/PORT/NAME
  - Creates ai_skill_gap DB tables if missing (IF NOT EXISTS) from models.py
  - Prints live counts from /api/statistics so you can verify in terminal

Workbench alternative:
  File -> Open SQL Script -> backend/workbench/init.sql -> Execute
"""

from .database import engine
from .models import Base
from sqlalchemy import text


def main():
    print("→ Activating database (creating tables if missing)...")
    print(f"  Engine: {engine.url}")

    # Create all tables defined in models.py (safe, uses IF NOT EXISTS)
    Base.metadata.create_all(bind=engine)
    print("✓ Tables verified/created from models.py")

    # Verify counts (same as GET /api/statistics)
    try:
        with engine.connect() as conn:
            for tbl in ["education_categories", "education_programs", "domains", "careers_v2", "skills_v2", "career_skill_requirements", "resume_analyses"]:
                try:
                    c = conn.execute(text(f"SELECT COUNT(*) FROM `{tbl}`")).scalar()
                    print(f"  - {tbl}: {c}")
                except Exception as e:
                    print(f"  - {tbl}: (missing or error: {e})")
    except Exception as e:
        print(f"⚠ Could not verify counts (DB connection issue): {e}")
        print("  Check backend/.env -> DB_USER/PASSWORD/HOST/PORT/NAME and that MySQL is running")
        return

    print("\n✓ Database active. Now run: uvicorn backend.main:app --reload --port 8000")
    print("  Test: http://127.0.0.1:8000/api/database-test  and  GET /api/statistics")


if __name__ == "__main__":
    main()
