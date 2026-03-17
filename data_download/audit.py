import os
from pathlib import Path
import pandas as pd

def audit_downloaded_data(root_path="dataops_project/pdf_raw"):
    root = Path(root_path)
    if not root.exists():
        return "❌ Thư mục gốc không tồn tại. Hãy kiểm tra lại đường dẫn!"

    stats = []
    print(f"🧐 Đang kiểm tra dữ liệu tại: {root.absolute()}\n")

    # Lấy danh sách tất cả các folder con
    folders = sorted([f for f in root.iterdir() if f.is_dir()])

    for folder in folders:
        pdf_files = list(folder.glob("*.pdf"))
        count = len(pdf_files)

        # Tính dung lượng trung bình để phát hiện file lỗi (thường < 10KB là file hỏng)
        if count > 0:
            avg_size_kb = sum(f.stat().st_size for f in pdf_files) / (count * 1024)
            sample_files = [f.name for f in pdf_files[:2]]
        else:
            avg_size_kb = 0
            sample_files = []

        stats.append({
            "Folder (Nhóm)": folder.name,
            "Số lượng PDF": count,
            "Size TB (KB)": round(avg_size_kb, 2),
            "Mẫu file": ", ".join(sample_files)
        })

    # Hiển thị bảng thống kê
    df = pd.DataFrame(stats)
    total_pdf = df["Số lượng PDF"].sum()

    # Tạo một dòng dữ liệu mới chứa tổng
    total_row = pd.DataFrame([{
        "Folder (Nhóm)": "⭐ TỔNG CỘNG",
        "Số lượng PDF": total_pdf,
        "Size TB (KB)": "-",     # Bỏ trống phần dung lượng TB cho dòng tổng
        "Mẫu file": "-"          # Bỏ trống mẫu file
    }])

    df_with_total = pd.concat([df, total_row], ignore_index=True)
    print(df_with_total.to_markdown(index=False))
    df_with_total.to_csv("bao_cao_nghiem_thu.csv", index=False, encoding="utf-8-sig")

    # Cập nhật lại total_pdf (dù ở trên đã tính rồi nhưng cứ giữ nguyên theo ý bạn)
    total_pdf = df["Số lượng PDF"].sum()
    print(f"\n📊 Tổng kết: {total_pdf} file đã sẵn sàng cho Giai đoạn 2 (Extraction).")

    # Cảnh báo nếu có folder trống hoặc file quá nhẹ
    small_files_warning = df[df["Size TB (KB)"] < 20]
    if not small_files_warning.empty:
        print(f"⚠️ Cảnh báo: Có {len(small_files_warning)} folder chứa file dung lượng rất thấp, có thể bị lỗi tải về!")

    return df

# Chạy lệnh khám phá
df_audit = audit_downloaded_data()