# Summarize Paper (RAG) — Giải thích dự án (Backend + Frontend)

Tài liệu này mô tả cách dự án hoạt động ở mức **chi tiết theo code hiện tại**: luồng đăng ký/đăng nhập, upload PDF hoặc dán text, tạo tóm tắt, chat theo RAG, và admin dashboard.

> Lưu ý bảo mật: file [backend/.env](backend/.env) hiện đang chứa **MongoDB URI + SMTP credentials**. Không nên commit lên repo công khai.

---

## 1) Tổng quan kiến trúc

### Thành phần chính

- **Backend**: FastAPI + MongoDB (Motor)
  - Entry: [backend/app/main.py](backend/app/main.py)
  - Router: [backend/app/api/router.py](backend/app/api/router.py)
  - DB: MongoDB qua `motor.motor_asyncio`
  - Chức năng:
    - Auth (register/verify/login)
    - Lưu document (text/pdf)
    - Tạo summary + lưu rating
    - Chat theo RAG (Chroma + embeddings + (tuỳ chọn) LLM local Qwen)
    - Admin KPI dashboard

- **Frontend**: Next.js (App Router) + client-side localStorage auth
  - API client + type definitions: [frontend/web/src/lib/api.ts](frontend/web/src/lib/api.ts)
  - Auth persistence: [frontend/web/src/lib/auth.ts](frontend/web/src/lib/auth.ts)
  - Landing/Auth page: [frontend/web/src/app/page.tsx](frontend/web/src/app/page.tsx)
  - Dashboard workspace: [frontend/web/src/app/dashboard/page.tsx](frontend/web/src/app/dashboard/page.tsx) + [frontend/web/src/components/dashboard-workspace.tsx](frontend/web/src/components/dashboard-workspace.tsx)
  - Admin page: [frontend/web/src/app/admin/page.tsx](frontend/web/src/app/admin/page.tsx)

### Base URL FE → BE

Frontend gọi backend qua:

- `API_BASE_URL = NEXT_PUBLIC_API_BASE_URL ?? "http://127.0.0.1:8002/api"`
  - nằm ở [frontend/web/src/lib/api.ts:1](frontend/web/src/lib/api.ts#L1)

Backend mount router tại `settings.api_prefix` (mặc định `/api`):
- [backend/app/main.py:34](backend/app/main.py#L34)
- [backend/app/core/config.py:11-16](backend/app/core/config.py#L11-L16)

---

## 2) Backend — cấu trúc, config và endpoints

### 2.1. Khởi tạo app + CORS + health

- File: [backend/app/main.py](backend/app/main.py)
- Việc xảy ra khi start server:
  1) Tạo `upload_dir` nếu chưa có (mặc định `backend/uploads`).
  2) Ping MongoDB để set `app.state.database_status`.
  3) Bật CORS cho `settings.frontend_origin` + localhost:3000.

Health endpoints:
- `GET /health` → `{status:"ok"}`
- `GET /health/db` → `{database: "ok" | "error: ..."}`

### 2.2. Settings / biến môi trường

- File: [backend/app/core/config.py](backend/app/core/config.py)
- Settings dùng `pydantic-settings`, đọc từ `.env` tại `backend/.env`.

Một số biến quan trọng:
- `FRONTEND_ORIGIN` → FE domain
- `MONGO_URI`, `MONGO_DB_NAME`
- `JWT_SECRET` (token ký bằng HS256)
- SMTP: `SMTP_HOST/PORT/USERNAME/PASSWORD` (gửi OTP)
- RAG:
  - `RAG_EMBEDDING_MODEL_NAME` (mặc định bkai bi-encoder)
  - `RAG_CHROMA_BASE_DIR` (mặc định `backend/uploads/chroma`)
  - `RAG_ENABLE_LLM_ANSWERS` (bật/tắt trả lời bằng LLM local)
  - `RAG_QWEN_MODEL_PATH` (trỏ tới `backend/qwen_offline` hoặc đường dẫn ngoài)
- Admin:
  - `ADMIN_EMAILS` (allowlist email admin)

### 2.3. Database (MongoDB Motor)

- File: [backend/app/core/database.py](backend/app/core/database.py)
- Global client:
  - `client = AsyncIOMotorClient(settings.mongo_uri, ...)`
  - `database = client[settings.mongo_db_name]`

