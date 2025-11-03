# schemas.py
from pydantic import BaseModel, EmailStr
from pydantic import Field

class Holding(BaseModel):
    coin: str
    amount: float

class UserResponse(BaseModel):
    username: str
    email: EmailStr
    is_admin: bool = False

class UserCreate(BaseModel):
    username: str = Field(..., min_length=3)
    email: EmailStr
    phone: str = Field(..., pattern=r"^\+?[1-9]\d{1,14}$")  # E.164
    country: str
    password: str = Field(..., min_length=6)

class UserLogin(BaseModel):
    username: str
    password: str

class UserProfile(BaseModel):
    username: str
    email: str
    phone: str
    country: str
    created_at: str
    class Config:
        orm_mode = True

