import os
import subprocess
import time
import sys

# Lấy đường dẫn tuyệt đối của thư mục extract_and_scan
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))

def run_script(script_name, description):
    """Hàm gọi và chạy các script Python con"""
    script_path = os.path.join(CURRENT_DIR, script_name)
    
    print(f"\n{'='*70}")
    print(f"🚀 BƯỚC: {description}")
    print(f"📂 Đang thực thi: {script_name}")
    print(f"{'='*70}\n")
    
    start_time = time.time()
    
    try:
        # sys.executable đảm bảo nó dùng đúng Python trong môi trường ảo (.venv)
        subprocess.run([sys.executable, script_path], check=True)
        elapsed = time.time() - start_time
        print(f"\n✅ HOÀN THÀNH: {script_name} (Thời gian: {elapsed:.2f} giây)")
        return True
    except subprocess.CalledProcessError as e:
        print(f"\n❌ LỖI NGHIÊM TRỌNG: File {script_name} bị dừng đột ngột!")
        print(f"Mã lỗi (Return code): {e.returncode}")
        return False
    except FileNotFoundError:
        print(f"\n❌ KHÔNG TÌM THẤY FILE: {script_name}. Sếp kiểm tra lại tên file nhé!")
        return False

def merge_final_data():
    """Gộp tất cả dữ liệu đã bóc thành 1 file Master duy nhất"""
    print(f"\n{'='*70}")
    print("🔗 BƯỚC CUỐI: Gộp dữ liệu thành Master File (Sẵn sàng cho MongoDB)")
    print(f"{'='*70}\n")
    
    file_b = os.path.join(CURRENT_DIR, "extracted_group_B.jsonl")
    file_a_refined = os.path.join(CURRENT_DIR, "refined_group_A.jsonl")
    file_a_raw = os.path.join(CURRENT_DIR, "extracted_group_A.jsonl")
    master_file = os.path.join(CURRENT_DIR, "final_master_data.jsonl")

    count = 0
    with open(master_file, 'w', encoding='utf-8') as f_out:
        # 1. Gộp Nhóm B (Digital)
        if os.path.exists(file_b):
            print("Đang gộp dữ liệu Nhóm B...")
            with open(file_b, 'r', encoding='utf-8') as fb:
                for line in fb:
                    f_out.write(line)
                    count += 1
        
        # 2. Gộp Nhóm A (Ưu tiên bản đã qua Gemini tinh lọc, nếu chưa có thì lấy bản Raw)
        if os.path.exists(file_a_refined):
            print("Đang gộp dữ liệu Nhóm A (Bản đã tinh lọc qua AI)...")
            with open(file_a_refined, 'r', encoding='utf-8') as fa:
                for line in fa:
                    f_out.write(line)
                    count += 1
        elif os.path.exists(file_a_raw):
            print("⚠️ Chưa có bản tinh lọc Nhóm A. Đang gộp dữ liệu thô (Raw OCR)...")
            with open(file_a_raw, 'r', encoding='utf-8') as fa:
                for line in fa:
                    f_out.write(line)
                    count += 1
                    
    print(f"\n🎉 XUẤT SẮC! Đã gộp thành công tổng cộng {count} bài báo.")
    print(f"💎 Kho báu của sếp nằm tại: {master_file}")

def main():
    print("\n🌟 BỘ TỔNG CHỈ HUY HỆ THỐNG TRÍCH XUẤT DỮ LIỆU (DATA MINING) 🌟")
    
    # Bước 1: Quét X-Quang (Đẩy file Scan lỗi từ Nhóm B sang Nhóm A)
    if not run_script("xray_scanner.py", "Quét X-Quang: Lọc PDF ảnh trà trộn trong Nhóm B"):
        return
    
    # Bước 2: Quét Nhóm B (Chỉ còn lại Digital xịn, chạy rất nhanh bằng PyMuPDF)
    if not run_script("extract_group_B.py", "Trích xuất hàng loạt Nhóm B (Digital PDF chuẩn)"):
        return
        
    # Bước 3: Quét Nhóm A (OCR chậm. Đã nhận thêm các file từ bước X-Quang chuyển sang)
    if not run_script("extract_group_A.py", "Trích xuất Nhóm A bằng Tesseract OCR (Scan/Lỗi Font)"):
        return
        
    # Tinh lọc dữ liệu (Hùng xử lí , chỉnh lại file refine_data)

if __name__ == "__main__":
    main()