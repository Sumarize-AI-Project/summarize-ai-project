from fastapi import APIRouter, UploadFile, File, Form, HTTPException, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.domain import SessionRecord
from app.models.schemas import SummaryResponse
import shutil
import os
import time

from app.services.pdf_parser import extract_text_from_pdf
from app.services.text_rank import generate_extractive_summary

router = APIRouter()

@router.post("/summarize", response_model=SummaryResponse)
async def summarize_pdf(
    file: UploadFile = File(...),
    target_words: int = Form(500),
    mode: str = Form("polished", description="Nhập 'extractive' để lấy bản thô, 'polished' để lấy bản AI đã biên tập"),
    session_id: str = Form(None, description="Mã phiên làm việc. Nếu để trống hệ thống tự tạo."),
    db: Session = Depends(get_db)
):
    if not file.filename.endswith('.pdf'):
        raise HTTPException(status_code=400, detail="Chỉ hỗ trợ file PDF.")
        
    temp_path = f"temp_uploads/{file.filename}"
    t0 = time.time()
    
    try:
        # 1. Lưu file tạm
        with open(temp_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        # 2. Đọc file PDF bằng PyMuPDF
        pdf_text = extract_text_from_pdf(temp_path)
        if not pdf_text:
            raise HTTPException(status_code=400, detail="Không thể trích xuất văn bản từ PDF này.")
            
        # 2.5 (RAG) Đưa văn bản toàn bộ PDF vào Vector DB để phục vụ tính năng Chat
        from app.services.rag_engine import index_document
        current_session_id = index_document(pdf_text, session_id)
            
        # 3. Chạy thuật toán TextRank (Trích xuất các câu quan trọng nhất thô)
        textrank_result = generate_extractive_summary(pdf_text, target_words=target_words)
        extractive_text = textrank_result["extractive_text"]
        
        if mode == "extractive":
            final_summary = extractive_text
        else:
            # 4. Giai đoạn 2: Gọi LLM để biên tập lại cho mượt mà (Polishing)
            try:
                from app.services.llm_service import polish_summary
                final_summary = polish_summary(extractive_text, target_words=target_words)
            except Exception as e:
                import logging
                logging.error(f"LLM polishing failed: {e}. Falling back to extractive summary.")
                final_summary = extractive_text
            
        word_count = len(final_summary.split())
        
        # --- LƯU VÀO DATABASE ---
        db_session = db.query(SessionRecord).filter(SessionRecord.id == current_session_id).first()
        if not db_session:
            db_session = SessionRecord(
                id=current_session_id,
                pdf_filename=file.filename,
                summary_text=final_summary
            )
            db.add(db_session)
        else:
            db_session.summary_text = final_summary
        db.commit()
        # ------------------------

        return SummaryResponse(
            summary=final_summary,
            word_count=word_count,
            processing_time=round(time.time() - t0, 2),
            session_id=current_session_id
        )
    finally:
        # Xóa file tạm
        if os.path.exists(temp_path):
            os.remove(temp_path)
