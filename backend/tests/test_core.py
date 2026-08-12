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
from pydantic import ValidationError

from backend import main
from backend.skill_catalog import dedupe_skills, select_main_skills


class MainSkillCatalogTests(unittest.TestCase):
    def test_data_scientist_keeps_only_core_skills(self):
        noisy = [
            {"skill_id": 1, "name": "Python", "required_level": 95},
            {"skill_id": 2, "name": "Pandas", "required_level": 92},
            {"skill_id": 3, "name": "pandas", "required_level": 80},
            {"skill_id": 4, "name": "NumPy", "required_level": 90},
            {"skill_id": 5, "name": "numpy", "required_level": 70},
            {"skill_id": 6, "name": "Java", "required_level": 90},
            {"skill_id": 7, "name": "C++", "required_level": 85},
            {"skill_id": 8, "name": "C#", "required_level": 85},
            {"skill_id": 9, "name": "Machine Learning", "required_level": 95},
            {"skill_id": 10, "name": "SQL", "required_level": 85},
            {"skill_id": 11, "name": "Excel", "required_level": 70},
            {"skill_id": 12, "name": "Engineering Drawing", "required_level": 90},
        ]

        selected = select_main_skills("Data Scientist", noisy)
        names = [item["name"] for item in selected]

        self.assertIn("Python", names)
        self.assertIn("Pandas", names)
        self.assertIn("Machine Learning", names)
        self.assertNotIn("Java", names)
        self.assertNotIn("C++", names)
        self.assertNotIn("C#", names)
        self.assertNotIn("Excel", names)
        self.assertNotIn("Engineering Drawing", names)
        self.assertNotIn("NumPy", names)
        self.assertLessEqual(len(selected), 6)
        self.assertEqual(len([n for n in names if n.lower() == "pandas"]), 1)

    def test_dedupe_keeps_higher_required_level(self):
        unique = dedupe_skills(
            [
                {"name": "Pandas", "required_level": 70},
                {"name": "pandas", "required_level": 92},
            ]
        )
        self.assertEqual(len(unique), 1)
        self.assertEqual(unique[0]["required_level"], 92)

    def test_unlisted_career_drops_filler_languages(self):
        selected = select_main_skills(
            "Cloud Engineer",
            [
                {"name": "AWS", "required_level": 90},
                {"name": "Docker", "required_level": 85},
                {"name": "Java", "required_level": 80},
                {"name": "Engineering Drawing", "required_level": 90},
                {"name": "Linux", "required_level": 80},
            ],
            domain_name="Cloud Computing",
        )
        names = [item["name"] for item in selected]
        self.assertEqual(names, ["AWS", "Docker", "Linux"])


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


class RoadmapInputTests(unittest.TestCase):
    def test_rejects_oversized_roadmap_input(self):
        with self.assertRaises(ValidationError):
            main.AiRoadmapRequest(
                career_name="Data Engineer",
                skill_gaps=[{"name": "Python"}] * 11,
            )

    def test_rejects_out_of_range_skill_levels(self):
        with self.assertRaises(ValidationError):
            main.SkillGapItem(name="Python", current=101)


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
