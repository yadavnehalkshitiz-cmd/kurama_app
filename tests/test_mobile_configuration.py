from pathlib import Path
import unittest


ROOT = Path(__file__).parents[1]


class MobileConfigurationTests(unittest.TestCase):
    def test_android_update_identity_is_preserved(self):
        gradle = (ROOT / "mobile/android/app/build.gradle.kts").read_text(
            encoding="utf-8"
        )
        self.assertIn('applicationId = "com.kuramabot.kurama_mobile"', gradle)
        self.assertIn('namespace = "com.kuramabot.kurama_mobile"', gradle)
        self.assertIn("minSdk = 28", gradle)

    def test_dart_package_identity_is_preserved(self):
        pubspec = (ROOT / "mobile/pubspec.yaml").read_text(encoding="utf-8")
        self.assertIn("name: kurama_mobile", pubspec)

    def test_visible_android_name_is_kurama_app(self):
        manifest = (
            ROOT / "mobile/android/app/src/main/AndroidManifest.xml"
        ).read_text(encoding="utf-8")
        self.assertIn('android:label="Kurama App"', manifest)

    def test_api_key_has_no_compiled_production_default(self):
        env = (ROOT / "mobile/lib/app/app_environment.dart").read_text(encoding="utf-8")
        self.assertNotIn("const prodKey", env)
        self.assertNotRegex(env, r"const\s+prodKey\s*=\s*'[^']+'")


if __name__ == "__main__":
    unittest.main()
