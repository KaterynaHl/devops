from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.config import load_config

config = load_config()

DATABASE_URL = config["database_url"]

engine = create_engine(DATABASE_URL)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)