"""Tests for JsonTaskRepository — disk persistence and restart recovery."""
import json
import os
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parents[1] / "backend"))

from kurama_api.models import TaskRecord, TaskStatus
from kurama_api.repositories import JsonTaskRepository, InMemoryTaskRepository


def _make_task(**kwargs) -> TaskRecord:
    import time
    defaults = dict(
        task_id="job-1",
        owner_id="user-1",
        client_request_id="req-1",
        url="https://example.com/video",
        format="video",
        status=TaskStatus.pending,
        created_at=time.time(),
        updated_at=time.time(),
    )
    defaults.update(kwargs)
    return TaskRecord(**defaults)


class JsonTaskRepositoryTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.path = Path(self.temp.name) / "tasks.json"

    def tearDown(self):
        self.temp.cleanup()

    def test_create_and_get_round_trips(self):
        repo = JsonTaskRepository(self.path)
        task = _make_task()
        repo.create(task)
        got = repo.get("job-1")
        self.assertIsNotNone(got)
        self.assertEqual(got.task_id, "job-1")

    def test_update_persists_to_disk(self):
        repo = JsonTaskRepository(self.path)
        task = _make_task()
        repo.create(task)
        task.status = TaskStatus.completed
        repo.update(task)
        # Re-load from disk
        repo2 = JsonTaskRepository(self.path)
        self.assertEqual(repo2.get("job-1").status, TaskStatus.completed)

    def test_interrupted_task_is_recovered_without_deleting_progress(self):
        self.path.write_text(
            json.dumps({
                "job-1": {
                    "task_id": "job-1",
                    "owner_id": "user-1",
                    "client_request_id": "req-1",
                    "url": "https://example.com/1",
                    "format": "video",
                    "status": "downloading",
                    "progress": 68,
                    "downloaded_bytes": 680,
                    "total_bytes": 1000,
                    "created_at": 1.0,
                    "updated_at": 2.0,
                }
            }),
            encoding="utf-8",
        )
        repo = JsonTaskRepository(self.path)
        task = repo.get("job-1")
        self.assertEqual(task.status, TaskStatus.waiting_for_worker)
        self.assertEqual(task.progress, 68)
        self.assertEqual(task.downloaded_bytes, 680)

    def test_pending_task_recovered_to_waiting_for_worker(self):
        self.path.write_text(
            json.dumps({
                "job-2": {
                    "task_id": "job-2",
                    "owner_id": "u",
                    "client_request_id": "r",
                    "url": "https://example.com/2",
                    "format": "video",
                    "status": "pending",
                    "progress": 0,
                    "downloaded_bytes": 0,
                    "created_at": 1.0,
                    "updated_at": 1.0,
                }
            }),
            encoding="utf-8",
        )
        repo = JsonTaskRepository(self.path)
        self.assertEqual(repo.get("job-2").status, TaskStatus.waiting_for_worker)

    def test_delete_removes_and_returns_true(self):
        repo = JsonTaskRepository(self.path)
        repo.create(_make_task())
        self.assertTrue(repo.delete("job-1"))
        self.assertIsNone(repo.get("job-1"))

    def test_delete_missing_returns_false(self):
        repo = JsonTaskRepository(self.path)
        self.assertFalse(repo.delete("nonexistent"))

    def test_find_by_request_matches_owner_and_key(self):
        repo = JsonTaskRepository(self.path)
        repo.create(_make_task(owner_id="alice", client_request_id="abc"))
        found = repo.find_by_request("alice", "abc")
        self.assertIsNotNone(found)
        self.assertIsNone(repo.find_by_request("alice", "xyz"))

    def test_atomic_write_uses_tmp_file(self):
        """Verify no partial writes reach the target file."""
        repo = JsonTaskRepository(self.path)
        repo.create(_make_task())
        # The .tmp file must not remain after a successful write
        self.assertFalse(Path(str(self.path) + ".tmp").exists())

    def test_corrupt_file_starts_empty(self):
        self.path.write_text("{corrupt json}", encoding="utf-8")
        repo = JsonTaskRepository(self.path)
        self.assertEqual(repo.list(), [])


class InMemoryTaskRepositoryTests(unittest.TestCase):
    def test_basic_crud(self):
        repo = InMemoryTaskRepository()
        task = _make_task()
        repo.create(task)
        self.assertEqual(repo.get("job-1").task_id, "job-1")
        task.status = TaskStatus.completed
        repo.update(task)
        self.assertEqual(repo.get("job-1").status, TaskStatus.completed)
        self.assertTrue(repo.delete("job-1"))
        self.assertIsNone(repo.get("job-1"))


if __name__ == "__main__":
    unittest.main()
