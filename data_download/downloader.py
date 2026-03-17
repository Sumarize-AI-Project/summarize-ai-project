import asyncio
import httpx
import sqlite3
import aiofiles
from tqdm.asyncio import tqdm
from config import PDF_DIR, MAX_CONCURRENT_DOWNLOADS, TIMEOUT_SECONDS, DB_PATH

async def download_task(client, semaphore, row):
    """Nhiệm vụ tải cho từng file đơn lẻ"""
    db_id, url, j_code = row
    if not j_code: # Nếu j_code bị None hoặc rỗng
        j_code = "khac" # Đưa vào thư mục tên là "khac"

    async with semaphore:
        # Tạo thư mục con theo tạp chí để dễ quản lý (Data Organization)
        sub_folder = PDF_DIR / j_code
        sub_folder.mkdir(parents=True, exist_ok=True)
        dest_path = sub_folder / f"{db_id}.pdf"

        try:
            # Header giả lập trình duyệt để tránh bị chặn
            headers = {
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
            }

            response = await client.get(url, headers=headers, timeout=TIMEOUT_SECONDS, follow_redirects=True)

            # Kiểm tra tính hợp lệ của file (Data Validation)
            if response.status_code == 200:
                content = response.content
                if b"%PDF" in content[:1024]: # Kiểm tra header file PDF
                    async with aiofiles.open(dest_path, "wb") as f:
                        await f.write(content)
                    return db_id, "downloaded", str(dest_path), None
                else:
                    return db_id, "error", None, "Invalid Content: Not a PDF"
            else:
                return db_id, "error", None, f"HTTP {response.status_code}"

        except Exception as e:
            return db_id, "error", None, str(e)

async def run_data_collection():
    """Điều phối toàn bộ quá trình tải hàng loạt"""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # Chỉ lấy những file chưa tải hoặc bị lỗi để tải lại (Incremental Loading)
    cursor.execute("SELECT id, pdf_url, journal_code FROM articles WHERE status != 'downloaded'")
    rows = cursor.fetchall()

    if not rows:
        print("🎉 Tất cả file đã được tải xong!")
        return

    print(f"🚀 Bắt đầu tải {len(rows)} file...")

    semaphore = asyncio.Semaphore(MAX_CONCURRENT_DOWNLOADS)

    async with httpx.AsyncClient(verify=False) as client:
        tasks = [download_task(client, semaphore, row) for row in rows]

        # Dùng tqdm để hiển thị thanh tiến trình trực quan
        for future in tqdm(asyncio.as_completed(tasks), total=len(tasks), desc="Downloading"):
            db_id, status, path, error = await future

            # Cập nhật kết quả vào Tracker ngay lập tức
            cursor.execute('''
                UPDATE articles
                SET status = ?, local_path = ?, error_log = ?, retry_count = retry_count + 1
                WHERE id = ?
            ''', (status, path, error, db_id))
            conn.commit()

    conn.close()
    print("\n✅ Giai đoạn 1 hoàn tất!")