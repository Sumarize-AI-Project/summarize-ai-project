from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.domain import ChatMessage, SessionRecord
from app.models.schemas import ChatRequest, ChatResponse
from app.services.rag_engine import find_relevant_context
from app.services.llm_service import generate_chat_reply

router = APIRouter()

@router.post("/chat", response_model=ChatResponse)
async def chat_with_document(request: ChatRequest, db: Session = Depends(get_db)):
    if not request.session_id:
        raise HTTPException(status_code=400, detail="Thiếu session_id. Vui lòng gửi kèm session_id từ kết quả summarize.")
        
    # --- LƯU TIN NHẮN NGƯỜI DÙNG ---
    user_msg = ChatMessage(session_id=request.session_id, is_user=True, content=request.message)
    db.add(user_msg)
    
    # 1. Tìm ngữ cảnh liên quan trong ChromaDB
    context = find_relevant_context(request.message, request.session_id)
    
    if not context:
        reply_text = "Xin lỗi, tôi không tìm thấy thông tin nào trong tài liệu liên quan đến câu hỏi của bạn. Vui lòng kiểm tra lại xem tài liệu đã được tải lên thành công chưa."
        ai_msg = ChatMessage(session_id=request.session_id, is_user=False, content=reply_text)
        db.add(ai_msg)
        db.commit()
        return ChatResponse(reply=reply_text)
        
    # 2. Gọi LLM để sinh câu trả lời
    try:
        reply_text = generate_chat_reply(request.message, context)
        
        # --- LƯU TIN NHẮN AI ---
        ai_msg = ChatMessage(session_id=request.session_id, is_user=False, content=reply_text)
        db.add(ai_msg)
        
        # Cập nhật thời gian truy cập cuối cùng cho session
        db_session = db.query(SessionRecord).filter(SessionRecord.id == request.session_id).first()
        if db_session:
            from datetime import datetime
            db_session.last_accessed = datetime.utcnow()
            
        db.commit()
        
        return ChatResponse(reply=reply_text)
    except Exception as e:
        import logging
        logging.error(f"Chat failed: {e}")
        raise HTTPException(status_code=500, detail="Lỗi khi tạo câu trả lời từ AI.")
