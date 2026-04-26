from __future__ import annotations

try:
    from dotenv import load_dotenv
    load_dotenv()
except Exception:
    pass

import os
from functools import lru_cache


def _parse_bool(value: str | None, *, default: bool) -> bool:
    if value is None:
        return default
    return value.strip().lower() in {"1", "true", "yes", "on"}


def _parse_csv(value: str | None, *, default: list[str]) -> list[str]:
    if value is None or not value.strip():
        return default
    return [item.strip() for item in value.split(",") if item.strip()]


class Settings:
    def __init__(self) -> None:
        self.app_name = os.getenv("BUNCHIN_APP_NAME", "Bunchin Backend")
        self.environment = os.getenv("BUNCHIN_ENV", "development")
        self.database_url = os.getenv(
            "BUNCHIN_DATABASE_URL",
            "sqlite:///./bunchin.db",
        )
        self.timezone = os.getenv("BUNCHIN_TIMEZONE", "America/Sao_Paulo")
        self.token_secret = os.getenv("BUNCHIN_TOKEN_SECRET")
        self.encryption_secret = os.getenv("BUNCHIN_ENCRYPTION_SECRET")
        self.token_ttl_hours = int(os.getenv("BUNCHIN_TOKEN_TTL_HOURS", "12"))
        self.remember_me_ttl_days = int(
            os.getenv("BUNCHIN_REMEMBER_ME_TTL_DAYS", "30"),
        )
        self.enforce_https = _parse_bool(
            os.getenv("BUNCHIN_ENFORCE_HTTPS"),
            default=False,
        )
        self.seed_on_startup = _parse_bool(
            os.getenv("BUNCHIN_SEED_ON_STARTUP"),
            default=True,
        )
        self.allowed_origins = _parse_csv(
            os.getenv("BUNCHIN_ALLOWED_ORIGINS"),
            default=[
                "http://localhost",
                "http://localhost:3000",
                "http://localhost:5173",
                "http://localhost:8080",
            ],
        )
        self.seed_admin_password = os.getenv(
            "BUNCHIN_SEED_ADMIN_PASSWORD",
            "Bunchin@123",
        )

        missing = [
            name
            for name, value in {
                "BUNCHIN_TOKEN_SECRET": self.token_secret,
                "BUNCHIN_ENCRYPTION_SECRET": self.encryption_secret,
            }.items()
            if not value
        ]
        if missing:
            missing_list = ", ".join(missing)
            raise RuntimeError(
                "Missing required environment variables: "
                f"{missing_list}. Configure them before starting the backend.",
            )


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings()
