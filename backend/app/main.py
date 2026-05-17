from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os

from app.api import routes_summary, routes_chat
from app.core.database import engine, Base
from app.models import domain

# Tạo các bảng trong cơ sở dữ liệu SQLite
Base.metadata.create_all(bind=engine)

# Đảm bảo thư mục temp_uploads tồn tại ở ngoài cùng
os.makedirs("temp_uploads", exist_ok=True)

app = FastAPI(
    title="AI Summarize API",
    description="Backend for PDF Summarization and Chat using TextRank and Gemma API",
    version="1.0.0"
)

# Cấu hình CORS để App Flutter có thể gọi được từ mọi nguồn
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

from app.api import routes_summary, routes_chat, routes_history

# Đăng ký các routes
app.include_router(routes_summary.router, prefix="/api", tags=["Summary"])
app.include_router(routes_chat.router, prefix="/api", tags=["Chat"])
app.include_router(routes_history.router, prefix="/api/history", tags=["History"])

@app.on_event("startup")
def on_startup():
    from app.services.llm_service import diagnose
    diagnose()


@app.get("/")
def read_root():
    return {"status": "ok", "message": "AI Summarizer Backend is running!"}