Collections được dùng (nhìn theo service):
- `users`
- `documents`
- `summaries`
- `summary_ratings`

### 2.4. Auth (JWT + verify email)

- Routes: [backend/app/api/routes/auth.py](backend/app/api/routes/auth.py)
- Security helpers: [backend/app/core/security.py](backend/app/core/security.py)

Luồng:

1) **Register**
- `POST /api/auth/register`
- Input: `{ full_name, email, password }`
- Tạo user với `is_verified=false`, lưu `verification_code` + expiry.
- Gửi OTP qua SMTP (xem `email_service`).

2) **Verify Email**
- `POST /api/auth/verify-email`
- Input: `{ email, code }`
- Nếu đúng và chưa hết hạn → set `is_verified=true`, xoá `verification_code`, trả JWT access token.

3) **Login**
- `POST /api/auth/login`
- Chỉ cho login nếu `is_verified=true`.

JWT:
- Token chứa `sub = user_id` và `exp`
- Decode/verify ở `get_current_user()`.

### 2.5. Summary API (tạo document + generate summary + rating)

Routes chính nằm ở: [backend/app/api/routes/summary.py](backend/app/api/routes/summary.py)

#### A) Upload PDF → tạo Document
- `POST /api/summary/upload`
- Content-Type: multipart/form-data
  - `file`: PDF
  - `language`: `vi|en` (default vi)
- Xử lý:
  1) Lưu file vào `settings.upload_dir` (mặc định `backend/uploads`).
  2) Extract text từ PDF bằng `get_pdf_text_smart(...)`.
     - Import từ: [backend/app/services/summary_reference_pdf_processor.py](backend/app/services/summary_reference_pdf_processor.py) (chưa đọc sâu trong lượt này nhưng route đang dùng)
  3) Tính `content_hash` (SHA256 của text normalized) để reuse document nếu đã có.
  4) Lưu document vào MongoDB (`documents`).

Kết quả trả về `UploadDocumentResponse`.

#### B) Tạo Document từ text
- `POST /api/summary/text`
- JSON body: `{ text, language, title? }`
- Lưu document source_type="text".

#### C) Generate summary
- `POST /api/summary/{document_id}/generate`
- Auth: Bearer token
- JSON body: `{ language, force_regenerate, target_words }`

Logic:
- Nếu `force_regenerate=false` thì backend cố trả về **preferred summary** (rating cao nhất) nếu đã có.
- Nếu cần generate mới:
  - Gọi `SummaryService.generate_summary(...)`.
  - Lưu summary vào `summaries`.

`SummaryService` hiện tại:
- File: [backend/app/services/summary_service.py](backend/app/services/summary_service.py)
- Thực tế gọi `summarize_pdf_by_textrank(...)` từ [backend/app/services/summary_reference_summarizer.py](backend/app/services/summary_reference_summarizer.py)
  - Có chế độ `use_llm_polish` (mặc định bật cho tiếng Việt nếu `summary_enable_llm_polish=true`).
  - Method gắn nhãn:
    - `reference-textrank-qwen` (nếu có dùng LLM polish)
    - `reference-textrank-fallback`
    - `reference-textrank-extractive`

#### D) Lịch sử & detail
- `GET /api/summary/history` (auth)
  - Trả list `SummaryHistoryItem` dựa trên documents của user.
- `GET /api/summary/{document_id}` (auth)
  - Trả `SummaryDetailResponse`: document + preferred/latest + all summaries sorted.

#### E) Rating summary
- `POST /api/summary/{document_id}/summaries/{summary_id}/rate` (auth)
- Body: `{ rating: 1..5 }`
- Logic update:
  - Lưu rating theo user vào `summary_ratings`
  - Update `rating_total`, `rating_count`, `rating_average` trên `summaries`
- Thực thi ở: [backend/app/services/document_service.py](backend/app/services/document_service.py)

### 2.6. Chat API (RAG)

Route:
- `POST /api/chat`
- File: [backend/app/api/routes/chat.py](backend/app/api/routes/chat.py)
- Body: `{ document_id, question, locale }`

Luồng xử lý:
1) Lấy document theo `document_id` từ DB.
2) Gọi `ChatService.answer_question(...)`.
   - File: [backend/app/services/chat_service.py](backend/app/services/chat_service.py)
