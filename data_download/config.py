from pathlib import Path

# ==========================================
# CẤU HÌNH ĐƯỜNG DẪN DỰ ÁN
# ==========================================
PROJECT_DIR = Path("dataops_project")
DB_PATH = PROJECT_DIR / "dataops_tracker.db"
PDF_DIR = PROJECT_DIR / "pdf_raw"

# NHỚ SỬA DÒNG NÀY: Trỏ tới file JSON trên máy tính của bạn
JSON_INPUT = "merged_data.json" 

# ==========================================
# CẤU HÌNH TẢI DỮ LIỆU
# ==========================================
MAX_CONCURRENT_DOWNLOADS = 10
TIMEOUT_SECONDS = 30.0

# Tự động tạo thư mục nếu chưa có
PDF_DIR.mkdir(parents=True, exist_ok=True)