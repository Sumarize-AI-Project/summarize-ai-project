# ĐỀ CƯƠNG BÁO CÁO DỰ ÁN: AI TÓM TẮT BÀI BÁO KHOA HỌC TIẾNG VIỆT (GIAI ĐOẠN XỬ LÝ DỮ LIỆU)

## LỜI MỞ ĐẦU
- Giới thiệu chung về bài toán tóm tắt văn bản tiếng Việt, đặc biệt là với độ phức tạp của tài liệu khoa học định dạng PDF.
- Mục tiêu dài hạn của toàn bộ dự án: Khai sinh ra một mô hình AI có khả năng tự động đọc hiểu và tóm tắt bài báo khoa học tiếng Việt.

## CHƯƠNG 1: TỔNG QUAN VÀ XÁC ĐỊNH YÊU CẦU HỆ THỐNG
**1.1. Mục tiêu và phạm vi dự án**
- **Mục tiêu tổng quát (Grand Vision):** Xây dựng một hệ thống AI tóm tắt bài báo PDF tiếng Việt.
- **Phạm vi hiện tại của báo cáo (Current Scope):** Chặng đường đầu tiên và gian nan nhất để tạo ra AI là có dữ liệu mớm cho nó. Báo cáo này tập trung vào việc **Xây dựng Data Pipeline (Đường ống xử lý dữ liệu)**. Pipeline này tự động thu thập, trích xuất text từ các file PDF tiếng Việt phức tạp, làm sạch, đóng gói thành `.jsonl` và lưu trên MongoDB để tạo lập **Bộ dữ liệu (Dataset)** chất lượng cao.

**1.2. Yêu cầu hệ thống**
- **Yêu cầu chức năng của Pipeline dữ liệu (Giai đoạn hiện tại):**
  + Tự động tải tài liệu PDF tiếng Việt.
  + Trích xuất văn bản từ PDF (giải quyết lỗi font chữ tiếng Việt, loại bỏ bớt bảng biểu/hình ảnh rác).
  + Tiền xử lý (làm sạch nhiễu, chuẩn hóa text tiếng Việt).
  + Lưu mỗi văn bản thành một record trên từng dòng của file `.jsonl` (chuẩn công nghiệp để đưa vào mô hình AI).
  + Quản lý luồng Dataset tập trung thông qua cơ sở dữ liệu MongoDB.
- **Yêu cầu chức năng của mô hình AI (Giai đoạn tương lai):**
  + Nạp PDF đầu vào, đẩy vào mô hình ngôn ngữ (NLP Model), trả về câu văn tóm tắt.

**1.3. Biểu đồ Use Case**
- **Actor:** Người dùng (Người tra cứu), Kĩ sư dữ liệu (Hành động của nhóm bạn), Hệ thống AI.
- **Use Case Giai đoạn 1 (Của nhóm bạn):** Chạy lệnh Download -> Chạy lệnh Extract PDF -> Chạy lệnh Clean/Normalize -> Cấu trúc sang JSONL -> Import MongoDB.
- **Use Case Giai đoạn 2 (Tương lai cho User):** Upload file PDF -> Hệ thống Trích xuất text -> AI Summarizer chạy -> Trả về bản tóm tắt hiển thị lên màn hình.

## CHƯƠNG 2: PHÂN TÍCH VÀ THIẾT KẾ KIẾN TRÚC HỆ THỐNG
**2.1. Cấu trúc hệ thống tổng thể (System Architecture)**
Hệ thống được chia thành 2 phân hệ (Sub-systems) xếp nối tiếp nhau:
1. **Phân hệ Data Pipeline (Đã xong - Trọng tâm báo cáo):** Chịu trách nhiệm tạo Dataset. Dùng kiến trúc đường ống ETL (Extract - Transform - Load).
2. **Phân hệ AI Core (Bước tiếp theo):** Kéo dữ liệu sạch từ MongoDB xuống, nhét vào Mô hình học sâu (như PhoBERT, mBART, hoặc dùng nền tảng RAG với LLM) để huấn luyện hoặc truy vấn.

