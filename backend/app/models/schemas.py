from pydantic import BaseModel

class SummaryResponse(BaseModel):
    summary: str
    word_count: int
    processing_time: float
    session_id: str | None = None

class ChatRequest(BaseModel):
    message: str
    session_id: str

class ChatResponse(BaseModel):
    reply: str
