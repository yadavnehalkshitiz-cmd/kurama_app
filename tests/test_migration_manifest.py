from pathlib import Path
import unittest


class MigrationManifestTests(unittest.TestCase):
    def test_manifest_records_both_exact_sources(self):
        text = (Path(__file__).parents[1] / "docs" / "MIGRATION.md").read_text(
            encoding="utf-8"
        )
        self.assertIn("yadavnehalkshitiz-cmd/kurama_telebot", text)
        self.assertIn("427ac0966321af56cd5bc3fffe26b81134028223", text)
        self.assertIn("yadavnehalkshitiz-cmd/kurama_bot", text)
        self.assertIn("a5e96a0126bc7ff3729300c02c3ceeb1e842bdaa", text)
        self.assertIn("archive/legacy-kurama-bot", text)
        self.assertIn("legacy-kurama-bot-2026-08-12", text)


if __name__ == "__main__":
    unittest.main()
