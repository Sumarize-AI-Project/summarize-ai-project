import sqlite3
from pathlib import Path
from tqdm.asyncio import tqdm
from audit import audit_downloaded_data
from check_status import audit_pdf_dataset

import asyncio
from database import init_tracker, sync_existing_files
from downloader import run_data_collection

if __name__ == "__main__":
    init_tracker()
    sync_existing_files()
    # 1.2 Chạy tải
    try:
        asyncio.run(run_data_collection())
        audit_downloaded_data()
        # Thực thi
        data_path = "dataops_project/pdf_raw"
        df_audit = audit_pdf_dataset(data_path)

        # --- PHÂN TÍCH KẾT QUẢ ---
        print("\n📊 --- THỐNG KÊ TÌNH TRẠNG FILE ---")
        print(df_audit["status"].value_counts())

        print("\n🔍 --- PHÂN LOẠI PDF (Cần thiết cho Giai đoạn 2) ---")
        print(df_audit[df_audit["status"] == "OK"]["type"].value_counts())

        # Xuất danh sách các file lỗi để xử lý thủ công hoặc xóa
        error_files = df_audit[df_audit["status"] != "OK"]
        if not error_files.empty:
            error_files.to_csv("need_cleaning_files.csv", index=False)
            print(f"\n❌ Đã tìm thấy {len(error_files)} file lỗi. Chi tiết tại 'need_cleaning_files.csv'")
        # Lưu toàn bộ metadata để Giai đoạn 2 dùng
        df_audit.to_csv("dataops_project/audited_dataset.csv", index=False)
        print("\n✅ Đã lưu file tổng 'audited_dataset.csv' để chuyển sang Giai đoạn 2.")
    except KeyboardInterrupt:
        print("\n🛑 Đã dừng tiến trình bởi người dùng.")