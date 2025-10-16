# models.py
from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from database import Base

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    is_admin = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class SessionLog(Base):
    __tablename__ = "session_logs"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer)
    login_time = Column(DateTime(timezone=True), server_default=func.now())
    active = Column(Boolean, default=True)

class Notification(Base):
    __tablename__ = "notifications"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer)
    message = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class EmailSubscription(Base):
    __tablename__ = "email_subscriptions"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class UserMessage(Base):
    __tablename__ = "user_messages"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=True)
    message = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
