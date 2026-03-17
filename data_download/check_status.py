import os
import fitz  # PyMuPDF
import pandas as pd
from tqdm import tqdm
from pathlib import Path

def audit_pdf_dataset(root_path):
    report = []
    root_dir = Path(root_path)

    # Lấy danh sách tất cả các thư mục con
    subdirs = [d for d in root_dir.iterdir() if d.is_dir()]

    print(f"🚀 Bắt đầu kiểm tra dữ liệu tại: {root_path}")

    for subdir in subdirs:
        files = list(subdir.glob("*.pdf"))

        # 1. Kiểm tra folder trống
        if not files:
            print(f"⚠️ Cảnh báo: Thư mục {subdir.name} trống. Nên loại bỏ khỏi Pipeline.")
            continue

        for pdf_path in tqdm(files, desc=f"Processing {subdir.name}", unit="file"):
            file_stats = os.stat(pdf_path)
            file_size_kb = file_stats.st_size / 1024

            status = "OK"
            pdf_type = "Unknown"
            page_count = 0
            text_sample = ""

            # 2. Kiểm tra dung lượng quá thấp (< 10KB)
            if file_size_kb < 10:
                status = "ERROR: Too Small (Corrupted/Empty)"
            else:
                try:
                    # Mở file kiểm tra nội dung
                    with fitz.open(pdf_path) as doc:
                        page_count = len(doc)
                        if page_count == 0:
                            status = "ERROR: No Pages"
                        else:
                            # 3. Nhận diện PDF dạng ảnh (OCR) hay Text-based
                            # Lấy text trang đầu tiên để kiểm tra
                            page = doc[0]
                            text_sample = page.get_text().strip()

                            # Nếu số lượng ký tự quá ít so với diện tích trang -> Khả năng là ảnh
                            if len(text_sample) < 100:
                                pdf_type = "Image-based (Needs OCR)"
                            else:
                                pdf_type = "Text-based"

                except Exception as e:
                    status = f"ERROR: Cannot open ({str(e)})"

            report.append({
                "folder": subdir.name,
                "filename": pdf_path.name,
                "size_kb": round(file_size_kb, 2),
                "pages": page_count,
                "type": pdf_type,
                "status": status
            })

    return pd.DataFrame(report)


