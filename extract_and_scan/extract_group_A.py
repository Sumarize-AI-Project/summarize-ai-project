import sys
# BỌC THÉP UNICODE: Ép Terminal Windows không bao giờ bị lỗi font charmap nữa
sys.stdout.reconfigure(encoding='utf-8')

import os
import json
import fitz  # PyMuPDF
import pytesseract
from PIL import Image
import io
import re
from tqdm import tqdm

# Import khuôn đúc MongoDB
from schema_builder import build_mongo_document

print("="*60)
print("🤖 HỆ THỐNG KÍCH HOẠT: CỖ XE TĂNG AI OCR -> MARKDOWN (NHÓM A)")
print("="*60)

# ==========================================
# CẤU HÌNH TESSERACT
# ==========================================
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'

# Định vị thư mục
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(CURRENT_DIR)

input_folder = os.path.join(ROOT_DIR, "data_download", "dataops_project", "NHOM_A_SCAN")
output_jsonl = os.path.join(CURRENT_DIR, "extracted_group_A_MARKDOWN.jsonl") # Đổi tên file output cho đồng bộ

def clean_markdown_text(text):
    """Hàm dọn dẹp mượn từ Nhóm B, giữ nguyên ngắt dòng để bảo toàn cấu trúc đoạn văn."""
    if not text:
        return ""
    
    # Ép loại bỏ/thay thế các ký tự surrogate gây lỗi
    text = text.encode('utf-8', 'replace').decode('utf-8')
    
    # Sửa lỗi dãn chữ đặc thù của tiếng Việt
    text = re.sub(r'(đ|Đ)\s+([a-zàáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵ])', r'\1\2', text, flags=re.IGNORECASE)
    
    cleaned_lines = []
    for line in text.split('\n'):
        # Dọn khoảng trắng thừa nhưng bỏ qua các dòng kẻ bảng (nếu có vô tình OCR ra)
        if not re.match(r'^[\s\|-]+$', line): 
            line = re.sub(r'[ \t]+', ' ', line).strip()
        cleaned_lines.append(line)
        
    return '\n'.join(cleaned_lines)

def extract_text_via_ocr(file_path):
    """Thuật toán AI OCR xả ra format giống Markdown"""
    full_text = ""
    pages_data = []
    page_count = 0
    
    try:
        with fitz.open(file_path) as doc:
            page_count = len(doc)
            for page_num, page in enumerate(doc, 1):
                zoom = 2.0 
                mat = fitz.Matrix(zoom, zoom)
                pix = page.get_pixmap(matrix=mat, alpha=False)
                
                img = Image.open(io.BytesIO(pix.tobytes("png")))
                
                # --psm 3: Tự động phân tích bố cục, cố gắng giữ các khối văn bản
                raw_text = pytesseract.image_to_string(img, lang='vie', config='--psm 3')
                
                # Chạy qua máy giặt Markdown
                cleaned_md = clean_markdown_text(raw_text)
                
                if cleaned_md:
                    pages_data.append({
                        "page_number": page_num,
                        "text": cleaned_md
                    })
                    # Ghép text, phân cách trang bằng thẻ ngắt Markdown (---) y như Nhóm B
                    full_text += f"\n\n\n\n{cleaned_md}\n\n---\n\n"
                
    except Exception as e:
        return None, [], 0, f"LỖI OCR: {str(e)}"
        
    return full_text.strip(), pages_data, page_count, "OK"

def run_ocr_extraction():
    if not os.path.exists(pytesseract.pytesseract.tesseract_cmd):
        print("❌ LỖI: Không tìm thấy Tesseract-OCR. Hãy chắc chắn bạn đã cài đặt vào ổ C!")
        return

    if not os.path.exists(input_folder):
        print(f"❌ LỖI: Không tìm thấy thư mục Nhóm A tại: {input_folder}")
        return

    all_files = [f for f in os.listdir(input_folder) if f.lower().endswith('.pdf')]

    processed_files = set()
    if os.path.exists(output_jsonl):
        # THÊM errors='replace' ĐỂ CHỐNG SẬP KHI ĐỌC LỊCH SỬ
        with open(output_jsonl, 'r', encoding='utf-8', errors='replace') as f:
            for line in f:
                try:
                    data = json.loads(line)
                    processed_files.add(data["file_info"]["file_name"])
                except:
                    pass
        print(f"✅ Đã tìm thấy lịch sử: Bỏ qua {len(processed_files)} bài báo Scan đã OCR.")

    pending_files = [f for f in all_files if f not in processed_files]
    
    if not pending_files:
        print("🎉 XUẤT SẮC! Bạn đã 'nhai' xong toàn bộ file Nhóm A sang định dạng Markdown-like!")
        return

    print(f"🚀 Bắt đầu dùng AI đọc {len(pending_files)} bài báo Scan...\n")
    print("⚠️ LƯU Ý SỐNG CÒN: AI OCR chạy RẤT CHẬM (vì phải đọc từng điểm ảnh).")
    
    # THÊM errors='replace' ĐỂ CHỐNG SẬP KHI GHI FILE NHƯ ĐÃ FIX Ở NHÓM B
    with open(output_jsonl, 'a', encoding='utf-8', errors='replace') as out_f:
        pbar = tqdm(pending_files, desc="Đang OCR")
        
        for filename in pbar:
            file_path = os.path.join(input_folder, filename)
            
            safe_name = filename.encode('ascii', 'ignore').decode('ascii')
            pbar.set_description(f"Đang AI-OCR: {safe_name[:15]}...")
            
            file_size_kb = int(os.path.getsize(file_path) / 1024)
            
            full_text, pages_data, page_count, status = extract_text_via_ocr(file_path)
            
            if status == "OK" and full_text:
                mongo_doc = build_mongo_document(
                    file_name=filename,
                    local_path=f"/NHOM_A_SCAN/{filename}",
                    processing_label="A_SCAN_OCR_MARKDOWN", # Đổi label để dễ nhận diện
                    file_size_kb=file_size_kb,
                    page_count=page_count,
                    full_text=full_text
                )
                
                out_f.write(json.dumps(mongo_doc, ensure_ascii=False) + "\n")
                out_f.flush()

    print("\n🎉 HOÀN TẤT BÓC CHỮ NHÓM A!")
    print(f"👉 Dữ liệu chuẩn MongoDB đã sẵn sàng tại: {output_jsonl}")

if __name__ == "__main__":
    run_ocr_extraction()