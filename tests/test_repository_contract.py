from pathlib import Path
import unittest


ROOT = Path(__file__).parents[1]


class RepositoryContractTests(unittest.TestCase):
    def test_forbidden_runtime_files_are_not_present(self):
        forbidden_names = {
            ".env",
            "cookies.txt",
            "key.properties",
            "kuramabot-release.jks",
            "user_configs.json",
            "ffmpeg.exe",
        }
        found = [
            path.relative_to(ROOT).as_posix()
            for path in ROOT.rglob("*")
            if path.is_file() and ".git" not in path.parts and path.name in forbidden_names
        ]
        self.assertEqual([], found)

    def test_telegram_entrypoints_are_absent(self):
        for relative in (
            "bot.py",
            "handlers.py",
            "keyboards.py",
            "senders.py",
            "run_bot.py",
        ):
            with self.subTest(relative=relative):
                self.assertFalse((ROOT / relative).exists(), relative)
                self.assertFalse((ROOT / "backend" / relative).exists(), relative)


if __name__ == "__main__":
    unittest.main()
