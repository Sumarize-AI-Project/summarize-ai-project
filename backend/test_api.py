"""Script test trực tiếp Google GenAI API để debug lỗi"""
import os
import sys
sys.path.insert(0, os.path.dirname(__file__))

from dotenv import load_dotenv
load_dotenv()

from google import genai

# Lấy API key
api_key = os.getenv("GEMINI_API_KEY_PRIMARY", "").strip()
print(f"API Key (4 ký tự đầu): {api_key[:4]}...")

client = genai.Client(api_key=api_key)

# Test 1: Liệt kê các model có sẵn
print("\n=== DANH SÁCH MODEL CÓ SẴN ===")
try:
    models = client.models.list()
    for m in models:
        name = m.name if hasattr(m, 'name') else str(m)
        if 'gemma' in name.lower() or 'flash-lite' in name.lower():
            print(f"  - {name}")
except Exception as e:
    print(f"  Lỗi khi liệt kê model: {e}")

# Test 2: Gọi gemma-4-31b-it
print("\n=== TEST gemma-4-31b-it ===")
try:
    response = client.models.generate_content(
        model="gemma-4-31b-it",
        contents="Xin chào, hãy trả lời ngắn gọn: 1+1 bằng mấy?"
    )
    print(f"  Thành công! Response: {response.text}")
except Exception as e:
    print(f"  LỖI: {type(e).__name__}: {e}")

# Test 3: Gọi gemini-3.1-flash-lite
print("\n=== TEST gemini-3.1-flash-lite ===")
try:
    response = client.models.generate_content(
        model="gemini-3.1-flash-lite",
        contents="Xin chào, hãy trả lời ngắn gọn: 1+1 bằng mấy?"
    )
    print(f"  Thành công! Response: {response.text}")
except Exception as e:
    print(f"  LỖI: {type(e).__name__}: {e}")

print("\n=== XONG ===")
