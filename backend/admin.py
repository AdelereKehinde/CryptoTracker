# admin.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from database import get_db
from models import User, Notification, EmailSubscription, UserMessage, SessionLog
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import jwt
from datetime import datetime, timedelta

ADMIN_USERNAME = "admin"
ADMIN_PASSWORD = "cheeseball2025"
SECRET_KEY = "supersecretkey"
ALGORITHM = "HS256"

router = APIRouter(prefix="/admin", tags=["admin"])

def authenticate_admin(username: str, password: str):
    return username == ADMIN_USERNAME and password == ADMIN_PASSWORD

def create_admin_token():
    expire = datetime.utcnow() + timedelta(hours=12)
    to_encode = {"sub": ADMIN_USERNAME, "exp": expire}
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

@router.post("/login")
def admin_login(form_data: OAuth2PasswordRequestForm = Depends()):
    if authenticate_admin(form_data.username, form_data.password):
        token = create_admin_token()
        return {"access_token": token, "token_type": "bearer"}
    raise HTTPException(status_code=401, detail="Invalid admin credentials")

# Admin CRUD endpoints
@router.get("/users")
def get_users(db: Session = Depends(get_db)):
    return db.query(User).all()

@router.post("/users")
def add_user(username: str, email: str, password: str, db: Session = Depends(get_db)):
    user = User(username=username, email=email, hashed_password=password)
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

@router.delete("/users/{user_id}")
def delete_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    db.delete(user)
    db.commit()
    return {"detail": "User deleted"}

@router.post("/notifications")
def send_notification(user_id: int, message: str, db: Session = Depends(get_db)):
    notif = Notification(user_id=user_id, message=message)
    db.add(notif)
    db.commit()
    return notif

@router.get("/sessions")
def get_sessions(db: Session = Depends(get_db)):
    return db.query(SessionLog).all()

@router.get("/emails")
def get_emails(db: Session = Depends(get_db)):
    return db.query(EmailSubscription).all()

@router.get("/messages")
def get_messages(db: Session = Depends(get_db)):
    return db.query(UserMessage).all()
