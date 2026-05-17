from google import genai
from google.genai.errors import APIError
from app.core.config import ENV_FILE, settings
import logging

logger = logging.getLogger(__name__)

_clients: list[genai.Client] | None = None
_current_client_idx = 0


def _api_keys() -> list[str]:
    return [
        key.strip()
        for key in (
            settings.gemini_api_key_primary,
            settings.gemini_api_key_fallback,
            settings.gemini_api_key_tertiary,
        )
        if key and key.strip()
    ]


def get_clients() -> list[genai.Client]:
    """Tạo danh sách GenAI clients từ .env (lazy, không phụ thuộc cwd lúc import)."""
    global _clients
    keys = _api_keys()
    if not keys:
        exists = "có" if ENV_FILE.is_file() else "KHÔNG có"
        raise ValueError(
            f"Chưa cấu hình GEMINI API key. File {ENV_FILE} {exists}. "
            "Thêm GEMINI_API_KEY_PRIMARY=... và khởi động lại server."
        )
    if _clients is None or len(_clients) != len(keys):
        _clients = [genai.Client(api_key=key) for key in keys]
    return _clients


def get_current_client():
    """Lấy ra client GenAI hiện tại đang được active."""
    clients = get_clients()
    return clients[_current_client_idx]


def switch_api_key():
    """Tự động chuyển sang Client/API Key dự phòng khi gặp lỗi Rate Limit / Hết Quota."""
    global _current_client_idx
    clients = get_clients()
    if len(clients) > 1:
        _current_client_idx = (_current_client_idx + 1) % len(clients)
        logger.warning(
            f"Đã chuyển sang dùng API Key dự phòng (Key thứ {_current_client_idx + 1})."
        )
    else:
        logger.error("Chỉ có 1 API Key, không có key dự phòng để chuyển đổi!")
        raise Exception("API Key đã hết Quota và không có Key dự phòng.")


def diagnose():
    """Gọi lúc startup để kiểm tra .env và API key."""
    keys = _api_keys()
    logger.info(f"[DIAGNOSE] .env: {ENV_FILE} ({'OK' if ENV_FILE.is_file() else 'MISSING'})")
    logger.info(f"[DIAGNOSE] Số API key: {len(keys)}")
    if not keys:
        logger.error("[DIAGNOSE] Không có GEMINI_API_KEY_* — LLM sẽ fallback extractive.")
        return
    try:
        models = get_clients()[0].models.list()
        names = [
            m.name
            for m in models
            if "gemini" in m.name.lower() or "gemma" in m.name.lower()
        ]
        logger.info(f"[DIAGNOSE] Model khả dụng ({len(names)}): {names[:8]}")
    except Exception as e:
        logger.error(f"[DIAGNOSE] Không liệt kê được model: {e}")


