from pathlib import Path
import ast
import unittest


ROOT = Path(__file__).parents[1]
BACKEND = ROOT / "backend"


class BackendBoundaryTests(unittest.TestCase):
    def test_requirements_exclude_telegram(self):
        requirements = (BACKEND / "requirements.txt").read_text(
            encoding="utf-8"
        ).lower()
        self.assertNotIn("python-telegram-bot", requirements)

    def test_backend_does_not_import_telegram_or_bot_modules(self):
        forbidden = {"telegram", "bot", "handlers", "keyboards", "senders", "run_bot"}
        found = []
        for path in BACKEND.glob("*.py"):
            tree = ast.parse(
                path.read_text(encoding="utf-8-sig"), filename=str(path)
            )
            for node in ast.walk(tree):
                if isinstance(node, ast.Import):
                    for alias in node.names:
                        root = alias.name.split(".")[0]
                        if root in forbidden:
                            found.append((path.name, root))
                elif isinstance(node, ast.ImportFrom) and node.module:
                    root = node.module.split(".")[0]
                    if root in forbidden:
                        found.append((path.name, root))
        self.assertEqual([], found)

    def test_backend_config_has_no_telegram_runtime_settings(self):
        config = (BACKEND / "config.py").read_text(encoding="utf-8-sig")
        for name in (
            "TELEGRAM_BOT_TOKEN",
            "TELEGRAM_LIMIT",
            "ADMIN_CHAT_ID",
            "LAPTOP_FOLDER",
        ):
            with self.subTest(name=name):
                self.assertNotIn(name, config)


if __name__ == "__main__":
    unittest.main()
