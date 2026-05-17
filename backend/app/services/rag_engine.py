import os
import chromadb
from sentence_transformers import SentenceTransformer
import logging
import uuid

logger = logging.getLogger(__name__)

# Khởi tạo mô hình Embedding tiếng Việt (mô hình nhẹ và tốt)
# Khi chạy lần đầu sẽ mất chút thời gian tải về
try:
    # Có thể dùng bkai-foundation-models/vietnamese-bi-encoder hoặc keepitreal/vietnamese-sbert
    embedding_model = SentenceTransformer('keepitreal/vietnamese-sbert')
except Exception as e:
    logger.error(f"Lỗi tải mô hình embedding: {e}")
    embedding_model = None

# Khởi tạo ChromaDB lưu tại thư mục cục bộ
DB_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "chroma_db")
if not os.path.exists(DB_PATH):
    os.makedirs(DB_PATH)

try:
    chroma_client = chromadb.PersistentClient(path=DB_PATH)
    collection_name = "pdf_documents"
    collection = chroma_client.get_or_create_collection(name=collection_name)
except Exception as e:
    logger.error(f"Lỗi khởi tạo ChromaDB collection: {e}")
    collection = None

def chunk_text(text: str, chunk_size: int = 250, overlap: int = 50) -> list[str]:
    """Cắt văn bản thành các đoạn nhỏ (chunks) để đưa vào Vector DB."""
    words = text.split()
    chunks = []
    i = 0
    while i < len(words):
        chunk = " ".join(words[i:i + chunk_size])
        chunks.append(chunk)
        i += chunk_size - overlap
    return chunks

def index_document(text: str, session_id: str = None) -> str:
    """Băm nhỏ tài liệu và lưu vào ChromaDB dưới một session_id (mã phiên làm việc)."""
    if not session_id:
        session_id = str(uuid.uuid4())
        
    if embedding_model is None or collection is None:
        logger.error("RAG Engine chưa sẵn sàng!")
        return session_id

    # Tránh bị trùng lặp nếu người dùng upload lại cùng session_id
    try:
        collection.delete(where={"session_id": session_id})
    except Exception:
        pass
    
    chunks = chunk_text(text)
    if not chunks:
        return session_id
        
    # Tạo embeddings
    try:
        embeddings = embedding_model.encode(chunks, show_progress_bar=False).tolist()
        
        # Tạo IDs và Metadata
        ids = [f"{session_id}_chunk_{i}" for i in range(len(chunks))]
        metadatas = [{"session_id": session_id} for _ in chunks]
        
        # Lưu vào Chroma
        collection.add(
            embeddings=embeddings,
            documents=chunks,
            metadatas=metadatas,
            ids=ids
        )
        logger.info(f"Đã vector hóa và lưu {len(chunks)} chunks cho session {session_id}.")
    except Exception as e:
        logger.error(f"Lỗi khi index tài liệu: {e}")
        
    return session_id

def find_relevant_context(query: str, session_id: str, top_k: int = 3) -> str:
    """Tìm kiếm K đoạn văn bản liên quan nhất tới câu hỏi của người dùng."""
    if embedding_model is None or collection is None:
        return ""

    try:
        query_embedding = embedding_model.encode([query]).tolist()
        
        results = collection.query(
            query_embeddings=query_embedding,
            n_results=top_k,
            where={"session_id": session_id}
        )
        
        if not results or not results['documents'] or not results['documents'][0]:
            return ""
            
        # Nối các chunks tìm được lại thành 1 văn bản Context
        context = "\n\n...\n\n".join(results['documents'][0])
        return context
    except Exception as e:
        logger.error(f"Lỗi khi query ChromaDB: {e}")
        return ""
