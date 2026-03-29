import sys
# BỌC THÉP UNICODE: Ép Terminal Windows không bao giờ bị lỗi font charmap nữa
sys.stdout.reconfigure(encoding='utf-8') 

import os
import csv
import json
import fitz  # PyMuPDF
import pymupdf4llm  # <--- VŨ KHÍ MỚI: Chuyên bóc Markdown cho AI
from tqdm import tqdm
import re 

# Import khuôn đúc chuẩn MongoDB
from schema_builder import build_mongo_document

print("="*60)
print("🚀 HỆ THỐNG KÍCH HOẠT: CỖ MÁY BÓC MARKDOWN TỐC ĐỘ CAO (NHÓM B)")
print("="*60)

# 1. Định vị đường dẫn
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(CURRENT_DIR)

input_folder = os.path.join(ROOT_DIR, "data_download", "dataops_project", "NHOM_B_DIGITAL")
csv_map = os.path.join(ROOT_DIR, "preprocess_and_normalized", "classification_results_precision.csv")
output_jsonl = os.path.join(CURRENT_DIR, "extracted_group_B_MARKDOWN.jsonl")

def clean_markdown_text(text):
    """
    Hàm dọn dẹp ĐÃ ĐƯỢC THIẾT KẾ LẠI CHO MARKDOWN.
    TUYỆT ĐỐI KHÔNG XÓA DẤU XUỐNG DÒNG (\n) vì sẽ làm vỡ bảng biểu và tiêu đề.
    """
    if not text:
        return ""
    
    # 1. Chỉ sửa lỗi dãn chữ đặc thù của tiếng Việt (ví dụ: "đ ã" -> "đã")
    text = re.sub(r'(đ|Đ)\s+([a-zàáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵ])', r'\1\2', text, flags=re.IGNORECASE)
    
    # 2. Xóa các khoảng trắng thừa trên CÙNG MỘT DÒNG (không đụng tới \n)
    # Dùng list comprehension để xử lý từng dòng một cách an toàn
    cleaned_lines = []
    for line in text.split('\n'):
        # Dọn khoảng trắng thừa (spaces/tabs) nhưng bỏ qua các dòng kẻ bảng của Markdown (như |---|---|)
        if not re.match(r'^[\s\|-]+$', line): 
            line = re.sub(r'[ \t]+', ' ', line).strip()
        cleaned_lines.append(line)
        
    return '\n'.join(cleaned_lines)

def extract_markdown_content(file_path):
    """Hàm bóc Markdown sử dụng pymupdf4llm"""
    try:
        # Sử dụng pymupdf4llm cắt theo từng trang (page_chunks=True)
        # Nó sẽ tự động nhận diện bảng biểu, tiêu đề, và hình ảnh cơ bản
        page_chunks = pymupdf4llm.to_markdown(file_path, page_chunks=True)
        page_count = len(page_chunks)
        
        full_text = ""
        pages_data = []
        
        for chunk in page_chunks:
            # Lấy metadata trang
            page_num = chunk.get("metadata", {}).get("page", 0) + 1
            raw_md = chunk.get("text", "")
            
            # Đưa qua bàn ủi tiếng Việt nhẹ nhàng
            cleaned_md = clean_markdown_text(raw_md)
            
            if cleaned_md:
                pages_data.append({
                    "page_number": page_num,
                    "text": cleaned_md
                })
                # Gom vào cục text bự, phân cách các trang bằng thẻ Markdown Horizon Rule (---)
                full_text += f"\n\n\n\n" + cleaned_md + "\n\n---\n\n"
                
        return full_text.strip(), pages_data, page_count, "OK"
        
    except Exception as e:
        return None, [], 0, f"LỖI: {str(e)}"

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
        print(f"✅ Đã tìm thấy lịch sử: Bỏ qua {len(processed_files)} bài báo đã bóc Markdown.")

    pending_files = [item for item in files_to_process if item["filename"] not in processed_files]
    
    if not pending_files:
        print("🎉 Tuyệt vời! Bạn đã bóc xong 100% tài liệu Nhóm B sang Markdown!")
        return

    print(f"🚀 Bắt đầu đút {len(pending_files)} bài báo vào khuôn đúc MongoDB...\n")
    
    with open(output_jsonl, 'a', encoding='utf-8', errors='replace') as out_f:
        pbar = tqdm(pending_files, desc="Đang bóc Markdown")
        
        for item in pbar:
            filename = item["filename"]
            label = item["label"]
            file_path = os.path.join(input_folder, filename)
            
            safe_name = filename.encode('ascii', 'ignore').decode('ascii')
            pbar.set_description(f"Đang bóc: {safe_name[:20]}...")
            
            file_size_kb = int(os.path.getsize(file_path) / 1024) if os.path.exists(file_path) else 0
            
            # --- GỌI HÀM BÓC MARKDOWN MỚI TẠI ĐÂY ---
            full_text, pages_data, page_count, status = extract_markdown_content(file_path)
            
            if status == "OK" and full_text: 
                mongo_doc = build_mongo_document(
                    file_name=filename,
                    local_path=f"/NHOM_B_DIGITAL/{filename}",
                    processing_label=label,
                    file_size_kb=file_size_kb,
                    page_count=page_count,
                    full_text=full_text  # Bây giờ full_text đang chứa chuỗi Markdown xịn xò
                )
                
                out_f.write(json.dumps(mongo_doc, ensure_ascii=False) + "\n")
                out_f.flush()

    print("\n🎉 HOÀN TẤT BÓC MARKDOWN NHÓM B!")
    print(f"👉 Dữ liệu chuẩn MongoDB đã sẵn sàng tại: {output_jsonl}")

if __name__ == "__main__":
    run_extraction()