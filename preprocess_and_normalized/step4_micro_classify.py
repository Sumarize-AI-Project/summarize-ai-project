print("⏳ Đang nạp hệ thống Bọc thép...")

import fitz  # PyMuPDF
import os
import csv
from tqdm import tqdm

fitz.TOOLS.mupdf_display_errors(False)

print(">>> HỆ THỐNG KÍCH HOẠT: TRUY TÌM B2 & GHI NHỚ LỊCH SỬ (RESUME) <<<")

# Định vị thư mục
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(CURRENT_DIR)
target_root = os.path.join(ROOT_DIR, "data_download", "dataops_project")

input_folder = os.path.join(target_root, 'NHOM_B_DIGITAL')
output_csv = os.path.join(CURRENT_DIR, 'classification_results_precision.csv')

def is_B2_precise(file_path):
    """Logic lõi đã được bọc try-except nhiều lớp để chống sập nguồn"""
    try:
        with fitz.open(file_path) as doc:
            for page in doc:
                page_area = page.rect.width * page.rect.height
                
                # BỌC THÉP 1: Bắt lỗi riêng phần dò Bảng biểu (Thủ phạm gây sập ở 90%)
                try:
                    if page.find_tables().tables:
                        return 'B2'
                except Exception:
                    pass # Nếu cái bảng bị lỗi cấu trúc, bỏ qua không dò bảng nữa, tránh treo máy

                # BỌC THÉP 2: Bắt lỗi phần dò Hình ảnh
                try:
                    for img in page.get_images(full=True):
                        xref = img[0]
                        for rect in page.get_image_rects(xref):
                            if (rect.width * rect.height) > (page_area * 0.02):
                                return 'B2'
                except Exception:
                    pass
                    
            return 'B1' # Vượt qua hết mà không có gì thì là B1
    except Exception:
        return 'ERROR' # File hỏng hoàn toàn không mở được

def run_micro_classification():
    if not os.path.exists(input_folder):
        print("❌ LỖI: Không tìm thấy thư mục NHOM_B_DIGITAL!")
        return

    all_files = [f for f in os.listdir(input_folder) if f.lower().endswith('.pdf')]
    
    # ---------------------------------------------------------
    # HỆ THỐNG GHI NHỚ LỊCH SỬ (Chỉ đọc file mới, bỏ qua file cũ)
    # ---------------------------------------------------------
    processed_files = set()
    if os.path.exists(output_csv):
        with open(output_csv, 'r', encoding='utf-8') as f:
            reader = csv.reader(f)
            next(reader, None) # Bỏ qua dòng tiêu đề
            for row in reader:
                if row and len(row) >= 2: # Đảm bảo dòng không bị trống
                    processed_files.add(row[0]) # Lưu tên file đã làm xong vào bộ nhớ
                    
        print(f"✅ ĐÃ NHỚ MẶT: Bỏ qua {len(processed_files)} file đã làm xong từ trước.")

    # Lọc ra danh sách CHỈ gồm những file chưa từng làm
    files_to_process = [f for f in all_files if f not in processed_files]
    
    if not files_to_process:
        print("🎉 Tuyệt vời! Bạn đã phân loại xong 100% dữ liệu!")
        return

    print(f"🚀 Tiếp tục xử lý {len(files_to_process)} file CÒN LẠI...")
    
    # Lấy lại thông số đếm cũ để thanh tiến trình hiển thị đúng số tổng
    stats = {'B1': 0, 'B2': 0, 'ERROR': 0}

    with open(output_csv, 'a', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        if not processed_files:
            writer.writerow(['file_name', 'label']) # Chỉ ghi tiêu đề nếu là file mới hoàn toàn

        pbar = tqdm(files_to_process, desc="Đang phân tích")
        for filename in pbar:
            file_path = os.path.join(input_folder, filename)
            
            # Gắn nhãn file
            label = is_B2_precise(file_path)
            stats[label] += 1
            
            # Ghi ngay vào CSV và chốt ổ cứng (flush) để lỡ cúp điện cũng không mất
            writer.writerow([filename, label])
            f.flush()

            # Hiển thị tiến trình
            pbar.set_postfix({'B1 mới': stats['B1'], 'B2 mới': stats['B2'], 'Lỗi': stats['ERROR']})

    print(f"\n🎉 HOÀN THÀNH PHÂN LOẠI TINH 100% DỮ LIỆU!")

if __name__ == "__main__":
    run_micro_classification()