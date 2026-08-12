// =====================================================
// SCORING LOGIC
// =====================================================
//
// Pure functions — no React, no side effects. Keeping the
// math here makes it easy to unit-test (see P2 testing plan).
// Both functions mirror the original logic in App.jsx 1:1.

// =====================================================
// COMPUTE RESULTS FOR THE SELECTED CAREER
// =====================================================
//
// requiredSkills: [{ skill_id, skill, category, required_level }]
// skillLevels:    { [skill_id]: number (0-100) }
//
// Returns { matchScore, readiness, gaps, strongSkills, skillGaps }
// or null when there are no skills to analyze.

export { dedupeSkills, selectMainSkills } from "./mainSkills";

export function computeResults(requiredSkills, skillLevels = {}) {
    if (requiredSkills.length === 0) {
        return null;
    }

    let totalRequired = 0;
    let totalCurrent = 0;

    const gaps = requiredSkills.map((skill) => {
        const required = Number(skill.required_level) || 0;
        const current = Number(skillLevels[skill.skill_id]) || 0;
        const gap = Math.max(required - current, 0);

        totalRequired += required;
        totalCurrent += Math.min(current, required);

        return {
            ...skill,
            current,
            gap,
        };
    });

    // =================================================
    // MATCH SCORE
    // =================================================

    const matchScore =
        totalRequired > 0
            ? Math.round(
                  (totalCurrent / totalRequired) * 100
              )
            : 0;

    // =================================================
    // STRONG SKILLS
    // =================================================

    const strongSkills = gaps.filter(
        (skill) => skill.gap === 0
    );

    // =================================================
    // SKILL GAPS
    // =================================================

    const skillGaps = gaps
        .filter((skill) => skill.gap > 0)
        .sort((a, b) => b.gap - a.gap);

    // =================================================
    // READINESS
    // =================================================

    let readiness = "";

    if (matchScore >= 80) {
        readiness = "Highly Ready";
    } else if (matchScore >= 60) {
        readiness = "Career Ready";
    } else if (matchScore >= 40) {
        readiness = "Developing";
    } else {
        readiness = "Beginner";
    }

    return {
        matchScore,
        readiness,
        gaps,
        strongSkills,
        skillGaps,
    };
}

// =====================================================
// COMPUTE ALTERNATIVE CAREER RECOMMENDATIONS
// =====================================================
//
// domainCareerSkills: careers of the selected domain, each with
//                     a `skills` array (same shape as requiredSkills)
// selectedCareer:     id of the career being analyzed (excluded)
// skillLevels:        { [skill_id]: number }
//
// Returns up to 3 careers sorted by match score.

export function computeCareerRecommendations(
    domainCareerSkills,
    selectedCareer,
    skillLevels = {}
) {
    if (
        !selectedCareer ||
        domainCareerSkills.length === 0
    ) {
        return [];
    }

    return domainCareerSkills
        .filter(
            (career) =>
                String(career.id) !== String(selectedCareer)
        )
        .map((career) => {
            const overlapping = (career.skills || [])
                .map((skill) => {
                    const current =
                        Number(skillLevels[skill.skill_id]) ||
                        0;

                    return {
                        ...skill,
                        current,
                        gap: Math.max(
                            skill.required_level - current,
                            0
                        ),
                    };
                })
                .filter(
                    (skill) =>
                        skill.current > 0 ||
                        skill.required_level > 0
                );

            const totalRequired = overlapping.reduce(
                (sum, skill) =>
                    sum + Number(skill.required_level),
                0
            );

            const totalCurrent = overlapping.reduce(
                (sum, skill) =>
                    sum +
                    Math.min(
                        skill.current,
                        Number(skill.required_level)
                    ),
                0
            );

            return {
                ...career,
                overlapping,
                matchScore:
                    totalRequired > 0
                        ? Math.round(
                              (totalCurrent / totalRequired) *
                                  100
                          )
                        : 0,
            };
        })
        .filter((career) => career.overlapping.length > 0)
        .sort((a, b) => b.matchScore - a.matchScore)
        .slice(0, 3);
}
