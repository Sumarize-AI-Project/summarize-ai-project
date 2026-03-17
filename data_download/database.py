import sqlite3

import json

import os

from config import DB_PATH, JSON_INPUT
from config import PDF_DIR



def init_tracker():

    """Đọc JSON và khởi tạo sổ cái quản lý dữ liệu"""

    conn = sqlite3.connect(DB_PATH)

    cursor = conn.cursor()



    # Tạo bảng quản lý theo vòng đời dữ liệu

    cursor.execute('''

        CREATE TABLE IF NOT EXISTS articles (

            id INTEGER PRIMARY KEY AUTOINCREMENT,

            title TEXT,

            journal_code TEXT,

            pdf_url TEXT UNIQUE,

            status TEXT DEFAULT 'pending',

            local_path TEXT,

            error_log TEXT,

            retry_count INTEGER DEFAULT 0

        )

    ''')



    # Load dữ liệu từ file JSON vào DB

    if os.path.exists(JSON_INPUT):

        with open(JSON_INPUT, 'r', encoding='utf-8') as f:

            data = json.load(f)

            print(f"--- Đang nạp {len(data)} mục vào Database ---")

            for item in data:

                cursor.execute('''

                    INSERT OR IGNORE INTO articles (title, journal_code, pdf_url)

                    VALUES (?, ?, ?)

                ''', (item.get('article_title'), item.get('journal_code'), item.get('pdf_url')))

        conn.commit()

    else:

        print(f"⚠️ Không tìm thấy file {JSON_INPUT}!")



    conn.close()

    print(f"✅ Đã khởi tạo Tracker tại: {DB_PATH}")

def sync_existing_files():
    """Quét thư mục thật trên máy và cập nhật trạng thái đã tải vào Database"""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # Tìm những file mà sổ cái đang báo là chưa tải
    cursor.execute("SELECT id, journal_code FROM articles WHERE status != 'downloaded'")
    rows = cursor.fetchall()

    synced_count = 0
    for db_id, j_code in rows:
        if not j_code:
            j_code = "khac"
        
        # Đường dẫn thực tế nếu file đã được tải về
        expected_path = PDF_DIR / j_code / f"{db_id}.pdf"
        
        # Kiểm tra xem file có thực sự nằm trên ổ cứng không
        if expected_path.exists():
            cursor.execute('''
                UPDATE articles 
                SET status = 'downloaded', local_path = ? 
                WHERE id = ?
            ''', (str(expected_path), db_id))
            synced_count += 1
            
    conn.commit()
    conn.close()
    
    if synced_count > 0:
        print(f"🔄 Đã đồng bộ & bỏ qua {synced_count} file PDF cũ có sẵn trên máy!")
    else:
        print("🔍 Đã kiểm tra: Không có file cũ nào cần đồng bộ.")