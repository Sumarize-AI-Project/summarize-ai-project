import sys
# BỌC THÉP UNICODE: Ép Terminal Windows không bao giờ bị lỗi font charmap nữa
sys.stdout.reconfigure(encoding='utf-8') 

import os
import csv
import json
import fitz  # PyMuPDF
from tqdm import tqdm
import re    # <--- THÊM THƯ VIỆN "BÀN ỦI" ĐỂ LÀM PHẲNG CHỮ

# Import cái khuôn đúc siêu xịn mà bạn vừa tạo
from schema_builder import build_mongo_document

print("="*60)
print("🚀 HỆ THỐNG KÍCH HOẠT: CỖ MÁY BÓC CHỮ TỐC ĐỘ CAO (NHÓM B) - BẢN ĐÃ FIX FONT")
print("="*60)

# 1. Định vị đường dẫn (Liên kết các thư mục với nhau)
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(CURRENT_DIR)

input_folder = os.path.join(ROOT_DIR, "data_download", "dataops_project", "NHOM_B_DIGITAL")
csv_map = os.path.join(ROOT_DIR, "preprocess_and_normalized", "classification_results_precision.csv")

# Kết quả sẽ lưu vào file JSONL này
output_jsonl = os.path.join(CURRENT_DIR, "extracted_group_B.jsonl")

def clean_text(text):
    """Hàm dọn dẹp các lỗi xuống dòng và dãn chữ của PDF"""
    if not text:
        return ""
    
    # 1. Thay thế tất cả các dấu xuống dòng (\n) bằng một khoảng trắng
    text = text.replace('\n', ' ')
    
    # 2. Sửa lỗi dãn chữ đặc thù của tiếng Việt (ví dụ: "đ ã" -> "đã", "đ iểm" -> "điểm")
    text = re.sub(r'(đ|Đ)\s+([a-zàáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵ])', r'\1\2', text, flags=re.IGNORECASE)
    
    # 3. Gom nhiều khoảng trắng liên tiếp thành 1 khoảng trắng duy nhất
    text = re.sub(r'\s+', ' ', text)
    
    return text.strip()

def extract_pdf_content(file_path, label):
    """Hàm bóc chữ thông minh dựa trên nhãn B1 hay B2"""
    full_text = ""
    pages_data = []
    page_count = 0
    
    try:
        with fitz.open(file_path) as doc:
            page_count = len(doc)
            for page_num, page in enumerate(doc, 1):
                page_text = ""
                
                if label == 'B1':
                    page_text = page.get_text("text")
                else:
                    blocks = page.get_text("blocks")
                    blocks.sort(key=lambda b: (b[1], b[0])) 
                    for b in blocks:
                        if b[6] == 0: 
                            page_text += b[4] + " "
                            
                # --- ĐƯA CHỮ QUA BÀN ỦI Ở ĐÂY ---
                page_text = clean_text(page_text)
                
                if page_text:
                    # Cất nội dung vào từng trang
                    pages_data.append({
                        "page_number": page_num,
                        "text": page_text
                    })
                    # Gom vào cục text bự (Các trang cách nhau 2 lần xuống dòng)
                    full_text += page_text + "\n\n"
                
    except Exception as e:
        return None, None, 0, f"LỖI: {str(e)}"
        
    return full_text.strip(), pages_data, page_count, "OK"

def run_extraction():
    if not os.path.exists(csv_map):
        print(f"❌ LỖI: Không tìm thấy bản đồ CSV tại: {csv_map}")
        return

    files_to_process = []
    with open(csv_map, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        next(reader, None)
        for row in reader:
            if len(row) >= 2 and row[1] in ['B1', 'B2']:
                files_to_process.append({"filename": row[0], "label": row[1]})

    processed_files = set()
    if os.path.exists(output_jsonl):
        with open(output_jsonl, 'r', encoding='utf-8') as f:
            for line in f:
                try:
                    data = json.loads(line)
                    processed_files.add(data["file_info"]["file_name"])
                except:
                    pass
        print(f"✅ Đã tìm thấy lịch sử: Bỏ qua {len(processed_files)} bài báo đã bóc chữ.")

    pending_files = [item for item in files_to_process if item["filename"] not in processed_files]
    
    if not pending_files:
        print("🎉 Tuyệt vời! Bạn đã bóc xong 100% tài liệu Nhóm B!")
        return

    print(f"🚀 Bắt đầu đút {len(pending_files)} bài báo vào khuôn đúc MongoDB...\n")
    
    with open(output_jsonl, 'a', encoding='utf-8') as out_f:
        pbar = tqdm(pending_files, desc="Đang bóc chữ")
        
        for item in pbar:
            filename = item["filename"]
            label = item["label"]
            file_path = os.path.join(input_folder, filename)
            
            safe_name = filename.encode('ascii', 'ignore').decode('ascii')
            pbar.set_description(f"Đang bóc: {safe_name[:20]}...")
            
            file_size_kb = int(os.path.getsize(file_path) / 1024) if os.path.exists(file_path) else 0
            
            full_text, pages_data, page_count, status = extract_pdf_content(file_path, label)
            
            if status == "OK" and full_text: 
                mongo_doc = build_mongo_document(
                    file_name=filename,
                    local_path=f"/NHOM_B_DIGITAL/{filename}",
                    processing_label=label,
                    file_size_kb=file_size_kb,
                    page_count=page_count,
                    full_text=full_text,
                    pages_data=pages_data
                )
                
                out_f.write(json.dumps(mongo_doc, ensure_ascii=False) + "\n")
                out_f.flush()

    print("\n🎉 HOÀN TẤT BÓC CHỮ NHÓM B!")
    print(f"👉 Dữ liệu chuẩn MongoDB đã sẵn sàng tại: {output_jsonl}")

if __name__ == "__main__":
    run_extraction()