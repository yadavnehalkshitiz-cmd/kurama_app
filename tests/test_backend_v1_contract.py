"""Tests for the /v1 API contract — downloads and idempotency."""
import sys
import unittest
from pathlib import Path

from fastapi.testclient import TestClient

sys.path.insert(0, str(Path(__file__).parents[1] / "backend"))

from kurama_api.app import create_app
from kurama_api.config import Settings
from kurama_api.repositories import InMemoryTaskRepository
from kurama_api.services.downloads import DownloadService


def _make_app():
    repo = InMemoryTaskRepository()
    svc = DownloadService(repository=repo, max_concurrent=5)
    app = create_app(settings=Settings.for_testing(), download_service=svc)
    # Inject the repository into app.state for the GET route
    app.state.task_repository = repo
    app.state.download_service = svc
    return TestClient(app)


class V1DownloadContractTests(unittest.TestCase):
    def setUp(self):
        self.client = _make_app()

    def test_post_without_idempotency_key_is_rejected(self):
        response = self.client.post(
            "/v1/downloads",
            json={"url": "https://example.com/video"},
        )
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.json()["error"]["code"], "idempotency_key_required")

    def test_post_with_key_returns_202_and_download_id(self):
        response = self.client.post(
            "/v1/downloads",
            json={"url": "https://example.com/video", "format": "video"},
            headers={"Idempotency-Key": "req-abc"},
        )
        self.assertEqual(response.status_code, 202)
        body = response.json()
        self.assertIn("download_id", body)
        self.assertEqual(body["status"], "pending")
        self.assertFalse(body["idempotent_replay"])

    def test_repeat_post_same_key_returns_200_and_same_id(self):
        first = self.client.post(
            "/v1/downloads",
            json={"url": "https://example.com/video", "format": "video"},
            headers={"Idempotency-Key": "dup-key"},
        )
        second = self.client.post(
            "/v1/downloads",
            json={"url": "https://example.com/video", "format": "video"},
            headers={"Idempotency-Key": "dup-key"},
        )
        self.assertEqual(second.status_code, 200)
        self.assertEqual(first.json()["download_id"], second.json()["download_id"])
        self.assertTrue(second.json()["idempotent_replay"])

    def test_get_existing_download_returns_status(self):
        create_resp = self.client.post(
            "/v1/downloads",
            json={"url": "https://example.com/video"},
            headers={"Idempotency-Key": "get-test"},
        )
        download_id = create_resp.json()["download_id"]
        poll = self.client.get(f"/v1/downloads/{download_id}")
        self.assertEqual(poll.status_code, 200)
        self.assertEqual(poll.json()["download_id"], download_id)
        self.assertIn("status", poll.json())

    def test_get_missing_download_returns_404_with_stable_code(self):
        response = self.client.get("/v1/downloads/nonexistent-id")
        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.json()["error"]["code"], "download_not_found")

    def test_v1_health_returns_ok(self):
        response = self.client.get("/v1/health")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["status"], "ok")


if __name__ == "__main__":
    unittest.main()
