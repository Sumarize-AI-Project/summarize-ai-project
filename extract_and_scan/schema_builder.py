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
    metadata: dict = None,
    # Thêm 2 tham số mới để nhận dữ liệu bảng và ảnh
    tables_data: list = None,
    images_data: list = None
):
    """
    Hàm đóng gói dữ liệu đã bóc tách thành chuẩn JSON Schema cho MongoDB.
    """
    
    if metadata is None:
        metadata = {
            "title": "",
            "authors": [],
            "publish_year": None,
            "keywords_author": []
        }
        
    # Xử lý list rỗng mặc định
    if tables_data is None:
        tables_data = []
    if images_data is None:
        images_data = []

    current_time = datetime.now(timezone.utc).isoformat()
    unique_id = str(uuid.uuid4())
    document_id = f"{journal_code}_{unique_id[:8]}" 

    basic_identifiers = {
        "_id": unique_id,
        "document_id": document_id,
        "journal_code": journal_code,
        "processing_label": processing_label
    }
    
    file_info = {
        "document_id": document_id,
        "file_name": file_name,
        "local_path": local_path,
        "file_size_kb": file_size_kb,
        "page_count": page_count
    }
    
    metadata_collection = {
        "document_id": document_id,
        "title": metadata.get("title", ""),
        "authors": metadata.get("authors", []),
        "publish_year": metadata.get("publish_year", None),
        "keywords_author": metadata.get("keywords_author", [])
    }
    
    # MỞ RỘNG Collection 4: content
    content_collection = {
        "document_id": document_id,
        "full_text": full_text,
        # Lưu trữ cấu trúc Markdown hoặc HTML của bảng
        "tables": tables_data, 
        # Lưu trữ đường dẫn tới file ảnh đã cắt và caption của nó
        "images": images_data  
    }
    
    # MỞ RỘNG Collection 5: nlp_data
    nlp_data_collection = {
        "document_id": document_id,
        "extracted_text": bool(full_text.strip()),
        "ai_summary": None,
        "extracted_entities": [],
        "embedding_vector": None,
        # Cờ đánh dấu xem tài liệu này có chứa các thành phần phức tạp không
        "has_tables": len(tables_data) > 0,
        "has_images": len(images_data) > 0
    }
    
    system_collection = {
        "document_id": document_id,
        "status": "extracted",
        "created_at": current_time,
        "updated_at": current_time
    }
    
    doc = {
        "basic_identifiers": basic_identifiers,
        "file_info": file_info,
        "metadata": metadata_collection,
        "content": content_collection,
        "nlp_data": nlp_data_collection,
        "system": system_collection
    }
    
    return doc