def polish_summary(extractive_text: str, target_words: int = 500) -> str:
    """Gọi LLM để biên tập (Polishing) bản tóm tắt thô thành văn bản mượt mà."""
    clients = get_clients()
    prompt = f"""
Bạn là một chuyên gia tổng hợp tài liệu học thuật. 
Dưới đây là các ý chính được trích xuất thô từ một bài báo/tài liệu tiếng Việt.
Nhiệm vụ của bạn là biên tập, liên kết và viết lại chúng thành một bản tóm tắt hoàn chỉnh, mạch lạc, dễ hiểu.
Tuyệt đối KHÔNG được bịa đặt thêm thông tin.

[YÊU CẦU CỰC KỲ QUAN TRỌNG VỀ ĐỘ DÀI]
Bản tóm tắt của bạn PHẢI dài sát với mốc {target_words} từ. 
KHÔNG ĐƯỢC PHÉP dài vượt quá {int(target_words)} từ. Hãy đếm số lượng từ cẩn thận và chắt lọc nội dung thật súc tích để đảm bảo không bị vượt quá giới hạn này.
CHỈ trả về nội dung tóm tắt, KHÔNG trả về các lời giải thích hay lặp lại yêu cầu.

Văn bản thô (Nguyên liệu):
---
{extractive_text}
---

Hãy viết bản tóm tắt cuối cùng:
"""

    max_retries = len(clients)
    last_e: Exception | None = None

    for attempt in range(max_retries):
        try:
            client = get_current_client()

            response = client.models.generate_content(
                model="gemma-4-31b-it",
                contents=prompt,
            )

            if response.text:
                return response.text.strip()

            logger.error(f"Phản hồi từ AI trống. Chi tiết response: {response}")
            last_e = Exception(f"Empty response: {response}")
            if attempt < max_retries - 1:
                switch_api_key()

        except APIError as e:
            logger.error(
                f"[API ERROR] Lần {attempt + 1}/{max_retries} | "
                f"Code: {getattr(e, 'code', 'N/A')} | Message: {getattr(e, 'message', str(e))}"
            )
            last_e = e
            error_msg = str(e).lower()

            if getattr(e, "code", None) in [400, 403, 429, 500, 503] or "quota" in error_msg or "rate" in error_msg:
                if attempt < max_retries - 1:
                    switch_api_key()
                    continue

            raise Exception(f"Lỗi LLM: {e}") from e

        except Exception as e:
            last_e = e
            logger.error(f"Lỗi hệ thống không xác định: {e}")
            if attempt < max_retries - 1:
                switch_api_key()
                continue
            raise Exception(f"Lỗi hệ thống: {e}") from e

    raise Exception(f"Tất cả {max_retries} API key đều lỗi. Lỗi cuối: {last_e}")


def generate_chat_reply(query: str, context: str) -> str:
    """Sử dụng Gemini để trả lời câu hỏi dựa trên Context (RAG)."""
    if not context.strip():
        return "Xin lỗi, tôi không tìm thấy thông tin nào trong tài liệu liên quan đến câu hỏi của bạn."

    clients = get_clients()
    prompt = f"""Bạn là một trợ lý ảo thông minh chuyên giải đáp các thắc mắc về tài liệu khoa học/báo cáo.
Dưới đây là một số thông tin trích xuất từ tài liệu của người dùng (Context):
---
{context}
---

DỰA VÀO HƯỚNG DẪN TRÊN, hãy trả lời câu hỏi sau của người dùng:
Câu hỏi: {query}

Yêu cầu:
- Trả lời rõ ràng, mạch lạc, trực tiếp vào vấn đề bằng tiếng Việt.
- CHỈ sử dụng thông tin có trong Context. Nếu Context không có thông tin để trả lời, hãy nói rõ là "Tài liệu không cung cấp thông tin này" chứ không được tự bịa ra (hallucination).
"""

    max_retries = len(clients)
    last_e: Exception | None = None

    for attempt in range(max_retries):
        try:
            client = get_current_client()
            response = client.models.generate_content(
                model="gemini-3.1-flash-lite",
                contents=prompt,
            )
            if response.text:
                return response.text.strip()

            last_e = Exception(f"Empty response: {response}")
            if attempt < max_retries - 1:
                switch_api_key()

        except APIError as e:
            last_e = e
            error_msg = str(e).lower()
            if getattr(e, "code", None) in [403, 429, 500, 503] or "quota" in error_msg or "rate" in error_msg or "internal" in error_msg:
                logger.warning(f"Lỗi API Chat (Lần {attempt + 1}/{max_retries}): {e}")
                if attempt < max_retries - 1:
                    switch_api_key()
                    continue
            raise Exception(f"Lỗi LLM: {e}") from e

        except Exception as e:
            logger.error(f"Lỗi hệ thống Chat: {e}")
            raise Exception(f"Lỗi LLM: {e}") from e

    raise Exception(f"Tất cả {max_retries} API key đều lỗi. Lỗi cuối: {last_e}")
