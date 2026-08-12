import { describe, expect, it } from "vitest";

import {
    computeResults,
    computeCareerRecommendations,
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

describe("computeResults", () => {
    it("returns null when there are no skills", () => {
        expect(computeResults([], {})).toBeNull();
    });

    it("computes match score, gaps and strong skills", () => {
        const result = computeResults(skills, { 1: 80, 2: 30 });

        // Weighted engine: coverage = (80*80 + 30*60) / (80²+60²) = 0.82
        // strengths = 1/2 skills met = 0.5
        // final = (0.7*0.82 + 0.1*0.5) / 0.8 = 0.78 → 78
        expect(result.matchScore).toBe(78);
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
        const mid = { 1: 60, 2: 50 }; // coverage 0.78 → final ≈ 68 → Career Ready

        expect(computeResults(skills, allMax).readiness).toBe("Highly Ready");
        expect(computeResults(skills, mid).readiness).toBe("Career Ready");
        expect(computeResults(skills, { 1: 50, 2: 35 }).readiness).toBe("Developing");
        expect(computeResults(skills, { 1: 20, 2: 10 }).readiness).toBe("Beginner");
    });

    it("exposes a score breakdown matching the weighted formula", () => {
        const result = computeResults(skills, { 1: 80, 2: 30 });

        expect(result.scoreBreakdown.skillCoverage).toBe(82);
        expect(result.scoreBreakdown.strengths).toBe(50);
        // education / resume signals not provided → dropped
        expect(result.scoreBreakdown.education).toBeNull();
        expect(result.scoreBreakdown.resumeEvidence).toBeNull();
    });

    it("education compatibility raises the score for a matching domain", () => {
        const base = computeResults(skills, { 1: 80, 2: 30 });
        const boosted = computeResults(skills, { 1: 80, 2: 30 }, {
            education: "B.Tech Computer Science",
            domainName: "Software Development",
        });

        expect(boosted.matchScore).toBeGreaterThan(base.matchScore);
        expect(boosted.scoreBreakdown.education).toBe(100);
    });

    it("learning order puts the career's most-demanded gaps first", () => {
        const rows = [
            { ...skills[0], required_level: 50 },
            { ...skills[1], required_level: 90 },
            { skill_id: 3, skill: "Git", category: "Tools", required_level: 40 },
        ];
        const result = computeResults(rows, { 1: 10, 2: 10, 3: 10 });

        expect(result.learningOrder.map((s) => s.required_level)).toEqual([90, 50, 40]);
        expect(result.learningOrder[0].step).toBe(1);
        expect(result.learningOrder[0].skill).toBe("SQL");
        // SQL gap = 80 → Critical; Python gap = 40 → High; Git gap = 30 → Medium
        expect(result.criticalGaps.map((s) => s.skill)).toEqual(["SQL", "Python"]);
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
