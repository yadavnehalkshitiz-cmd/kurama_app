"""kurama_api.app — FastAPI application factory.

Usage:
    from kurama_api.app import create_app
    app = create_app()                          # production (reads env vars)
    app = create_app(Settings.for_testing())    # tests / CI

Uvicorn --factory:
    uvicorn kurama_api.app:create_app --factory --host 0.0.0.0 --port 8000
"""
from __future__ import annotations

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from starlette.exceptions import HTTPException as StarletteHTTPException
from fastapi.exceptions import RequestValidationError

from kurama_api.config import Settings
from kurama_api.errors import (
    ApiError,
    api_error_handler,
    http_exception_handler,
    validation_error_handler,
)
from kurama_api.routers.health import router as health_router
from kurama_api.routers.v1_downloads import router as v1_downloads_router


def create_app(
    settings: Settings | None = None,
    task_repository=None,   # injected in Tasks 7-8; None → built from settings
    download_service=None,  # injected in Tasks 7-8; None → built from settings
) -> FastAPI:
    """Build and return a configured FastAPI application.

    Args:
        settings: typed runtime configuration.  When *None* reads from
            environment variables via ``Settings.from_environment()``.
        task_repository: optional pre-built ``TaskRepository`` (used by tests).
        download_service: optional pre-built ``DownloadService`` (used by tests).
    """
    if settings is None:
        settings = Settings.from_environment()

    app = FastAPI(
        title="Kurama App API",
        version="1.2.0",
        description="Backend for the Kurama App media downloader",
    )

    # ── CORS ────────────────────────────────────────────────────────────
    app.add_middleware(
        CORSMiddleware,
        allow_origins=list(settings.allowed_origins),
        allow_credentials=True,
        allow_methods=["GET", "POST"],
        allow_headers=["Authorization", "Content-Type", "Idempotency-Key", "X-Request-ID"],
    )

    # ── Exception handlers ──────────────────────────────────────────────
    app.add_exception_handler(ApiError, api_error_handler)
    app.add_exception_handler(StarletteHTTPException, http_exception_handler)
    app.add_exception_handler(RequestValidationError, validation_error_handler)

    # ── Versioned routes ────────────────────────────────────────────────
    app.include_router(health_router)
    app.include_router(v1_downloads_router)

    # Store settings and injected deps on the app instance so routers/
    # tasks mounted in Tasks 7-8 can access them via app.state.
    app.state.settings = settings
    app.state.task_repository = task_repository
    app.state.download_service = download_service

    return app
