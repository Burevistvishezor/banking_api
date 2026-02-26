from pydantic import BaseModel
from decimal import Decimal


class AccountCreate(BaseModel):
    pass


class AccountResponse(BaseModel):
    id: int
    balance: Decimal

    class Config:
        from_attributes = True