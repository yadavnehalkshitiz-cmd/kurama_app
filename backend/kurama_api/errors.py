"""kurama_api.errors — stable error envelope and exception handlers.

Every error response the client receives follows this shape:

    {
        "error": {
            "code": "snake_case_stable_string",
            "message": "Human-readable description.",
            "retryable": false,
            "recovery_action": null,
            "request_id": "uuid"
        }
    }

The ``request_id`` is propagated from the ``X-Request-ID`` request header when
present; otherwise a fresh UUID is generated.
"""
from __future__ import annotations

import uuid
from dataclasses import dataclass

from fastapi import Request
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException


@dataclass
class ApiError(Exception):
    """Raise this anywhere inside a route to emit a stable error envelope."""

    code: str
    message: str
    status_code: int = 400
    retryable: bool = False
    recovery_action: str | None = None


def _request_id(request: Request) -> str:
    return request.headers.get("X-Request-ID") or str(uuid.uuid4())


def _error_body(
    request: Request,
    *,
    code: str,
    message: str,
    retryable: bool = False,
    recovery_action: str | None = None,
) -> dict:
    return {
        "error": {
            "code": code,
            "message": message,
            "retryable": retryable,
            "recovery_action": recovery_action,
            "request_id": _request_id(request),
        }
    }


async def api_error_handler(request: Request, exc: ApiError) -> JSONResponse:
    return JSONResponse(
        status_code=exc.status_code,
        content=_error_body(
            request,
            code=exc.code,
            message=exc.message,
            retryable=exc.retryable,
            recovery_action=exc.recovery_action,
        ),
    )


async def http_exception_handler(
    request: Request, exc: StarletteHTTPException
) -> JSONResponse:
    if exc.status_code == 404:
        code, message = "route_not_found", "The requested API route does not exist."
    elif exc.status_code == 401:
        code, message = "invalid_legacy_credential", str(exc.detail)
    elif exc.status_code == 503:
        code, message = "service_unavailable", str(exc.detail)
    elif exc.status_code == 429:
        code, message = "worker_capacity_reached", str(exc.detail)
    else:
        code, message = "request_error", str(exc.detail)
    return JSONResponse(
        status_code=exc.status_code,
        content=_error_body(
            request,
            code=code,
            message=message,
            retryable=exc.status_code in (429, 503),
        ),
    )


async def validation_error_handler(
    request: Request, exc: RequestValidationError
) -> JSONResponse:
    return JSONResponse(
        status_code=422,
        content=_error_body(
            request,
            code="validation_error",
            message=str(exc.errors()),
        ),
    )
