import sys
# BỌC THÉP UNICODE
sys.stdout.reconfigure(encoding='utf-8')

import os
import json
import fitz  # PyMuPDF
import pytesseract
from PIL import Image
import io
from tqdm import tqdm

# Import khuôn đúc MongoDB
from schema_builder import build_mongo_document

print("="*60)
print("🤖 HỆ THỐNG KÍCH HOẠT: CỖ XE TĂNG AI OCR (NHÓM A - SCAN & LỖI FONT)")
print("="*60)

# ==========================================
# CẤU HÌNH TESSERACT (Đường dẫn cài đặt phần mềm của bạn)
# ==========================================
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'

# Định vị thư mục
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(CURRENT_DIR)

input_folder = os.path.join(ROOT_DIR, "data_download", "dataops_project", "NHOM_A_SCAN")
output_jsonl = os.path.join(CURRENT_DIR, "extracted_group_A.jsonl")

def extract_text_via_ocr(file_path):
    """Thuật toán AI cắt ảnh và dịch chữ"""
    full_text = ""
    pages_data = []
    page_count = 0
    
    try:
        with fitz.open(file_path) as doc:
            page_count = len(doc)
            for page_num, page in enumerate(doc, 1):
                # 1. Zoom to gấp đôi (2.0) để AI nhìn nét hơn
                zoom = 2.0 
                mat = fitz.Matrix(zoom, zoom)
                pix = page.get_pixmap(matrix=mat, alpha=False)
                
                # 2. Đổi thành ảnh
                img = Image.open(io.BytesIO(pix.tobytes("png")))
                
                # 3. Ép AI đọc bằng Tiếng Việt
                # --psm 3: Tự động phân tích bố cục khối văn bản
                page_text = pytesseract.image_to_string(img, lang='vie', config='--psm 3')
                
                # Dọn dẹp khoảng trắng thừa
                page_text = " ".join(page_text.split())
                
                if page_text:
                    pages_data.append({
                        "page_number": page_num,
                        "text": page_text
                    })
                    full_text += page_text + "\n\n"
                
    except Exception as e:
        return None, None, 0, f"LỖI OCR: {str(e)}"
        
    return full_text.strip(), pages_data, page_count, "OK"

def run_ocr_extraction():
    if not os.path.exists(pytesseract.pytesseract.tesseract_cmd):
        print("❌ LỖI: Không tìm thấy Tesseract-OCR. Hãy chắc chắn bạn đã cài đặt vào ổ C!")
        return

    if not os.path.exists(input_folder):
        print(f"❌ LỖI: Không tìm thấy thư mục Nhóm A tại: {input_folder}")
        return

    all_files = [f for f in os.listdir(input_folder) if f.lower().endswith('.pdf')]

    # Cơ chế Resume (Ghi nhớ)
    processed_files = set()
    if os.path.exists(output_jsonl):
        with open(output_jsonl, 'r', encoding='utf-8') as f:
            for line in f:
                try:
                    data = json.loads(line)
                    processed_files.add(data["file_info"]["file_name"])
                except:
                    pass
        print(f"✅ Đã tìm thấy lịch sử: Bỏ qua {len(processed_files)} bài báo Scan đã làm.")

    pending_files = [f for f in all_files if f not in processed_files]
    
    if not pending_files:
        print("🎉 XUẤT SẮC! Bạn đã 'nhai' xong toàn bộ file xương xẩu Nhóm A!")
        return

    print(f"🚀 Bắt đầu dùng AI đọc {len(pending_files)} bài báo Scan...\n")
    print("⚠️ LƯU Ý SỐNG CÒN: AI OCR chạy RẤT CHẬM (vì phải đọc từng điểm ảnh).")
    print("👉 Hãy để máy chạy từ từ, có thể mất vài phút cho 1 file dài. TUYỆT ĐỐI KHÔNG BẤM CTRL+C!\n")
    
    with open(output_jsonl, 'a', encoding='utf-8') as out_f:
        pbar = tqdm(pending_files, desc="Đang OCR")
        
        for filename in pbar:
            file_path = os.path.join(input_folder, filename)
            
            # Chống lỗi font thanh tiến trình
            safe_name = filename.encode('ascii', 'ignore').decode('ascii')
            pbar.set_description(f"Đang AI-OCR: {safe_name[:15]}...")
            
            file_size_kb = int(os.path.getsize(file_path) / 1024)
            
            # Gọi hàm AI
            full_text, pages_data, page_count, status = extract_text_via_ocr(file_path)
            
            if status == "OK" and full_text:
                # Đúc vào MongoDB
                mongo_doc = build_mongo_document(
                    file_name=filename,
                    local_path=f"/NHOM_A_SCAN/{filename}",
                    processing_label="A_SCAN_OCR",
                    file_size_kb=file_size_kb,
                    page_count=page_count,
                    full_text=full_text,
                    pages_data=pages_data
                )
                
                out_f.write(json.dumps(mongo_doc, ensure_ascii=False) + "\n")
                out_f.flush()

    print("\n🎉 HOÀN TẤT BÓC CHỮ NHÓM A BẰNG AI!")
    print(f"👉 Dữ liệu chuẩn MongoDB đã sẵn sàng tại: {output_jsonl}")

if __name__ == "__main__":
    run_ocr_extraction()