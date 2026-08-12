import { describe, expect, it } from "vitest";
import { selectMainSkills } from "./mainSkills";

const noisyDataScientist = [
    { skill_id: 1, name: "Python", required_level: 95 },
    { skill_id: 2, name: "Pandas", required_level: 92 },
    { skill_id: 3, name: "pandas", required_level: 80 },
    { skill_id: 4, name: "NumPy", required_level: 90 },
    { skill_id: 5, name: "numpy", required_level: 70 },
    { skill_id: 6, name: "Java", required_level: 90 },
    { skill_id: 7, name: "C++", required_level: 85 },
    { skill_id: 8, name: "C#", required_level: 85 },
    { skill_id: 9, name: "Machine Learning", required_level: 95 },
    { skill_id: 10, name: "SQL", required_level: 85 },
    { skill_id: 11, name: "Excel", required_level: 70 },
    { skill_id: 12, name: "Scikit-learn", required_level: 90 },
    { skill_id: 13, name: "Statistics", required_level: 88 },
];

describe("selectMainSkills", () => {
    it("keeps only the main Data Scientist skills", () => {
        const selected = selectMainSkills(
            "Data Scientist",
            noisyDataScientist,
            "Data Science & Analytics"
        );
        const names = selected.map((skill) => skill.name);

        expect(names).toEqual([
            "Python",
            "SQL",
            "Pandas",
            "Machine Learning",
            "Statistics",
            "Scikit-learn",
        ]);
        expect(names).not.toContain("NumPy");
        expect(names).not.toContain("Java");
        expect(names).not.toContain("C++");
        expect(names.filter((name) => name.toLowerCase() === "pandas")).toHaveLength(1);
    });

    it("matches Senior Data Scientist by career name", () => {
        const selected = selectMainSkills("Senior Data Scientist", noisyDataScientist);
        expect(selected.map((skill) => skill.name)).toContain("Python");
        expect(selected.map((skill) => skill.name)).not.toContain("Java");
    });
});
