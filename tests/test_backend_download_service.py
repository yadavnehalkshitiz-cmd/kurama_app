"""Tests for DownloadService — idempotency, concurrency guard, retry."""
import sys
import time
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parents[1] / "backend"))

from kurama_api.models import TaskRecord, TaskStatus
from kurama_api.repositories import InMemoryTaskRepository
from kurama_api.services.downloads import (
    CreateDownloadCommand,
    DownloadService,
)


class DownloadServiceTests(unittest.TestCase):
    def _service(self, max_concurrent=5):
        repo = InMemoryTaskRepository()
        spawned = []
        svc = DownloadService(
            repo,
            spawn=lambda t: spawned.append(t.task_id),
            max_concurrent=max_concurrent,
        )
        return svc, repo, spawned

    def _cmd(self, request_id="req-1", owner="user-1", url="https://example.com/v"):
        return CreateDownloadCommand(
            owner_id=owner,
            client_request_id=request_id,
            url=url,
            format="video",
        )

    def test_create_returns_new_task(self):
        svc, repo, spawned = self._service()
        result = svc.create(self._cmd())
        self.assertEqual(result.task.status, TaskStatus.pending)
        self.assertFalse(result.idempotent_replay)
        self.assertEqual(spawned, [result.task.task_id])

    def test_create_returns_existing_task_for_same_owner_and_request_id(self):
        svc, repo, spawned = self._service()
        first = svc.create(self._cmd())
        second = svc.create(self._cmd())
        self.assertEqual(first.task.task_id, second.task.task_id)
        self.assertTrue(second.idempotent_replay)
        # Worker only spawned once
        self.assertEqual(len(spawned), 1)

    def test_different_request_ids_create_separate_tasks(self):
        svc, repo, spawned = self._service()
        r1 = svc.create(self._cmd(request_id="req-a"))
        r2 = svc.create(self._cmd(request_id="req-b"))
        self.assertNotEqual(r1.task.task_id, r2.task.task_id)
        self.assertFalse(r2.idempotent_replay)

    def test_concurrency_guard_rejects_over_limit(self):
        from fastapi import HTTPException
        svc, repo, spawned = self._service(max_concurrent=2)
        svc.create(self._cmd(request_id="r1"))
        svc.create(self._cmd(request_id="r2"))
        with self.assertRaises(HTTPException) as ctx:
            svc.create(self._cmd(request_id="r3"))
        self.assertEqual(ctx.exception.status_code, 429)

    def test_retry_failed_task_requeues(self):
        svc, repo, spawned = self._service()
        result = svc.create(self._cmd())
        task = result.task
        task.status = TaskStatus.failed
        repo.update(task)
        svc.retry(task.task_id, task.owner_id)
        updated = repo.get(task.task_id)
        self.assertEqual(updated.status, TaskStatus.pending)
        self.assertEqual(len(spawned), 2)

    def test_retry_unknown_task_raises_404(self):
        from fastapi import HTTPException
        svc, repo, spawned = self._service()
        with self.assertRaises(HTTPException) as ctx:
            svc.retry("nonexistent", "user-1")
        self.assertEqual(ctx.exception.status_code, 404)

    def test_retry_wrong_owner_raises_403(self):
        from fastapi import HTTPException
        svc, repo, spawned = self._service()
        result = svc.create(self._cmd())
        task = result.task
        task.status = TaskStatus.failed
        repo.update(task)
        with self.assertRaises(HTTPException) as ctx:
            svc.retry(task.task_id, "intruder")
        self.assertEqual(ctx.exception.status_code, 403)

    def test_retry_downloading_task_raises_409(self):
        from fastapi import HTTPException
        svc, repo, spawned = self._service()
        result = svc.create(self._cmd())
        task = result.task
        task.status = TaskStatus.downloading
        repo.update(task)
        with self.assertRaises(HTTPException) as ctx:
            svc.retry(task.task_id, task.owner_id)
        self.assertEqual(ctx.exception.status_code, 409)


if __name__ == "__main__":
    unittest.main()
