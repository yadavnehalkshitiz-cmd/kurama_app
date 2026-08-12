"""Phase 0 architecture boundary tests.

These tests act as executable acceptance criteria for the Phase 0 plan.
Every sub-test is expected to FAIL until the corresponding task is
implemented; when all pass, Phase 0 is structurally complete.
"""

from pathlib import Path
import unittest


ROOT = Path(__file__).parents[1]


class Phase0ArchitectureTests(unittest.TestCase):
    # ── Flutter composition files (Tasks 2-5) ─────────────
    def test_flutter_composition_files_exist(self):
        for relative in (
            "mobile/lib/app/app.dart",
            "mobile/lib/app/app_bootstrap.dart",
            "mobile/lib/app/app_environment.dart",
            "mobile/lib/app/app_scope.dart",
            "mobile/lib/infrastructure/database/app_database.dart",
        ):
            with self.subTest(relative=relative):
                self.assertTrue((ROOT / relative).is_file(), relative)

    def test_flutter_theme_tokens_exist(self):
        for relative in (
            "mobile/lib/app/theme/kurama_colors.dart",
            "mobile/lib/app/theme/kurama_theme.dart",
        ):
            with self.subTest(relative=relative):
                self.assertTrue((ROOT / relative).is_file(), relative)

    def test_flutter_domain_boundaries_exist(self):
        for relative in (
            "mobile/lib/core/errors/app_failure.dart",
            "mobile/lib/domain/downloads/download_repository.dart",
            "mobile/lib/domain/playback/playback_position_repository.dart",
            "mobile/lib/features/downloads/download_controller.dart",
        ):
            with self.subTest(relative=relative):
                self.assertTrue((ROOT / relative).is_file(), relative)

    def test_flutter_infrastructure_files_exist(self):
        for relative in (
            "mobile/lib/infrastructure/downloads/sqlite_download_repository.dart",
            "mobile/lib/infrastructure/playback/sqlite_playback_position_repository.dart",
            "mobile/lib/infrastructure/migration/legacy_state_reader.dart",
            "mobile/lib/infrastructure/migration/legacy_state_migrator.dart",
            "mobile/lib/infrastructure/migration/legacy_state_mirror.dart",
        ):
            with self.subTest(relative=relative):
                self.assertTrue((ROOT / relative).is_file(), relative)

    # ── Backend package boundaries (Tasks 6-8) ────────────
    def test_backend_package_boundaries_exist(self):
        for relative in (
            "backend/kurama_api/__init__.py",
            "backend/kurama_api/app.py",
            "backend/kurama_api/config.py",
            "backend/kurama_api/auth.py",
            "backend/kurama_api/errors.py",
            "backend/kurama_api/models.py",
            "backend/kurama_api/repositories.py",
            "backend/kurama_api/services/downloads.py",
            "backend/kurama_api/routers/v1_downloads.py",
            "backend/kurama_api/routers/legacy.py",
            "backend/kurama_api/routers/health.py",
        ):
            with self.subTest(relative=relative):
                self.assertTrue((ROOT / relative).is_file(), relative)

    # ── No server-side database or queue deps (Task 1) ────
    def test_phase0_does_not_add_server_database_or_queue_dependencies(self):
        requirements = (ROOT / "backend/requirements.txt").read_text(
            encoding="utf-8"
        ).lower()
        for forbidden in ("sqlalchemy", "psycopg", "redis", "celery", "rq"):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, requirements)

    # ── CI and delivery files (Task 9) ────────────────────
    def test_windows_runner_is_committed(self):
        self.assertTrue(
            (ROOT / "mobile/windows/runner/main.cpp").is_file(),
            "mobile/windows/runner/main.cpp must be committed, not generated in CI",
        )

    def test_migration_runbook_exists(self):
        self.assertTrue(
            (ROOT / "docs/PHASE_0_MIGRATION.md").is_file(),
            "docs/PHASE_0_MIGRATION.md must exist",
        )


class Phase0ReleaseSecretTests(unittest.TestCase):
    """Ensure no production secret is compiled into a release client."""

    def test_release_client_has_no_embedded_api_key(self):
        dart_source = "\n".join(
            path.read_text(encoding="utf-8", errors="replace")
            for path in (ROOT / "mobile/lib").rglob("*.dart")
        )
        # No hard-coded key assignment
        import re
        self.assertNotRegex(dart_source, r"KURAMA_API_KEY\s*=\s*['\"][^'\"]+")
        # No leftover "Fix Key" repair UI intended for end users
        self.assertNotIn("Fix Key", dart_source)


if __name__ == "__main__":
    unittest.main()
