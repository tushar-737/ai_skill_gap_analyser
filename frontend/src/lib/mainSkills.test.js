import { describe, expect, it } from "vitest";
import { selectMainSkills } from "./mainSkills";

const noisy = [
    { skill_id: 1, name: "Python", required_level: 95 },
    { skill_id: 2, name: "Pandas", required_level: 92 },
    { skill_id: 3, name: "pandas", required_level: 80 },
    { skill_id: 4, name: "NumPy", required_level: 90 },
    { skill_id: 5, name: "numpy", required_level: 70 },
    { skill_id: 6, name: "Java", required_level: 90 },
    { skill_id: 7, name: "C++", required_level: 85 },
    { skill_id: 8, name: "Machine Learning", required_level: 95 },
    { skill_id: 9, name: "SQL", required_level: 85 },
    { skill_id: 10, name: "Excel", required_level: 70 },
    { skill_id: 11, name: "Statistics", required_level: 88 },
    { skill_id: 12, name: "R", required_level: 80 },
    { skill_id: 13, name: "Data Analysis", required_level: 82 },
    { skill_id: 14, name: "Matplotlib", required_level: 78 },
    { skill_id: 15, name: "Supervised Learning", required_level: 90 },
    { skill_id: 16, name: "Unsupervised Learning", required_level: 85 },
    { skill_id: 17, name: "Feature Engineering", required_level: 85 },
    { skill_id: 18, name: "Statistics & Probability", required_level: 90 },
    { skill_id: 19, name: "Pandas & NumPy", required_level: 90 },
    { skill_id: 20, name: "Data Visualization", required_level: 80 },
    { skill_id: 21, name: "Scikit-learn", required_level: 88 },
];

describe("selectMainSkills", () => {
    it("keeps the short unique Data Scientist list", () => {
        const names = selectMainSkills(
            "Data Scientist",
            noisy,
            "Data Science & Analytics"
        ).map((skill) => skill.name);

        expect(names).toEqual([
            "Python",
            "R",
            "SQL",
            "Statistics",
            "Pandas",
            "NumPy",
            "Data Analysis",
            "Matplotlib",
            "Machine Learning",
            "Scikit-learn",
        ]);
        expect(names).not.toContain("Java");
        expect(names).not.toContain("Supervised Learning");
        expect(names).not.toContain("Statistics & Probability");
        expect(names).not.toContain("Pandas & NumPy");
        expect(names.filter((name) => name.toLowerCase() === "pandas")).toHaveLength(1);
        expect(names.filter((name) => name.toLowerCase() === "numpy")).toHaveLength(1);
    });

    it("does not show every ML sub-skill for Data Analyst", () => {
        const names = selectMainSkills(
            "Data Analyst",
            noisy,
            "Data Science & Analytics"
        ).map((skill) => skill.name);

        expect(names).toEqual([
            "Python",
            "R",
            "SQL",
            "Statistics",
            "Pandas",
            "NumPy",
            "Data Analysis",
            "Matplotlib",
        ]);
        expect(names).not.toContain("Machine Learning");
        expect(names).not.toContain("Excel");
    });
});
