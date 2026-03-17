import os
import json
import google.generativeai as genai
from tqdm import tqdm
import time

# ==========================================
# CẤU HÌNH HỆ THỐNG
# ==========================================
GEMINI_API_KEY = "AIzaSyBWcVHgEA1jct4tNZq72yz_R56EBoOZfa4" 
genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel('gemini-1.5-flash')

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
INPUT_FILE = os.path.join(CURRENT_DIR, "extracted_group_A.jsonl")
OUTPUT_FILE = os.path.join(CURRENT_DIR, "refined_group_A.jsonl")

def ask_ai_to_refine(text_preview):
    """Gửi dữ liệu thô cho AI để tinh lọc metadata và tóm tắt"""
    prompt = f"""
    Bạn là một trợ lý khoa học chuyên nghiệp. Tôi sẽ cung cấp dữ liệu thô từ OCR của một bài báo. 
    Nhiệm vụ của bạn:
    1. Nhặt ra Tên các tác giả (Authors).
    2. Nhặt ra Đơn vị công tác (Affiliation).
    3. Tìm Tóm tắt (Abstract) có sẵn trong bài. Nếu bài KHÔNG CÓ tóm tắt, hãy viết 1 đoạn tóm tắt khoảng 150 chữ dựa trên nội dung.
    4. Trả về kết quả CHỈ DUY NHẤT ở định dạng JSON như sau:
    {{
        "authors": ["Tên 1", "Tên 2"],
        "affiliation": "Tên cơ quan",
        "abstract": "Nội dung tóm tắt..."
    }}

    DỮ LIỆU THÔ:
    {text_preview}
    """
    try:
        response = model.generate_content(prompt)
        # Làm sạch chuỗi trả về để ép kiểu JSON
        json_str = response.text.replace('```json', '').replace('```', '').strip()
        return json.loads(json_str)
    except Exception as e:
        print(f"Lỗi AI: {e}")
        return None

def start_refining():
    if not os.path.exists(INPUT_FILE):
        print("❌ Chưa thấy file extracted_group_A.jsonl. Chờ OCR chạy xong đã sếp ơi!")
        return

    print("💎 BẮT ĐẦU QUÁ TRÌNH TINH LỌC DỮ LIỆU BẰNG AI...")
    
    with open(INPUT_FILE, 'r', encoding='utf-8') as f_in, \
         open(OUTPUT_FILE, 'w', encoding='utf-8') as f_out:
        
        lines = f_in.readlines()
        for line in tqdm(lines, desc="Tinh lọc"):
            data = json.loads(line)
            
            # Chỉ lấy 1500 chữ đầu và 1500 chữ cuối để tiết kiệm API và chính xác hơn
            full_content = data['content']['full_text']
            preview = full_content[:1500] + "\n[...]\n" + full_content[-1500:]
            
            # Gọi AI xử lý
            refined = ask_ai_to_refine(preview)
            
            if refined:
                # Cập nhật vào Schematic chuẩn của sếp
                data['metadata']['authors'] = refined.get('authors', [])
                data['metadata']['publisher'] = refined.get('affiliation', "")
                data['content']['ai_summary'] = refined.get('abstract', "")
                data['nlp_data']['extracted_text'] = True
                data['system']['status'] = "refined"
            
            f_out.write(json.dumps(data, ensure_ascii=False) + "\n")
            time.sleep(4) # Tránh bị giới hạn tốc độ API (Rate limit)

    print(f"🎉 XONG! Dữ liệu tinh khiết đã nằm tại: {OUTPUT_FILE}")

if __name__ == "__main__":
    start_refining()