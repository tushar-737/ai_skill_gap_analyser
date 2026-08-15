// =====================================================
// DEMO PROFILE (P5) — "Try Demo Assessment"
// =====================================================
//
// A realistic, pre-filled assessment so a teacher/examiner can see
// the full system (results, ranking, learning order, roadmap) with
// one click — no manual slider work during a viva.
//
// Matching is done case-insensitively by NAME SUBSTRING so it keeps
// working even if database auto-increment IDs change between setups.

export const DEMO_PROFILE = {
    // Education program whose name contains this (e.g. "B.Tech Computer Science")
    educationIncludes: "b.tech computer",

    // Domain whose name contains this (e.g. "Software Development")
    domainIncludes: "software",

    // Career whose name contains this (e.g. "Full Stack Developer")
    careerIncludes: "full stack",

    // Skill levels by skill-name substring -> level (0-100).
    // First matching substring wins per skill.
    levelsBySkill: [
        ["html", 85],
        ["javascript", 78],
        ["react", 80],
        ["typescript", 55],
        ["node", 70],
        ["rest", 65],
        ["postgres", 45],
        ["mongo", 30],
        ["git", 72],
        ["docker", 25],
        ["figma", 40],
    ],
};

/**
 * Resolve the demo level for a skill row ({ skill, name }).
 * Returns 0 when the profile has no opinion on the skill.
 */
export function demoLevelForSkill(skill) {
    const name = String(skill.skill || skill.name || "").toLowerCase();
    for (const [needle, level] of DEMO_PROFILE.levelsBySkill) {
        if (name.includes(needle)) return level;
    }
    return 0;
}

/** Case-insensitive "name contains" lookup in a list of {id, name}. */
export function findByIncludes(list, needle) {
    if (!needle) return null;
    const lower = needle.toLowerCase();
    return (
        (list || []).find((item) =>
            String(item.name || "").toLowerCase().includes(lower)
        ) || null
    );
}
