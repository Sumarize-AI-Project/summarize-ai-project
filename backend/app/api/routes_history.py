from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.domain import SessionRecord, ChatMessage
from typing import List, Dict

router = APIRouter()

@router.get("/sessions", response_model=List[Dict])
async def get_all_sessions(db: Session = Depends(get_db)):
    """Lấy danh sách các file PDF đã tóm tắt, sắp xếp theo thời gian mới nhất"""
    sessions = db.query(SessionRecord).order_by(SessionRecord.last_accessed.desc()).all()
    
    result = []
    for s in sessions:
        result.append({
            "session_id": s.id,
            "pdf_filename": s.pdf_filename,
            "created_at": s.created_at,
            "last_accessed": s.last_accessed,
            "summary_snippet": s.summary_text[:100] + "..." if s.summary_text else ""
        })
    return result

@router.get("/sessions/{session_id}")
async def get_session_details(session_id: str, db: Session = Depends(get_db)):
    """Lấy chi tiết một phiên làm việc (Bản tóm tắt + Lịch sử Chat)"""
    session = db.query(SessionRecord).filter(SessionRecord.id == session_id).first()
    if not session:
        raise HTTPException(status_code=404, detail="Không tìm thấy phiên làm việc")
        
    messages = db.query(ChatMessage).filter(ChatMessage.session_id == session_id).order_by(ChatMessage.timestamp.asc()).all()
    
    return {
        "session_id": session.id,
        "pdf_filename": session.pdf_filename,
        "summary": session.summary_text,
        "chat_history": [
            {
                "is_user": msg.is_user,
                "content": msg.content,
                "timestamp": msg.timestamp
            } for msg in messages
        ]
    }