3) `ChatService` gọi `RAGService.answer(...)`.
   - File: [backend/app/services/rag_service.py](backend/app/services/rag_service.py)

#### RAGService hoạt động như thế nào?

**(1) Embedding**
- Dùng `HuggingFaceEmbeddings` với model name `settings.rag_embedding_model_name`
- Mặc định: `bkai-foundation-models/vietnamese-bi-encoder`

**(2) Vector store (Chroma persisted)**
- Persist dir: `settings.rag_chroma_base_dir / document_id`
  - Mặc định: `backend/uploads/chroma/<document_id>/...`
- Có cơ chế `.fingerprint`:
  - fingerprint = sha256(document_text)
  - Nếu fingerprint khớp → reuse chroma index đã build
  - Nếu khác → xoá thư mục cũ và rebuild

**(3) Chunking**
- Chunk theo đoạn (split theo `\n\n`), quản lý theo số từ:
  - `rag_chunk_words` (default 350)
  - `rag_chunk_overlap_words` (default 60)

**(4) Retrieval**
- `retriever = vectorstore.as_retriever(search_kwargs={"k": rag_retriever_k})`
- Lấy top-k document chunks rồi join thành `context`.

**(5) Answer generation**
- Nếu `rag_enable_llm_answers=false` hoặc không load được transformers pipeline → fallback:
  - Trả lại context để user tham chiếu (`reference-rag-retrieval-fallback`).
- Nếu bật LLM answers:
  - Dùng transformers `pipeline("text-generation")`
  - Model id/path:
    - Ưu tiên `rag_qwen_model_path` nếu tồn tại
    - Nếu không có, dùng `rag_qwen_model_id` (default `Qwen/Qwen2.5-3B-Instruct`)
  - Prompt template yêu cầu “chỉ dựa vào ngữ cảnh” (grounded QA)
  - Method: `reference-rag-qwen`

### 2.7. Admin API

- Routes: [backend/app/api/routes/admin.py](backend/app/api/routes/admin.py)
- Auth:
  - Dựa vào Bearer token + `get_current_user`
  - Sau đó check email nằm trong `ADMIN_EMAILS`

Endpoints:
- `GET /api/admin/me` (check quyền)
- `GET /api/admin/kpis` (counts)
- `GET /api/admin/series?days=30` (time series signups + summaries)
- `GET /api/admin/recent?limit=10`

---

## 3) Frontend — luồng UI và cách gọi API

### 3.1. API client

- File: [frontend/web/src/lib/api.ts](frontend/web/src/lib/api.ts)
- 3 helper chính:
  - `apiRequest(path, init)` → JSON, không kèm token
  - `apiAuthedRequest(path, token, init)` → thêm header `Authorization: Bearer <token>`
  - `apiFormRequest(path, formData)` → POST multipart

Các type FE match backend response models (`DocumentResponse`, `SummaryResponse`, `ChatResponse`, ...)

### 3.2. Lưu auth + locale

- File: [frontend/web/src/lib/auth.ts](frontend/web/src/lib/auth.ts)
- Lưu vào localStorage:
  - `summarize-ai-auth` (AuthResponse)
  - `summarize-ai-locale` (vi|en)

### 3.3. Landing page: đăng ký / verify / login

- File: [frontend/web/src/app/page.tsx](frontend/web/src/app/page.tsx)

UI gọi backend theo thứ tự:
- Register: `POST /auth/register`
- Verify: `POST /auth/verify-email` → thành công sẽ `persistAuth()` rồi chuyển `/dashboard`
- Login: `POST /auth/login` → `persistAuth()` rồi chuyển `/dashboard`

### 3.4. Dashboard gate

- File: [frontend/web/src/app/dashboard/page.tsx](frontend/web/src/app/dashboard/page.tsx)
- Khi mount:
  - đọc `readPersistedAuth()`
  - nếu không có token → `router.replace("/#auth")`
  - nếu có → render `DashboardWorkspace`

### 3.5. DashboardWorkspace (tóm tắt + lịch sử + chat)

- File: [frontend/web/src/components/dashboard-workspace.tsx](frontend/web/src/components/dashboard-workspace.tsx)

