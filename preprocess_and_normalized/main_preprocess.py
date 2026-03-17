import subprocess
import os
import sys
import time

print("="*60)
print("🚀 HỆ THỐNG DATAOPS: TỰ ĐỘNG HÓA TIỀN XỬ LÝ & PHÂN LOẠI PDF")
print("="*60)

# Định vị thư mục chứa các script
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))

# Danh sách các bước theo đúng thứ tự (Băng chuyền)
PIPELINE_STEPS = [
    {
        "name": "BƯỚC 2: Phân loại Thô (Macro Classify - Tách Scan & Digital)",
        "script": "step2_macro_classify.py"
    },
    {
        "name": "BƯỚC 3: Giải cứu Dữ liệu (Data Rescue - Chống nhận nhầm)",
        "script": "step3_rescue.py"
    },
    {
        "name": "BƯỚC 4: Phân loại Tinh (Micro Classify - Tách B1 & B2)",
        "script": "step4_micro_classify.py"
    }
]

def run_pipeline():
    start_time = time.time()
    
    for step in PIPELINE_STEPS:
        print(f"\n" + "-"*60)
        print(f"▶️ ĐANG KHỞI CHẠY {step['name']}...")
        print("-" * 60)
        
        script_path = os.path.join(CURRENT_DIR, step['script'])
        
        # Kiểm tra xem file script có tồn tại không
        if not os.path.exists(script_path):
            print(f"❌ LỖI NGHIÊM TRỌNG: Không tìm thấy file {step['script']}!")
            print("🛑 Băng chuyền đã bị dừng khẩn cấp.")
            sys.exit(1)
            
        # Gọi script chạy như thể bạn tự gõ lệnh trên Terminal
        try:
            # Dùng subprocess để kích hoạt file Python khác
            result = subprocess.run([sys.executable, script_path], check=True)
        except subprocess.CalledProcessError:
            print(f"\n❌ LỖI: {step['name']} gặp sự cố và đã dừng lại.")
            print("🛑 Băng chuyền đã bị dừng khẩn cấp để bảo vệ dữ liệu.")
            sys.exit(1)
            
        print(f"\n✅ HOÀN TẤT {step['name']}!")
        time.sleep(2) # Nghỉ 2 giây cho hệ thống xả hơi trước khi qua bước tiếp theo

    end_time = time.time()
    total_time = (end_time - start_time) / 60
    
    print("="*60)
    print(f"🎉🎉🎉 CHÚC MỪNG! TOÀN BỘ BĂNG CHUYỀN ĐÃ HOÀN TẤT!")
    print(f"⏱️ Tổng thời gian chạy: {total_time:.2f} phút")
    print("="*60)

if __name__ == "__main__":
    run_pipeline()