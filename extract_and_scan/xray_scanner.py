import sys
sys.stdout.reconfigure(encoding='utf-8')

import os
import json
import shutil
from tqdm import tqdm

print("="*60)
print("🩺 HỆ THỐNG KÍCH HOẠT: MÁY QUÉT X-QUANG V2 (ĐỘ NHẠY CAO)")
print("="*60)

# Định vị đường dẫn
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(CURRENT_DIR)

jsonl_file = os.path.join(CURRENT_DIR, "extracted_group_B.jsonl")
nhom_b_dir = os.path.join(ROOT_DIR, "data_download", "dataops_project", "NHOM_B_DIGITAL")
nhom_a_dir = os.path.join(ROOT_DIR, "data_download", "dataops_project", "NHOM_A_SCAN")

def is_corrupted(text):
    """Thuật toán V2 quét tỷ lệ phần trăm (%) chữ có dấu"""
    if not text or len(text) < 100:
        return True # Quá ngắn cũng vứt sang OCR cho AI đọc lại cho chắc
        
    # BỆNH 1: Bảng mã TCVN3/VNI cũ bóc ra bị lỗi (Ö, µ, ¶, häc...)
    garbage_chars = "Öµ¶·¹©ª«¬®¾¿×ØÜÞßæç÷øöñ"
    if sum(1 for c in text if c in garbage_chars) > 20:
        return True
        
    # BỆNH 2: Hỏng Map Font (như kiểu: "cudc cai each", "iQde")
    vn_vowels = "àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ"
    vn_vowel_count = sum(1 for c in text.lower() if c in vn_vowels)
    
    # Tính tỷ lệ dấu / tổng số chữ
    ratio = vn_vowel_count / len(text)
    
    # Nếu tỷ lệ dấu TV nhỏ hơn 1.5% tổng số ký tự
    if ratio < 0.015:
        # Kiểm tra xem có phải là bài báo 100% Tiếng Anh xịn không
        eng_words = [' the ', ' and ', ' of ', ' to ', ' in ', ' is ', ' that ']
        text_lower = text.lower()
        eng_word_count = sum(text_lower.count(w) for w in eng_words)
        
        # Nếu số từ tiếng Anh đếm được ít hơn 0.5% tổng số chữ -> Đích thị hàng giả!
        if eng_word_count < (len(text) / 200):
            return True
            
    return False

def run_scanner():
    if not os.path.exists(jsonl_file):
        print(f"❌ Không tìm thấy file dữ liệu: {jsonl_file}")
        return

    os.makedirs(nhom_a_dir, exist_ok=True)

    print("🔍 Đang tải dữ liệu từ Nhóm B lên bàn mổ (Vui lòng chờ 15s)...")
    good_docs = []
    bad_files_count = 0
    
    with open(jsonl_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    for line in tqdm(lines, desc="Đang quét X-Quang V2"):
        try:
            doc = json.loads(line)
            text = doc["content"]["full_text"]
            filename = doc["file_info"]["file_name"]
            
            # Khám bệnh
            if is_corrupted(text):
                bad_files_count += 1
                src_path = os.path.join(nhom_b_dir, filename)
                dst_path = os.path.join(nhom_a_dir, filename)
                if os.path.exists(src_path):
                    shutil.move(src_path, dst_path)
            else:
                good_docs.append(line)
        except Exception as e:
            continue

    print(f"\n💉 Đang phẫu thuật cắt bỏ {bad_files_count} bài báo lỗi khỏi Nhóm B...")
    with open(jsonl_file, 'w', encoding='utf-8') as f:
        for doc in good_docs:
            f.write(doc)

    print("\n" + "="*60)
    print("🎉 KẾT QUẢ KHÁM BỆNH V2:")
    print(f"✅ Đã giữ lại: {len(good_docs)} bài báo SẠCH 100%.")
    print(f"☣️ Đã phát hiện và ném {bad_files_count} bài 'hàng giả' sang Nhóm A (Scan).")
    print("="*60)

if __name__ == "__main__":
    run_scanner()