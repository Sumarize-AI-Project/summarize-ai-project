import fitz  # PyMuPDF
import os
import shutil
from tqdm import tqdm

print(">>> HỆ THỐNG KÍCH HOẠT: BỘ GIẢI CỨU DỮ LIỆU (DATA RESCUE) <<<")

# Định vị thư mục
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(CURRENT_DIR)
target_root = os.path.join(ROOT_DIR, "data_download", "dataops_project")

folder_a = os.path.join(target_root, 'NHOM_A_SCAN')
folder_b = os.path.join(target_root, 'NHOM_B_DIGITAL')

def verify_and_rescue(file_path):
    """
    Kiểm tra đa điểm: Trang đầu, giữa, cuối.
    Nếu thấy chữ (>50 ký tự) -> Trả về True (Nghi vấn là file Digital bị nhận nhầm)
    """
    try:
        with fitz.open(file_path) as doc:
            num_pages = len(doc)
            if num_pages == 0:
                return False
                
            # Chọn các trang mẫu để test (Đầu, Giữa, Cuối)
            indices = [0, num_pages // 2, num_pages - 1]
            
            # Đảm bảo không bị trùng trang nếu file quá ngắn (ví dụ file có 1-2 trang)
            indices = list(set(indices))

            for i in indices:
                page = doc[i]
                text = page.get_text("text") or ""
                
                # Ngưỡng 50 ký tự cho 1 trang là khá an toàn để khẳng định có text layer
                if len(text.strip()) > 50:
                    return True
            return False
    except Exception:
        return False

def run_rescue():
    if not os.path.exists(folder_a):
        print("❌ Không tìm thấy thư mục NHOM_A_SCAN!")
        return

    files_in_a = [f for f in os.listdir(folder_a) if f.lower().endswith('.pdf')]
    print(f"🚀 Đang kiểm tra lại {len(files_in_a)} file trong Nhóm A (Scan)...")

    moved_count = 0
    for filename in tqdm(files_in_a, desc="Đang quét giải cứu"):
        file_path = os.path.join(folder_a, filename)

        if verify_and_rescue(file_path):
            # Cầm file đó ném thẳng về lại Nhóm B (Digital)
            shutil.move(file_path, os.path.join(folder_b, filename))
            moved_count += 1

    print(f"\n✅ KIỂM TRA HOÀN TẤT!")
    print(f"🚑 Số file bị oan được 'giải cứu' sang Nhóm B (Digital): {moved_count} file")
    print(f"🔒 Số file Scan thực sự còn lại trong Nhóm A: {len(files_in_a) - moved_count} file")

if __name__ == "__main__":
    run_rescue()