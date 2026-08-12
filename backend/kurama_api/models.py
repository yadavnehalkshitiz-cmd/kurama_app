"""kurama_api.models — task record and state definitions."""
from __future__ import annotations

from dataclasses import dataclass, field
from enum import StrEnum


class TaskStatus(StrEnum):
    pending = "pending"
    waiting_for_worker = "waiting_for_worker"
    downloading = "downloading"
    verifying = "verifying"
    completed = "completed"
    failed = "failed"
    cancelled = "cancelled"


# States that are considered "in-flight" and should be recovered to
# waiting_for_worker on server restart.
_INFLIGHT_STATES = {TaskStatus.pending, TaskStatus.downloading}


@dataclass
class TaskRecord:
    task_id: str
    owner_id: str
    client_request_id: str
    url: str
    format: str
    status: TaskStatus
    progress: int = 0
    downloaded_bytes: int = 0
    total_bytes: int | None = None
    created_at: float = 0.0
    updated_at: float = 0.0
    error_code: str | None = None
    error_message: str | None = None
    # Preserves unknown fields from old JSON records
    extra: dict = field(default_factory=dict)

    @classmethod
    def from_dict(cls, d: dict) -> "TaskRecord":
        """Deserialize from a raw dictionary (e.g. loaded from JSON).

        In-flight tasks (pending/downloading) are transitioned to
        ``waiting_for_worker`` without losing byte/progress data.
        """
        known_fields = {
            "task_id", "owner_id", "client_request_id", "url", "format",
            "status", "progress", "downloaded_bytes", "total_bytes",
            "created_at", "updated_at", "error_code", "error_message",
        }
        extra = {k: v for k, v in d.items() if k not in known_fields}

        raw_status = d.get("status", "pending")
        try:
            status = TaskStatus(raw_status)
        except ValueError:
            status = TaskStatus.pending

        if status in _INFLIGHT_STATES:
            status = TaskStatus.waiting_for_worker

        return cls(
            task_id=d.get("task_id", ""),
            owner_id=d.get("owner_id", ""),
            client_request_id=d.get("client_request_id", ""),
            url=d.get("url", ""),
            format=d.get("format", "video"),
            status=status,
            progress=d.get("progress", 0),
            downloaded_bytes=d.get("downloaded_bytes", 0),
            total_bytes=d.get("total_bytes"),
            created_at=float(d.get("created_at", 0)),
            updated_at=float(d.get("updated_at", 0)),
            error_code=d.get("error_code"),
            error_message=d.get("error_message"),
            extra=extra,
        )

    def to_dict(self) -> dict:
        d = {
            "task_id": self.task_id,
            "owner_id": self.owner_id,
            "client_request_id": self.client_request_id,
            "url": self.url,
            "format": self.format,
            "status": self.status.value,
            "progress": self.progress,
            "downloaded_bytes": self.downloaded_bytes,
            "total_bytes": self.total_bytes,
            "created_at": self.created_at,
            "updated_at": self.updated_at,
            "error_code": self.error_code,
            "error_message": self.error_message,
        }
        d.update(self.extra)
        return d
