"""kurama_api.services.downloads — task orchestration and idempotency.

DownloadService sits between the API routes and the task workers.
It guarantees:

- Idempotent creation: same owner + client_request_id returns the existing
  task without spawning a second worker.
- Concurrency guard: rejects creation when too many tasks are active.
- Billing/credit concerns are isolated behind an injected
  ``LegacyEntitlementPolicy``; the service itself does not call user_config.
"""
from __future__ import annotations

import time
import uuid
from dataclasses import dataclass, field
from typing import Callable, Protocol, runtime_checkable

from kurama_api.models import TaskRecord, TaskStatus
from kurama_api.repositories import TaskRepository


# ── Entitlement policy boundary ──────────────────────────────────────────────

@runtime_checkable
class LegacyEntitlementPolicy(Protocol):
    """Isolates all billing / credit logic from the service layer."""

    def check_and_debit(self, owner_id: str, format: str) -> None:
        """Raise an exception if the owner cannot start a download."""
        ...

    def refund(self, owner_id: str, task_id: str) -> None:
        """Refund credits when a task is retried or fails unexpectedly."""
        ...


class NoOpEntitlementPolicy:
    """Used when billing is disabled (Phase 0 / guest mode)."""

    def check_and_debit(self, owner_id: str, format: str) -> None:
        pass

    def refund(self, owner_id: str, task_id: str) -> None:
        pass


# ── Command / result types ────────────────────────────────────────────────────

@dataclass
class CreateDownloadCommand:
    owner_id: str
    client_request_id: str
    url: str
    format: str = "video"
    video_quality: str = "best"
    audio_quality: str = "best"
    thumbnail: str | None = None
    playlist: bool = False


@dataclass
class CreateDownloadResult:
    task: TaskRecord
    idempotent_replay: bool = False


# ── Service ───────────────────────────────────────────────────────────────────

class DownloadService:
    def __init__(
        self,
        repository: TaskRepository,
        spawn: Callable[[TaskRecord], None] | None = None,
        max_concurrent: int = 5,
        entitlement_policy: LegacyEntitlementPolicy | None = None,
    ) -> None:
        self._repo = repository
        self._spawn = spawn or (lambda _: None)
        self._max_concurrent = max_concurrent
        self._policy = entitlement_policy or NoOpEntitlementPolicy()

    # ── Public API ────────────────────────────────────────────────────

    def create(self, command: CreateDownloadCommand) -> CreateDownloadResult:
        """Create a new download task, or return the existing one (idempotent)."""
        # Idempotency: same owner + request_id → return existing task
        existing = self._repo.find_by_request(
            command.owner_id, command.client_request_id
        )
        if existing is not None:
            return CreateDownloadResult(task=existing, idempotent_replay=True)

        # Concurrency guard
        active = [
            t for t in self._repo.list()
            if t.status in (
                TaskStatus.pending,
                TaskStatus.waiting_for_worker,
                TaskStatus.downloading,
                TaskStatus.verifying,
            )
        ]
        if len(active) >= self._max_concurrent:
            from fastapi import HTTPException
            raise HTTPException(
                429,
                f"Worker capacity reached ({self._max_concurrent} active downloads). "
                "Please wait for a slot to free up.",
            )

        # Entitlement check
        self._policy.check_and_debit(command.owner_id, command.format)

        # Persist before spawning (worker sees the record immediately)
        now = time.time()
        task = TaskRecord(
            task_id=str(uuid.uuid4()),
            owner_id=command.owner_id,
            client_request_id=command.client_request_id,
            url=command.url,
            format=command.format,
            status=TaskStatus.pending,
            created_at=now,
            updated_at=now,
        )
        self._repo.create(task)
        self._spawn(task)
        return CreateDownloadResult(task=task, idempotent_replay=False)

    def retry(self, task_id: str, owner_id: str) -> TaskRecord:
        """Retry a failed or waiting task, preserving the task_id."""
        task = self._repo.get(task_id)
        if task is None:
            from fastapi import HTTPException
            raise HTTPException(404, f"Task {task_id!r} not found")
        if task.owner_id != owner_id:
            from fastapi import HTTPException
            raise HTTPException(403, "Not authorised to retry this task")
        retryable_states = {TaskStatus.failed, TaskStatus.waiting_for_worker}
        if task.status not in retryable_states:
            from fastapi import HTTPException
            raise HTTPException(
                409,
                f"Task cannot be retried from status {task.status!r}. "
                f"Retryable states: {[s.value for s in retryable_states]}",
            )
        self._policy.refund(owner_id, task_id)
        task.status = TaskStatus.pending
        task.error_code = None
        task.error_message = None
        task.updated_at = time.time()
        self._repo.update(task)
        self._spawn(task)
        return task
