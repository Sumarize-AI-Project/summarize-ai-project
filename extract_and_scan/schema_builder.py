import uuid
from datetime import datetime, timezone

def build_mongo_document(
    file_name: str,
    local_path: str,
    processing_label: str,
    journal_code: str = "UNKNOWN",
    file_size_kb: int = 0,
    page_count: int = 0,
    full_text: str = "",
    pages_data: list = None,
    metadata: dict = None
):
    """
    Hàm đóng gói dữ liệu đã bóc tách thành chuẩn JSON Schema cho MongoDB.
    """
    
    # Xử lý các giá trị mặc định nếu không được truyền vào
    if pages_data is None:
        pages_data = []
        
    if metadata is None:
        metadata = {
            "title": "",
            "authors": [],
            "publish_year": None,
            "keywords_author": []
        }

    # Lấy thời gian chuẩn UTC hiện tại
    current_time = datetime.now(timezone.utc).isoformat()
    
    # Tạo ID duy nhất (Tránh trùng lặp 100% khi nạp vào database)
    unique_id = str(uuid.uuid4())

    # Đúc khuôn Document
    doc = {
        "_id": unique_id,
        "document_id": f"{journal_code}_{unique_id[:8]}", # Mã ID ngắn gọn dễ nhìn
        "journal_code": journal_code,
        "processing_label": processing_label, # A, B1, hoặc B2
        
        "file_info": {
            "file_name": file_name,
            "local_path": local_path,
            "file_size_kb": file_size_kb,
            "page_count": page_count
        },
        
        "metadata": metadata,
        
        "content": {
            "full_text": full_text,
            "pages": pages_data # Danh sách các trang: [{"page_number": 1, "text": "..."}, ...]
        },
        
        "nlp_data": {
            "extracted_text": True, # Đánh dấu là đã qua bước bóc chữ
            "ai_summary": None,
            "extracted_entities": [],
            "embedding_vector": None
        },
        
        "system": {
            "status": "extracted",
            "created_at": current_time,
            "updated_at": current_time
        }
    }
    
    return doc
