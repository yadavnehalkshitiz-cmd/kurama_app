from pathlib import Path
import unittest


class FlutterWorkflowTests(unittest.TestCase):
    def setUp(self):
        self.root = Path(__file__).parents[1]

    @staticmethod
    def workflow_text():
        return (
            Path(__file__).parents[1] / ".github" / "workflows" / "flutter_build.yml"
        ).read_text(encoding="utf-8")

    def test_android_job_does_not_regenerate_committed_runner(self):
        workflow = self.workflow_text()

        self.assertNotIn("flutter create --platforms=android .", workflow)

    def test_windows_job_pins_visual_studio_2022_runner(self):
        workflow = self.workflow_text()

        self.assertIn("runs-on: windows-2022", workflow)
        self.assertNotIn("runs-on: windows-latest", workflow)

    def test_flutter_workflow_uses_app_repository_paths_and_names(self):
        workflow = self.workflow_text()
        self.assertNotIn("kurama_mobile/", workflow)
        self.assertIn("working-directory: ./mobile", workflow)
        self.assertIn(
            "mobile/build/app/outputs/flutter-apk/app-release.apk", workflow
        )
        self.assertIn("Kurama-App-Android-APK", workflow)
        self.assertIn("Kurama-App-Windows.zip", workflow)

    def test_tagged_android_build_configures_release_signing(self):
        workflow = self.workflow_text()

        for secret in (
            "ANDROID_KEYSTORE_BASE64",
            "ANDROID_KEYSTORE_PASSWORD",
            "ANDROID_KEY_ALIAS",
            "ANDROID_KEY_PASSWORD",
        ):
            self.assertIn(f"secrets.{secret}", workflow)
        self.assertIn("base64 --decode", workflow)
        self.assertIn("app/kuramabot-release.jks", workflow)
        self.assertIn("key.properties", workflow)

    def test_android_signing_material_is_always_removed(self):
        workflow = self.workflow_text()

        self.assertIn("Remove Android signing material", workflow)
        self.assertIn("if: always()", workflow)
        self.assertIn(
            "rm -f android/app/kuramabot-release.jks android/key.properties",
            workflow,
        )

    def test_workflow_uses_node24_compatible_action_versions(self):
        workflow = self.workflow_text()

        for action in (
            "actions/checkout@v7",
            "actions/setup-java@v5",
            "actions/upload-artifact@v7",
            "actions/download-artifact@v8",
            "softprops/action-gh-release@v3",
        ):
            self.assertIn(action, workflow)

        for deprecated_action in (
            "actions/checkout@v4",
            "actions/setup-java@v4",
            "actions/upload-artifact@v4",
            "actions/download-artifact@v4",
            "softprops/action-gh-release@v2",
        ):
            self.assertNotIn(deprecated_action, workflow)

    def test_backend_workflow_tests_and_builds_container(self):
        workflow = (
            self.root / ".github" / "workflows" / "backend_ci.yml"
        ).read_text(encoding="utf-8")
        self.assertIn("python -m unittest discover -s tests -v", workflow)
        self.assertIn("PYTHONPATH", workflow)
        self.assertIn("docker build -f deployment/Dockerfile .", workflow)

    def test_backend_container_starts_only_the_api(self):
        dockerfile = (self.root / "deployment" / "Dockerfile").read_text(
            encoding="utf-8"
        )
        self.assertIn('CMD ["uvicorn", "api_server:app"', dockerfile)
        self.assertNotIn("run_bot.py", dockerfile)
        self.assertNotIn("bot.py", dockerfile)


if __name__ == "__main__":
    unittest.main()
