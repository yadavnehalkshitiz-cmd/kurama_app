"""Tests for the kurama_api application factory and stable error envelope."""
import os
import sys
import unittest
from pathlib import Path

from fastapi.testclient import TestClient

sys.path.insert(0, str(Path(__file__).parents[1] / "backend"))

from kurama_api.app import create_app
from kurama_api.config import Settings


class AppFactoryTests(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(create_app(Settings.for_testing()))

    def test_v1_health_has_versioned_contract(self):
        response = self.client.get("/v1/health")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["service"], "kurama-api")
        self.assertEqual(response.json()["status"], "ok")

    def test_api_error_uses_stable_envelope_and_request_id(self):
        response = self.client.get("/v1/test/not-found-route")
        self.assertEqual(response.status_code, 404)
        body = response.json()["error"]
        self.assertEqual(body["code"], "route_not_found")
        self.assertFalse(body["retryable"])
        self.assertIn("request_id", body)

    def test_request_id_is_propagated_from_header(self):
        custom_id = "my-trace-id-abc123"
        response = self.client.get(
            "/v1/test/not-found-route",
            headers={"X-Request-ID": custom_id},
        )
        self.assertEqual(response.json()["error"]["request_id"], custom_id)

    def test_settings_for_testing_provides_valid_keys(self):
        s = Settings.for_testing()
        self.assertEqual(s.api_auth_key, "test-key")
        self.assertEqual(s.api_admin_key, "test-admin-key")
        self.assertGreater(s.task_ttl_seconds, 0)

    def test_settings_from_environment_reads_env_vars(self):
        os.environ["KURAMA_API_KEY"] = "env-key-xyz"
        try:
            s = Settings.from_environment()
            self.assertEqual(s.api_auth_key, "env-key-xyz")
        finally:
            del os.environ["KURAMA_API_KEY"]

    def test_create_app_returns_fastapi_instance(self):
        from fastapi import FastAPI
        app = create_app(Settings.for_testing())
        self.assertIsInstance(app, FastAPI)

    def test_cors_middleware_is_configured(self):
        # FastAPI wraps CORSMiddleware as a generic Middleware entry.
        # Verify it is present by inspecting the middleware stack kwargs.
        app = create_app(Settings.for_testing())
        cors_found = any(
            getattr(m, "kwargs", {}).get("allow_credentials") is True
            or "CORSMiddleware" in str(getattr(m, "cls", ""))
            for m in app.user_middleware
        )
        self.assertTrue(cors_found, "CORSMiddleware not configured on the app")


if __name__ == "__main__":
    unittest.main()
