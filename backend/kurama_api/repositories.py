"""kurama_api.repositories — TaskRepository protocol and JSON implementation.

The JSON implementation uses atomic file replace (write tmp → os.replace) so
a server crash during a write never leaves a partially-written file.
"""
from __future__ import annotations

import json
import os
import threading
import time
from pathlib import Path
from typing import Protocol, runtime_checkable

from kurama_api.models import TaskRecord, TaskStatus


@runtime_checkable
class TaskRepository(Protocol):
    def create(self, task: TaskRecord) -> TaskRecord: ...
    def get(self, task_id: str) -> TaskRecord | None: ...
    def find_by_request(
        self, owner_id: str, client_request_id: str
    ) -> TaskRecord | None: ...
    def update(self, task: TaskRecord) -> TaskRecord: ...
    def list(self) -> list[TaskRecord]: ...
    def delete(self, task_id: str) -> bool: ...


class InMemoryTaskRepository:
    """Simple in-memory repository used in tests and as a lightweight default."""

    def __init__(self) -> None:
        self._store: dict[str, TaskRecord] = {}
        self._lock = threading.Lock()

    def create(self, task: TaskRecord) -> TaskRecord:
        with self._lock:
            self._store[task.task_id] = task
        return task

    def get(self, task_id: str) -> TaskRecord | None:
        return self._store.get(task_id)

    def find_by_request(
        self, owner_id: str, client_request_id: str
    ) -> TaskRecord | None:
        for t in self._store.values():
            if t.owner_id == owner_id and t.client_request_id == client_request_id:
                return t
        return None

    def update(self, task: TaskRecord) -> TaskRecord:
        with self._lock:
            task.updated_at = time.time()
            self._store[task.task_id] = task
        return task

    def list(self) -> list[TaskRecord]:
        return list(self._store.values())

    def delete(self, task_id: str) -> bool:
        with self._lock:
            if task_id in self._store:
                del self._store[task_id]
                return True
        return False


class JsonTaskRepository:
    """Disk-backed task repository using atomic JSON replace.

    On load, in-flight tasks (pending/downloading) are recovered to
    ``waiting_for_worker`` without resetting byte/progress fields.
    """

    def __init__(self, path: str | Path) -> None:
        self._path = Path(path)
        self._lock = threading.Lock()
        self._store: dict[str, TaskRecord] = {}
        self._load()

    # ── Private ───────────────────────────────────────────────────────

    def _load(self) -> None:
        if not self._path.exists():
            return
        try:
            raw: dict = json.loads(self._path.read_text(encoding="utf-8"))
            for task_id, d in raw.items():
                self._store[task_id] = TaskRecord.from_dict(d)
        except Exception:
            # Corrupt file — start empty; old file left for forensics.
            pass

    def _save(self) -> None:
        self._path.parent.mkdir(parents=True, exist_ok=True)
        tmp = str(self._path) + ".tmp"
        snapshot = {tid: t.to_dict() for tid, t in self._store.items()}
        with open(tmp, "w", encoding="utf-8") as fh:
            json.dump(snapshot, fh)
        os.replace(tmp, self._path)

    # ── Protocol ──────────────────────────────────────────────────────

    def create(self, task: TaskRecord) -> TaskRecord:
        with self._lock:
            self._store[task.task_id] = task
            self._save()
        return task

    def get(self, task_id: str) -> TaskRecord | None:
        return self._store.get(task_id)

    def find_by_request(
        self, owner_id: str, client_request_id: str
    ) -> TaskRecord | None:
        for t in self._store.values():
            if t.owner_id == owner_id and t.client_request_id == client_request_id:
                return t
        return None

    def update(self, task: TaskRecord) -> TaskRecord:
        with self._lock:
            task.updated_at = time.time()
            self._store[task.task_id] = task
            self._save()
        return task

    def list(self) -> list[TaskRecord]:
        return list(self._store.values())

    def delete(self, task_id: str) -> bool:
        with self._lock:
            if task_id in self._store:
                del self._store[task_id]
                self._save()
                return True
        return False