**2.2. Biểu đồ Hoạt động (Activity Diagram)**
Đây là linh hồn bài báo cáo của bạn. Hãy vẽ quá trình chạy:
`Raw PDF (Nguồn)` -> `extract_group_A (Trích xuất Text Tiếng Việt)` -> `Tiện ích chuẩn hóa (Xóa stopword, nối câu, sửa font)` -> `Đóng gói cấu trúc Output sang JSONL` -> `Nạp JSONL vô Database Mongo`.

**2.3. Lược đồ phân rã hệ thống con (Phân hệ Xử lý Dữ liệu)**
Khớp hoàn toàn với các folder bạn có:
- Modun Thu Thập: `collecting_data` & `data_download`.
- Modun Trích Xuất: `extract_and_scan`.
- Modun Tiền Xử Lý: `preprocess_and_normalized`.
- Modun Lưu Trữ: MongoDB Storage Hub.

## CHƯƠNG 3: THIẾT KẾ DATASET VÀ CƠ SỞ DỮ LIỆU
**3.1. Thiết kế định dạng Dataset (File JSONL)**
- Phải giải thích được tại sao nhóm không dùng file TXT hay CSV mà lại dùng `.jsonl`: Vì JSONL cực kỳ phổ biến trong cộng đồng học máy (như HuggingFace). Từng dòng là 1 JSON object giúp việc đọc stream dữ liệu siêu lớn không bị đầy bộ nhớ RAM, rất lý tưởng để feed vào mô hình AI.

**3.2. Cấu trúc CSDL MongoDB (Document Schema Design)**
- Database: `Viet_Papers_DB`
- Sơ đồ Document mẫu cho Collection `corpus_dataset`:
  ```json
  {
     "_id": "ObjectID",
     "source_file": "paper_abc.pdf",
     "raw_text": "Toàn văn nhiễu...",
     "cleaned_text": "Văn bản tiếng Việt đã được tinh chỉnh mượt mà...",
     "human_summary": "Tóm tắt mẫu (nếu thu thập được dùng để Train Supervised)",
     "status": "ready_for_nlp"
  }
  ```

## CHƯƠNG 4: LỰA CHỌN CÔNG NGHỆ ÁP DỤNG
- **Ngôn ngữ:** Python (Vua của Data Science và AI).
- **Thư viện PDF:** Các thư viện bạn đang khai thác (như `PyMuPDF`, `PyPDF2`...). Nhấn mạnh việc xử lý encoding Tiếng Việt rất khó qua thư viện ngoại.
- **Thư viện NLP Tiếng Việt (Nếu dùng):** `underthesea` hoặc `pyvi` để tách từ (word segmentation).
- **Chuẩn dữ liệu trung gian:** JSONLines (.jsonl).
- **Cơ sở dữ liệu NoSQL:** MongoDB (Tuyệt vời cho lưu trữ văn bản Big Data dạng Document vô định hình).

## CHƯƠNG 5: KẾT LUẬN VÀ BƯỚC TIẾP THEO
- **Kết luận:** Nhóm đã hoàn thiện thành công hạ tầng quan trọng và khó khăn nhất của một dự án Trí tuệ nhân tạo: Thiết lập được luồng làm sạch dữ liệu lớn (Big Data Pipeline) chuyên biệt xử lý các dị bản của PDF ngôn ngữ Tiếng Việt, lưu vào MongoDB. Sẵn sàng tạo ra Dataset quý giá.
- **Bước tiếp theo (AI Modeling):** 
  + Chọn kiến trúc AI (Ví dụ: sequence-to-sequence như mBART để finetune, hoặc dùng cấu trúc Langchain RAG kết hợp LLM API).
  + Khai thác `cleaned_text` từ MongoDB để AI thực hiện Inference (đoán nhận tóm tắt).
