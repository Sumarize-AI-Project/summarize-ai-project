from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict

# Luôn trỏ tới backend/.env — không phụ thuộc thư mục khi chạy uvicorn
BACKEND_DIR = Path(__file__).resolve().parent.parent.parent
ENV_FILE = BACKEND_DIR / ".env"


class Settings(BaseSettings):
    gemini_api_key_primary: str = ""
    gemini_api_key_fallback: str = ""
    gemini_api_key_tertiary: str = ""
    host: str = "0.0.0.0"
    port: int = 8000

    model_config = SettingsConfigDict(
        env_file=ENV_FILE,
        env_file_encoding="utf-8",
        extra="ignore",
    )


settings = Settings()
