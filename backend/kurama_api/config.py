"""kurama_api.config — typed runtime settings.

Read from environment variables. Never imports api_server or legacy config.
"""
from __future__ import annotations

import os
import tempfile
from dataclasses import dataclass, field
from pathlib import Path


@dataclass(frozen=True)
class Settings:
    api_auth_key: str | None
    api_admin_key: str | None
    allowed_origins: tuple[str, ...]
    temp_folder: str
    task_ttl_seconds: int
    max_concurrent_downloads: int

    @classmethod
    def from_environment(cls) -> "Settings":
        origins_raw = os.getenv("CORS_ALLOWED_ORIGINS", "")
        origins = tuple(
            item.strip() for item in origins_raw.split(",") if item.strip()
        ) or ("http://localhost:3000", "http://127.0.0.1:3000")

        default_temp = str(
            Path(__file__).parents[1] / "temp_mobile"
        )
        return cls(
            api_auth_key=os.getenv("KURAMA_API_KEY") or None,
            api_admin_key=os.getenv("KURAMA_ADMIN_KEY") or None,
            allowed_origins=origins,
            temp_folder=os.getenv("KURAMA_TEMP_FOLDER", default_temp),
            task_ttl_seconds=int(os.getenv("TASK_TTL", "3600")),
            max_concurrent_downloads=int(
                os.getenv("MAX_CONCURRENT_DOWNLOADS", "5")
            ),
        )

    @classmethod
    def for_testing(cls, temp_folder: str | None = None) -> "Settings":
        return cls(
            api_auth_key="test-key",
            api_admin_key="test-admin-key",
            allowed_origins=("http://testserver",),
            temp_folder=temp_folder or tempfile.mkdtemp(prefix="kurama-api-test-"),
            task_ttl_seconds=3600,
            max_concurrent_downloads=5,
        )
