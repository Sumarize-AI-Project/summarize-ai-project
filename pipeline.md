# Data Mining Project Pipeline

Dựa vào cấu trúc thư mục hiện tại của dự án, quy trình (pipeline) của hệ thống đã được xây dựng qua 4 giai đoạn cụ thể như sau:

## 1. Giai đoạn 1: Phân công và Thu thập thủ công (Thư mục `collecting_data`)
- Bao gồm các thư mục theo tên các thành viên (Hung, TAI, Thanh, Tuan, Vinh).
- **Chức năng**: Có khả năng lưu trữ dữ liệu thu thập thủ công ban đầu hoặc tài liệu/kết quả cá nhân (liên hệ với file `phanchiacongviec.docx`).

## 2. Giai đoạn 2: Tự động hoá Tải và Quản lý Dữ liệu (Thư mục `data_download`)
Giai đoạn này tập trung vào việc tự động tải, theo dõi và lưu trữ nguồn dữ liệu thô.
- **Tải dữ liệu**: `downloader.py` và `main.py` đóng vai trò kéo dữ liệu từ các nguồn/API.
- **Kiểm soát & Giám sát**: `audit.py` dùng để audit chất lượng, `check_status.py` giám sát trạng thái hệ thống và tiến độ.
- **Kết xuất & Lưu trữ**: `database.py` tương tác với DB lưu thông tin, dữ liệu tích lũy được gom lại thành file như `merged_data.json`.
- **Xử lý lỗi**: Tồn tại luồng theo dõi các file cần làm sạch lưu trong `need_cleaning_files.csv`.

## 3. Giai đoạn 3: Trích xuất và Quét Dữ liệu nâng cao (Thư mục `extract_and_scan`)
Thực hiện trích xuất dữ liệu từ các nguồn thô thành dạng có cấu trúc rõ ràng (`jsonl`).
- **Xây dựng cấu trúc**: `schema_builder.py` dùng để định nghĩa lược đồ (schema) dữ liệu cần xuất.
- **Trình trích xuất chính**: Chia thành các chiến lược trích xuất qua `extract_group_A.py`, `extract_group_B.py` và luồng chạy chính `main_extractor.py`.
  - Kết quả được xuất ra các file dữ liệu khổng lồ: `extracted_group_A.jsonl` (65MB+) và `extracted_group_B.jsonl` (457MB+).
- **Xử lý chuyên sâu**: Sử dụng `refine_data.py` để tinh chỉnh sau khi rút trích dữ liệu và `xray_scanner.py` để quét và kiểm tra cấu trúc/nội dung chi tiết.

## 4. Giai đoạn 4: Tiền xử lý, Chuẩn hoá và Phân loại (Thư mục `preprocess_and_normalized`)
Sau khi trích xuất, dữ liệu được đưa vào mô hình tiền xử lý nhiều bước.
- **Khởi chạy tiền xử lý**: `main_preprocess.py`.
- **Phân loại mức vĩ mô (Macro Classify)**: `step2_macro_classify.py`, phân rã dữ liệu thành các nhóm chính.
- **Giải cứu/Khôi phục (Rescue)**: `step3_rescue.py` được thiết kế để xử lý dữ liệu sinh ra lỗi từ các vòng phân loại trước hoặc dữ liệu ngoại lai.
- **Phân loại mức vi mô (Micro Classify)**: `step4_micro_classify.py` thực hiện việc gom hoặc dãn nhãn dữ liệu ở cấp độ cực chi tiết.
- Kết quả được lưu tại `classification_results_precision.csv`.

---
**Tóm tắt:** Dự án đã có một pipeline tự động hoàn chỉnh, có thiết kế modular rất tốt, đi qua các bước từ tải liệu (Download) -> Trích xuất & Lọc (Extract & Scan) -> Phân loại và Tinh chế (Preprocess & Classification).
