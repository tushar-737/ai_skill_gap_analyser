import { describe, expect, it } from "vitest";

import {
    computeResults,
    computeCareerRecommendations,
    dedupeSkills,
} from "./scoring";

// =====================================================
// computeResults
// =====================================================

const skills = [
    {
        skill_id: 1,
        skill: "Python",
        category: "Programming",
        required_level: 80,
    },
    {
        skill_id: 2,
        skill: "SQL",
        category: "Data",
        required_level: 60,
    },
];

describe("dedupeSkills", () => {
    it("keeps one row when the same library is listed twice", () => {
        const unique = dedupeSkills([
            { skill_id: 1, name: "Pandas", required_level: 80 },
            { skill_id: 2, name: "pandas", required_level: 92 },
            { skill_id: 3, name: "NumPy", required_level: 90 },
            { skill_id: 4, name: "numpy", required_level: 70 },
        ]);

        expect(unique).toHaveLength(2);
        expect(unique.find((s) => s.name.toLowerCase() === "pandas").required_level).toBe(92);
        expect(unique.find((s) => s.name.toLowerCase() === "numpy").skill_id).toBe(3);
    });
});

describe("computeResults", () => {
    it("returns null when there are no skills", () => {
        expect(computeResults([], {})).toBeNull();
    });

    it("computes match score, gaps and strong skills", () => {
        const result = computeResults(skills, { 1: 80, 2: 30 });

        // (80 + 30) / (80 + 60) = 110/140 ≈ 78.57 → 79
        expect(result.matchScore).toBe(79);
        expect(result.readiness).toBe("Career Ready");

        expect(result.strongSkills).toHaveLength(1);
        expect(result.strongSkills[0].skill).toBe("Python");

        expect(result.skillGaps).toHaveLength(1);
        expect(result.skillGaps[0].skill).toBe("SQL");
        expect(result.skillGaps[0].gap).toBe(30);
    });

    it("sorts skill gaps from largest to smallest", () => {
        const result = computeResults(
            [
                { ...skills[0], required_level: 50 },
                { ...skills[1], required_level: 90 },
                { skill_id: 3, skill: "Git", category: "Tools", required_level: 40 },
            ],
            { 1: 10, 2: 10, 3: 10 }
        );

        const gaps = result.skillGaps.map((s) => s.gap);
        expect(gaps).toEqual([...gaps].sort((a, b) => b - a));
    });

    it("caps current level at the required level (no over-scoring)", () => {
        const result = computeResults(skills, { 1: 100, 2: 100 });

        expect(result.matchScore).toBe(100);
        expect(result.strongSkills).toHaveLength(2);
        expect(result.skillGaps).toHaveLength(0);
    });

    it("returns Beginner for a zero-score profile", () => {
        const result = computeResults(skills, {});

        expect(result.matchScore).toBe(0);
        expect(result.readiness).toBe("Beginner");
    });

    it("readiness tiers are applied correctly", () => {
        const allMax = { 1: 80, 2: 60 };
        const mid = { 1: 50, 2: 40 }; // 90/140 = 64.3 → Career Ready

        expect(computeResults(skills, allMax).readiness).toBe("Highly Ready");
        expect(computeResults(skills, mid).readiness).toBe("Career Ready");
        expect(computeResults(skills, { 1: 40, 2: 20 }).readiness).toBe("Developing");
    });
});

// =====================================================
// computeCareerRecommendations
// =====================================================

const domainCareers = [
    {
        id: 10,
        name: "Data Scientist",
        skills: [
            { skill_id: 1, required_level: 80 },
            { skill_id: 2, required_level: 60 },
        ],
    },
    {
        id: 11,
        name: "Data Analyst",
        skills: [
            { skill_id: 1, required_level: 60 },
            { skill_id: 2, required_level: 80 },
        ],
    },
    {
        id: 12,
        name: "ML Engineer",
        skills: [
            { skill_id: 1, required_level: 90 },
            { skill_id: 3, required_level: 70 },
        ],
    },
    {
        id: 13,
        name: "Unrelated Career",
        // required_level 0 → no meaningful overlap (current 0,
        // required 0), so this career must be filtered out
        skills: [{ skill_id: 99, required_level: 0 }],
    },
];

describe("computeCareerRecommendations", () => {
    it("returns an empty list without a selected career", () => {
        expect(
            computeCareerRecommendations(domainCareers, "", {})
        ).toEqual([]);
    });

    it("excludes the selected career", () => {
        const recs = computeCareerRecommendations(
            domainCareers,
            "10",
            { 1: 80, 2: 60 }
        );

        expect(recs.some((c) => c.id === 10)).toBe(false);
    });

    it("sorts by match score descending and caps at 3", () => {
        const recs = computeCareerRecommendations(
            domainCareers,
            "10",
            { 1: 80, 2: 60, 3: 70 }
        );

        expect(recs.length).toBeLessThanOrEqual(3);
        const scores = recs.map((c) => c.matchScore);
        expect(scores).toEqual([...scores].sort((a, b) => b - a));
    });

    it("filters out careers with no overlapping skills", () => {
        const recs = computeCareerRecommendations(
            domainCareers,
            "10",
            { 1: 80, 2: 60 }
        );

        expect(recs.some((c) => c.id === 13)).toBe(false);
    });

    it("includes overlapping skills with current levels and gaps", () => {
        const recs = computeCareerRecommendations(
            domainCareers,
            "10",
            { 1: 50, 2: 0 }
        );

        const analyst = recs.find((c) => c.id === 11);

        expect(analyst).toBeDefined();
        expect(analyst.overlapping).toHaveLength(2);
        expect(analyst.overlapping[0].current).toBe(50);
        expect(analyst.overlapping[0].gap).toBe(10);
    });
});
