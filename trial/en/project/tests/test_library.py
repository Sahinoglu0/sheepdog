import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

from library import rules


class RuleTests(unittest.TestCase):
    def setUp(self):
        self.data = {"books": {}, "loans": []}
        rules.add_book(self.data, "K1", "The Little Prince")

    def test_adding_a_book_and_rejecting_a_duplicate_code(self):
        self.assertEqual(self.data["books"]["K1"], "The Little Prince")
        with self.assertRaises(ValueError):
            rules.add_book(self.data, "K1", "Another book")

    def test_loan_period_and_no_double_lending(self):
        self.assertEqual(rules.lend(self.data, "K1", "Ada", "2026-01-01"), 1)
        self.assertEqual(self.data["loans"][0]["due_date"], "2026-01-15")
        with self.assertRaises(ValueError):
            rules.lend(self.data, "K1", "Eve", "2026-01-02")

    def test_unknown_book(self):
        with self.assertRaises(ValueError):
            rules.lend(self.data, "K2", "Ada", "2026-01-01")

    def test_return_on_due_day_and_lend_again(self):
        loan = rules.lend(self.data, "K1", "Ada", "2026-01-01")
        self.assertEqual(rules.take_back(self.data, loan, "2026-01-15"), 0)
        self.assertEqual(rules.lend(self.data, "K1", "Eve", "2026-01-16"), 2)

    def test_late_return(self):
        loan = rules.lend(self.data, "K1", "Ada", "2026-01-01")
        self.assertEqual(rules.take_back(self.data, loan, "2026-01-18"), 3)

    def test_return_before_the_loan_date_is_rejected(self):
        loan = rules.lend(self.data, "K1", "Ada", "2026-01-01")
        with self.assertRaises(ValueError):
            rules.take_back(self.data, loan, "2025-12-31")
        self.assertIsNone(self.data["loans"][0]["returned"])

    def test_second_return_is_rejected(self):
        loan = rules.lend(self.data, "K1", "Ada", "2026-01-01")
        rules.take_back(self.data, loan, "2026-01-15")
        with self.assertRaises(ValueError):
            rules.take_back(self.data, loan, "2026-01-16")


class CommandTests(unittest.TestCase):
    def test_add_lend_and_return_in_separate_processes(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / "records.json"
            def run(*args):
                return subprocess.run(
                    [sys.executable, "-m", "library", "--data", str(path)] + list(args),
                    capture_output=True, text=True, encoding="utf-8",
                    env=dict(os.environ, PYTHONIOENCODING="utf-8"),
                )
            self.assertEqual(run("add", "K1", "The Little Prince").returncode, 0)
            self.assertEqual(run("lend", "K1", "Ada", "--date", "2026-01-01").returncode, 0)
            result = run("return", "1", "--date", "2026-01-18")
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("Late: 3 days", result.stdout)
            self.assertEqual(json.loads(path.read_text(encoding="utf-8"))["loans"][0]["returned"], "2026-01-18")
            before = path.read_bytes()
            self.assertEqual(run("return", "1", "--date", "2026-01-19").returncode, 1)
            self.assertEqual(path.read_bytes(), before)


if __name__ == "__main__":
    unittest.main()
