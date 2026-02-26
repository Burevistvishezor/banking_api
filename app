from sqlalchemy import Column, Integer, String, Boolean, DateTime
from sqlalchemy.sql import func
from app.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)

    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)

    full_name = Column(String, nullable=False)

    is_active = Column(Boolean, default=True)
    is_admin = Column(Boolean, default=False)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
app/main.py
from fastapi import FastAPI
from app.database import engine, Base

app = FastAPI(title="Banking API")

# создаём таблицы (пока без Alembic)
Base.metadata.create_all(bind=engine)


@app.get("/")
def root():
    return {"message": "Banking API is running"}