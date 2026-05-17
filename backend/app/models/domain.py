from sqlalchemy import Column, String, Text, DateTime, ForeignKey, Boolean, Integer
from sqlalchemy.orm import relationship
from datetime import datetime
from app.core.database import Base

class SessionRecord(Base):
    __tablename__ = "sessions"

    id = Column(String, primary_key=True, index=True) # session_id (UUID)
    user_id = Column(String, nullable=True, index=True) # Dành cho lúc tích hợp Đăng nhập
    pdf_filename = Column(String, nullable=True)
    summary_text = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    last_accessed = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Quan hệ với bảng chat_messages
    messages = relationship("ChatMessage", back_populates="session", cascade="all, delete-orphan")

class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    session_id = Column(String, ForeignKey("sessions.id"))
    is_user = Column(Boolean, default=True)
    content = Column(Text, nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow)

    session = relationship("SessionRecord", back_populates="messages")
