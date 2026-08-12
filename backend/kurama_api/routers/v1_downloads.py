"""kurama_api.routers.v1_downloads — versioned download API with idempotency.

POST /v1/downloads  — create a download (requires Idempotency-Key header)
GET  /v1/downloads/{id} — poll status

During Phase 0 the legacy numeric user_id from the request body is mapped to
``legacy-user-{user_id}`` as the owner_id. Managed session identity replaces
this mapping in Phase 2.
"""
from __future__ import annotations

import uuid
from typing import Literal

from fastapi import APIRouter, Depends, Header, HTTPException, Request
from pydantic import BaseModel, HttpUrl

from kurama_api.errors import ApiError
from kurama_api.models import TaskStatus
from kurama_api.services.downloads import CreateDownloadCommand, DownloadService

router = APIRouter()


# ── Request / Response models ─────────────────────────────────────────────────

class CreateDownloadBody(BaseModel):
    url: str
    format: Literal["video", "audio"] = "video"
    video_quality: str = "best"
    audio_quality: str = "best"
    thumbnail: str | None = None
    playlist: bool = False
    # Optional legacy numeric user ID; defaults to 0 for guest/anon
    user_id: int = 0


class DownloadEnvelope(BaseModel):
    download_id: str
    status: str
    idempotent_replay: bool = False


# ── Helpers ───────────────────────────────────────────────────────────────────

def _get_service(request: Request) -> DownloadService:
    svc = getattr(request.app.state, "download_service", None)
    if svc is None:
        raise HTTPException(503, "Download service not initialised")
    return svc


def _require_idempotency_key(
    idempotency_key: str | None = Header(None),
) -> str:
    if not idempotency_key:
        raise ApiError(
            code="idempotency_key_required",
            message="The Idempotency-Key header is required for download creation.",
            status_code=400,
        )
    return idempotency_key


def _owner_from_user_id(user_id: int) -> str:
    """Map the legacy numeric user_id to a stable owner string."""
    if user_id and user_id > 0:
        return f"legacy-user-{user_id}"
    return "guest"


# ── Routes ────────────────────────────────────────────────────────────────────

@router.post("/v1/downloads", status_code=202)
async def create_download(
    body: CreateDownloadBody,
    request: Request,
    idempotency_key: str = Depends(_require_idempotency_key),
):
    """Create a new download task.

    Returns 202 for a new task, 200 if the Idempotency-Key was already used
    (idempotent replay).
    """
    service = _get_service(request)
    owner_id = _owner_from_user_id(body.user_id)

    command = CreateDownloadCommand(
        owner_id=owner_id,
        client_request_id=idempotency_key,
        url=body.url,
        format=body.format,
        video_quality=body.video_quality,
        audio_quality=body.audio_quality,
        thumbnail=body.thumbnail,
        playlist=body.playlist,
    )

    result = service.create(command)

    response_data = {
        "download_id": result.task.task_id,
        "status": result.task.status.value,
        "idempotent_replay": result.idempotent_replay,
    }

    if result.idempotent_replay:
        from fastapi.responses import JSONResponse
        return JSONResponse(status_code=200, content=response_data)

    return response_data


@router.get("/v1/downloads/{download_id}")
async def get_download(download_id: str, request: Request):
    """Poll the status of a download task."""
    service = _get_service(request)
    task = service._repo.get(download_id)
    if task is None:
        raise ApiError(
            code="download_not_found",
            message=f"Download {download_id!r} was not found.",
            status_code=404,
        )
    return {
        "download_id": task.task_id,
        "status": task.status.value,
        "progress": task.progress,
        "downloaded_bytes": task.downloaded_bytes,
        "total_bytes": task.total_bytes,
        "error_code": task.error_code,
        "error_message": task.error_message,
    }
