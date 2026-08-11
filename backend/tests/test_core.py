"""Fast unit tests for backend logic that do not require a live MySQL server."""

import io
import os
import unittest
import zipfile
from types import SimpleNamespace

# database.py now intentionally requires configuration. A SQLite URL is enough
# for importing route helpers; these tests never create tables or query a DB.
os.environ.setdefault("DATABASE_URL", "sqlite+pysqlite:///:memory:")

from fastapi import HTTPException

from backend import main


class ReadinessTests(unittest.TestCase):
    def test_readiness_matches_frontend_thresholds(self):
        cases = {
            100: "Highly Ready",
            80: "Highly Ready",
            79: "Career Ready",
            60: "Career Ready",
            59: "Developing",
            40: "Developing",
            39: "Beginner",
        }
        for score, expected in cases.items():
            with self.subTest(score=score):
                self.assertEqual(main.get_readiness(score), expected)

    def test_priority_thresholds(self):
        self.assertEqual(main.get_priority(0), "None")
        self.assertEqual(main.get_priority(10), "Low")
        self.assertEqual(main.get_priority(30), "Medium")
        self.assertEqual(main.get_priority(50), "High")
        self.assertEqual(main.get_priority(51), "Critical")


class ResumeValidationTests(unittest.TestCase):
    @staticmethod
    def _docx_bytes():
        buffer = io.BytesIO()
        with zipfile.ZipFile(buffer, "w") as archive:
            archive.writestr("[Content_Types].xml", "<Types />")
            archive.writestr("word/document.xml", "<document />")
        return buffer.getvalue()

    def test_accepts_files_with_valid_signatures(self):
        main._validate_resume_content(b"%PDF-1.7\ncontent", "resume.pdf")
        main._validate_resume_content(self._docx_bytes(), "resume.docx")
        main._validate_resume_content(b"plain text resume", "resume.txt")

    def test_rejects_renamed_or_malformed_documents(self):
        for content, filename in [
            (b"not a PDF", "resume.pdf"),
            (b"not a zip archive", "resume.docx"),
        ]:
            with self.subTest(filename=filename):
                with self.assertRaises(HTTPException) as context:
                    main._validate_resume_content(content, filename)
                self.assertEqual(context.exception.status_code, 422)


class RateLimitTests(unittest.TestCase):
    def setUp(self):
        main._rate_limit_hits.clear()
        self.request = SimpleNamespace(
            client=SimpleNamespace(host="203.0.113.15"),
            headers={},
        )

    def test_limit_returns_retry_after_header(self):
        main._enforce_rate_limit(self.request, "test", 2)
        main._enforce_rate_limit(self.request, "test", 2)

        with self.assertRaises(HTTPException) as context:
            main._enforce_rate_limit(self.request, "test", 2)

        self.assertEqual(context.exception.status_code, 429)
        self.assertIn("Retry-After", context.exception.headers)


if __name__ == "__main__":
    unittest.main()
