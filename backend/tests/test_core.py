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


class WeightedEngineTests(unittest.TestCase):
    ROWS = [
        (1, "Python", "Programming", 80),
        (2, "SQL", "Databases", 60),
        (3, "Kubernetes", "DevOps", 90),
    ]

    def test_perfect_match_scores_100(self):
        user = {1: 80, 2: 60, 3: 90}
        scored = main.compute_career_score(self.ROWS, user, career_name="DevOps Engineer")
        self.assertEqual(scored["match_percentage"], 100)
        self.assertEqual(scored["readiness"], "Highly Ready")
        self.assertEqual(scored["missing_skills"], 0)
        self.assertEqual(len(scored["strengths"]), 3)
        self.assertEqual(scored["critical_gaps"], [])
        self.assertEqual(scored["learning_order"], [])

    def test_empty_profile_scores_zero(self):
        scored = main.compute_career_score(self.ROWS, {})
        self.assertEqual(scored["match_percentage"], 0)
        self.assertEqual(scored["readiness"], "Beginner")
        self.assertEqual(scored["missing_skills"], 3)

    def test_importance_weighting_emphasizes_high_requirement_skills(self):
        # Same raw coverage (min-sum ratio = 80+30+0 = 110/230 = 47.8%),
        # but missing Kubernetes (required 90) must hurt more than SQL.
        low_core = main.compute_career_score(self.ROWS, {1: 80, 2: 30, 3: 0})
        high_core = main.compute_career_score(self.ROWS, {1: 0, 2: 30, 3: 90})
        with self.subTest(case="missing the most-demanded skill scores lower"):
            self.assertLess(
                low_core["match_percentage"],
                high_core["match_percentage"],
            )
        # strengths ratio: meeting Python (80/80) adds its bonus either way
        self.assertEqual(low_core["score_breakdown"]["strengths"], 33.3)

        # coverage-only formula, fully determined:
        # Python met (80/80), SQL half (30/60), Kubernetes zero.
        # weighted coverage = (80*80 + 30*60 + 0*90) / (80^2+60^2+90^2)
        #                   = 8200/18100 = 0.4530...
        # strengths = 1/3; weights renormalize to 0.8 (no edu/resume)
        # final = (0.7*0.4530 + 0.1/3) / 0.8 = 0.4380... -> 44
        self.assertEqual(low_core["match_percentage"], 44)

    def test_education_compatibility_signal(self):
        with self.subTest("no education -> signal dropped (None)"):
            self.assertIsNone(main.education_compatibility(None, "Software Development"))
        with self.subTest("core hit"):
            self.assertEqual(
                main.education_compatibility("B.Tech Computer Science", "Software Development"),
                1.0,
            )
        with self.subTest("broad hit only"):
            self.assertEqual(
                main.education_compatibility("B.Tech Electronics", "Software Development"),
                0.6,
            )
        with self.subTest("unrelated"):
            self.assertEqual(
                main.education_compatibility("B.Com", "Healthcare & Life Sciences"),
                0.25,
            )
        with self.subTest("unknown domain -> neutral"):
            self.assertEqual(main.education_compatibility("MBA", "No Such Domain"), 0.5)

    def test_optional_signals_raise_score_when_present(self):
        user = {1: 80, 2: 30, 3: 0}
        base = main.compute_career_score(self.ROWS, user)
        boosted = main.compute_career_score(
            self.ROWS,
            user,
            career_name="Backend Developer",
            education="B.Tech Computer Science",
            domain_name="Software Development",
            resume_skill_ids={1, 2},
        )
        self.assertGreater(boosted["match_percentage"], base["match_percentage"])
        # education + resume signals now populated
        self.assertEqual(boosted["score_breakdown"]["education"], 100.0)
        self.assertEqual(boosted["score_breakdown"]["resume_evidence"], 66.7)
        self.assertIsNone(base["score_breakdown"]["education"])
        self.assertIsNone(base["score_breakdown"]["resume_evidence"])

    def test_critical_gaps_and_learning_order(self):
        user = {1: 80, 2: 30}
        scored = main.compute_career_score(self.ROWS, user)
        # Kubernetes gap = 90 -> Critical, SQL gap = 30 -> Medium
        self.assertEqual([g["skill"] for g in scored["critical_gaps"]], ["Kubernetes"])
        # learning order: highest required_level first
        self.assertEqual(
            [item["skill"] for item in scored["learning_order"]],
            ["Kubernetes", "SQL"],
        )
        self.assertEqual(scored["learning_order"][0]["step"], 1)

    def test_explanation_mentions_strengths_and_gaps(self):
        user = {1: 80, 2: 30, 3: 0}
        scored = main.compute_career_score(self.ROWS, user, career_name="Backend Developer")
        text = scored["explanation"]
        self.assertIn("strong Python", text)
        self.assertIn("Kubernetes", text)
        self.assertIn("Backend Developer", text)

    def test_explanation_full_match_variant(self):
        user = {1: 80, 2: 60, 3: 90}
        scored = main.compute_career_score(self.ROWS, user, career_name="SRE")
        self.assertIn("meet every core requirement", scored["explanation"])

    def test_request_model_accepts_optional_signals(self):
        # old clients: only skills
        main.SkillGapRequest(skills={1: 50})
        # new clients: education + resume evidence
        req = main.SkillGapRequest(
            skills={1: 50}, education="BCA", resume_skill_ids=[1, 2]
        )
        self.assertEqual(req.education, "BCA")
        self.assertEqual(req.resume_skill_ids, [1, 2])


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
