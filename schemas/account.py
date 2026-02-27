from pydantic import BaseModel
from decimal import Decimal


class AccountCreate(BaseModel):
    pass


class AccountResponse(BaseModel):
    id: int
    balance: Decimal

    class Config:
        from_attributes = True
        from pydantic import BaseModel
from decimal import Decimal
from datetime import datetime


class DepositRequest(BaseModel):
    amount: Decimal


class TransferRequest(BaseModel):
    to_account_id: int
    amount: Decimal


class TransactionResponse(BaseModel):
    id: int
    amount: Decimal
    type: str
    created_at: datetime

    class Config:
        from_attributes = True
