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
app/core/security.py
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext

SECRET_KEY = "supersecretkey"  # потом вынесем в env
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.account import Account
from app.models.user import User
from app.schemas.account import AccountResponse
from app.core.security import get_current_user

router = APIRouter(prefix="/accounts", tags=["Accounts"])


# 🔹 Создать счёт
@router.post("/", response_model=AccountResponse)
def create_account(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    account = Account(owner_id=current_user.id)
    db.add(account)
    db.commit()
    db.refresh(account)
    return account


# 🔹 Получить конкретный счёт
@router.get("/{account_id}", response_model=AccountResponse)
def get_account(
    account_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    account = db.query(Account).filter(Account.id == account_id).first()

    if not account:
        raise HTTPException(status_code=404, detail="Account not found")

    if account.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")

    return account
