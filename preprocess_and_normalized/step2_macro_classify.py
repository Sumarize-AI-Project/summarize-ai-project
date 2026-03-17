import fitz  # Thay thế pdfplumber bằng siêu xe PyMuPDF
import os
import shutil
from tqdm import tqdm

print(">>> HỆ THỐNG KÍCH HOẠT: BỘ PHÂN LOẠI MACRO CLASSIFICATION (BẢN TỐC ĐỘ CAO) <<<")

# Định vị tự động các thư mục
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(CURRENT_DIR)

# Thư mục gốc chứa dữ liệu vừa tải
target_root = os.path.join(ROOT_DIR, "data_download", "dataops_project")
root_path = os.path.join(target_root, "pdf_raw")

# Tạo 2 thư mục đích (Nhóm A và Nhóm B)
path_a = os.path.join(target_root, 'NHOM_A_SCAN')
path_b = os.path.join(target_root, 'NHOM_B_DIGITAL')

os.makedirs(path_a, exist_ok=True)
os.makedirs(path_b, exist_ok=True)

def classify_pdf(file_path):
    """
    Hàm soi 1 trang đầu của PDF bằng PyMuPDF. 
    Tốc độ x100 lần, không bị treo máy khi gặp file lỗi.
    """
    try:
        with fitz.open(file_path) as doc:
            # File rỗng hoặc không có trang nào
            if len(doc) == 0:
                return 'ERROR'
                
            page = doc[0] # Lấy trang 1
            text = page.get_text("text")

            # Nếu trang 1 trống rỗng hoặc < 50 chữ -> Đưa vào nhóm Scan (Nhóm A)
            if not text or len(text.strip()) < 50:
                return 'A'
            return 'B' # Còn lại là file Digital
    except Exception:
        return 'ERROR'

def run_classification():
    print("🚀 Bắt đầu quét và phân loại file PDF...")
    stats = {'A': 0, 'B': 0, 'ERROR': 0}

    # 1. Thu thập danh sách toàn bộ file PDF
    all_pdf_files = []
    for dirpath, _, filenames in os.walk(root_path):
        for f in filenames:
            if f.lower().endswith('.pdf'):
                all_pdf_files.append(os.path.join(dirpath, f))

    if not all_pdf_files:
        print("❌ Lỗi: Không tìm thấy file PDF nào trong thư mục pdf_raw! (Có thể file đã bị cắt đi chỗ khác ở lần chạy trước)")
        return

    # 2. Chạy vòng lặp phân loại
    for file_path in tqdm(all_pdf_files, desc="Đang phân loại"):
        filename = os.path.basename(file_path)
        result = classify_pdf(file_path)
        stats[result] += 1

        # 3. Di chuyển file vào đúng nhà của nó
        if result != 'ERROR':
            dest_folder = path_a if result == 'A' else path_b
            shutil.move(file_path, os.path.join(dest_folder, filename))

    print(f"\n🎉 HOÀN THÀNH PHÂN LOẠI!")
    print(f"📁 Nhóm A (Scan - Cần mang đi AI OCR): {stats['A']} file")
    print(f"📁 Nhóm B (Digital - Bóc chữ trực tiếp): {stats['B']} file")
    print(f"❌ Lỗi (File bị hỏng/Không mở được): {stats['ERROR']} file")

if __name__ == "__main__":
    run_classification()