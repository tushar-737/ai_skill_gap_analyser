import os

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import URL
from sqlalchemy.orm import sessionmaker, declarative_base


# =====================================================
# LOAD ENVIRONMENT VARIABLES
# =====================================================

_here = os.path.dirname(__file__)
_backend_env = os.path.join(_here, ".env")

if os.path.exists(_backend_env):
    load_dotenv(dotenv_path=_backend_env, override=False)

load_dotenv(override=False)


# =====================================================
# DATABASE CONFIGURATION
# =====================================================

# Prefer DATABASE_URL if provided.
DATABASE_URL = os.getenv("DATABASE_URL", "").strip()

if not DATABASE_URL:

    required_db_vars = (
        "DB_USER",
        "DB_PASSWORD",
        "DB_HOST",
        "DB_PORT",
        "DB_NAME",
    )

    missing_db_vars = [
        name
        for name in required_db_vars
        if not os.getenv(name)
    ]

    if missing_db_vars:
        missing = ", ".join(missing_db_vars)

        raise RuntimeError(
            f"Missing database configuration: {missing}. "
            "Configure backend/.env."
        )

    try:
        db_port = int(os.environ["DB_PORT"])

    except ValueError as exc:

        raise RuntimeError(
            "DB_PORT must be a valid integer."
        ) from exc

    DATABASE_URL = URL.create(
        "mysql+pymysql",

        username=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        host=os.environ["DB_HOST"],
        port=db_port,
        database=os.environ["DB_NAME"],
    )


# =====================================================
# DATABASE ENGINE
# =====================================================

engine = create_engine(

    DATABASE_URL,

    # Aiven MySQL requires encrypted connections.
    connect_args={
        "ssl": {}
    },

    # Test connection before using it.
    pool_pre_ping=True,

    # Recycle connections periodically.
    pool_recycle=3600,

)


# =====================================================
# DATABASE SESSION
# =====================================================

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)


# =====================================================
# SQLALCHEMY BASE
# =====================================================

Base = declarative_base()


# =====================================================
# DATABASE DEPENDENCY
# =====================================================

def get_db():

    db = SessionLocal()

    try:
        yield db

    finally:
        db.close()