Các state chính:
- Input:
  - `articleText` (textarea)
  - `selectedFile` (PDF)
- `activeDocument` (document hiện tại để generate summary / chat)
- Summary:
  - `summary`, `summaryMeta`, `availableSummaries`
- Chat:
  - `chatQuestion`, `chatAnswer`, `chatMeta`
- History:
  - `historyItems`

#### A) Load history
- Khi vào dashboard gọi:
  - `GET /summary/history` (authed)

#### B) Tạo document (ensureActiveDocument)
Hàm `ensureActiveDocument()` quyết định:
- Nếu đã có `activeDocument` → reuse
- Nếu có `selectedFile` → gọi `POST /summary/upload` (multipart)
- Nếu có `articleText` → gọi `POST /summary/text`

Nếu backend trả `reused_existing=true` → FE hiện message: ưu tiên summary rating cao.

#### C) Generate summary
- Button “Tạo tóm tắt”:
  - `POST /summary/{document.id}/generate` (authed)
  - body `{ language: locale, force_regenerate, target_words }`
- FE sẽ:
  - set `summary`, `summaryMeta`
  - reload history

#### D) Load history item detail
- Khi click 1 item:
  - `GET /summary/{documentId}` (authed)
  - set `activeDocument = detail.document`
  - set summary selection theo `detail.summary` và list `detail.available_summaries`

#### E) Chat theo RAG
- `POST /chat` (không authed trong FE hiện tại)
- body `{ document_id, question, locale }`
- FE hiển thị `chatMeta.method` + `chatMeta.source`

#### F) Rate summary
- `POST /summary/{document_id}/summaries/{summary_id}/rate` (authed)
- Sau đó FE resort list summaries theo:
  1) rating_average desc
  2) rating_count desc
  3) created_at desc

### 3.6. Admin page

- File: [frontend/web/src/app/admin/page.tsx](frontend/web/src/app/admin/page.tsx)
- Khi mount:
  - nếu chưa login → redirect `/#auth`
  - nếu có token → gọi `fetchAdminMe(token)`
  - rồi load song song: `kpis`, `series`, `recent`
  - nếu không phải admin → redirect về `/dashboard`

---

## 4) Luồng nghiệp vụ end-to-end (tóm tắt theo sequence)

### 4.1. Đăng ký → xác thực → đăng nhập
1) FE `POST /api/auth/register`
2) BE lưu user + OTP + gửi email
3) FE nhập code → `POST /api/auth/verify-email`
4) BE set verified + trả JWT
5) FE lưu localStorage và vào `/dashboard`

### 4.2. Upload PDF → tạo summary
1) FE chọn PDF → `POST /api/summary/upload`
2) BE lưu file, extract text, hash, lưu document
3) FE `POST /api/summary/{document_id}/generate`
4) BE tóm tắt (Textrank + có thể polish bằng LLM), lưu summary
5) FE hiển thị summary, cho rate

### 4.3. Chat (RAG)
1) FE `POST /api/chat`
2) BE load document.extracted_text
3) RAGService:
   - chunk → embed → build/reuse Chroma index per document_id
   - retrieve top-k
   - nếu LLM answers bật và load được model → sinh answer grounded
   - nếu không → trả fallback context

---

## 5) Gợi ý file cần xem tiếp (nếu muốn hiểu sâu hơn phần PDF/OCR + summarizer)

- PDF extraction “smart”:
  - [backend/app/services/summary_reference_pdf_processor.py](backend/app/services/summary_reference_pdf_processor.py)
  - [backend/app/services/summary_reference_config.py](backend/app/services/summary_reference_config.py)
- Summarizer textrank + LLM polish:
  - [backend/app/services/summary_reference_summarizer.py](backend/app/services/summary_reference_summarizer.py)
- Notebook gốc (research):
  - [backend/RAG.ipynb](backend/RAG.ipynb)
  - [backend/dataops-aisumary-9.ipynb](backend/dataops-aisumary-9.ipynb)

---

## 6) Cách chạy (tham khảo)

### Backend
- Cài deps: `pip install -r backend/requirements.txt`
- Chạy server (ví dụ):
  - `uvicorn app.main:app --host 127.0.0.1 --port 8002 --reload`

### Frontend
- `cd frontend/web`
- `npm install`
- `npm run dev`

---
