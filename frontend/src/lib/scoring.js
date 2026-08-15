// =====================================================
// SCORING LOGIC — weighted career-match engine
// =====================================================
//
// Pure functions — no React, no side effects. Unit-tested in
// scoring.test.js. This file mirrors backend/main.py's engine
// (compute_career_score) 1:1 so the instant client-side score
// matches what the API would return:
//
//   Career Match =
//       0.70 * importance-weighted skill coverage
//     + 0.10 * strengths ratio (required skills fully met)
//     + 0.10 * education compatibility (education <-> domain)
//     + 0.10 * resume evidence (resume-backed skills)
//
// Importance weighting: each skill's weight is required_level^2,
// so the skills a career demands hardest dominate the score.
// Signals that are not provided (education / resume) drop out and
// the remaining weights renormalize.

const ENGINE_WEIGHTS = {
    skillCoverage: 0.7,
    strengths: 0.1,
    education: 0.1,
    resumeEvidence: 0.1,
};

const ENGINE_FORMULA =
    "0.70*skill_coverage + 0.10*strengths + 0.10*education + " +
    "0.10*resume_evidence (missing signals drop out and weights renormalize)";

// Same keyword affinity table as backend/main.py
const EDUCATION_DOMAIN_AFFINITY = {
    "Artificial Intelligence & Data Science": {
        core: ["data science", "computer", "information technology", "artificial intelligence", "machine learning", "statistics", "bca", "mca"],
        broad: ["b.tech", "m.tech", "engineering", "mathematics", "physics", "science"],
    },
    "Software Development": {
        core: ["computer", "software", "information technology", "bca", "mca"],
        broad: ["b.tech", "m.tech", "electronics", "engineering", "science"],
    },
    "Cloud & DevOps": {
        core: ["computer", "information technology", "cloud", "bca", "mca", "network"],
        broad: ["b.tech", "m.tech", "electronics", "electrical", "engineering"],
    },
    Cybersecurity: {
        core: ["cyber", "security", "computer", "information technology", "bca", "mca", "network"],
        broad: ["b.tech", "m.tech", "electronics", "engineering"],
    },
    "UI/UX & Product Design": {
        core: ["design", "b.des", "fine arts", "bfa", "architecture", "animation"],
        broad: ["computer", "arts", "media"],
    },
    "Digital Marketing": {
        core: ["marketing", "bba", "mba", "pgdm", "business"],
        broad: ["commerce", "communication", "journalism", "arts", "media"],
    },
    "Finance & Accounting": {
        core: ["commerce", "b.com", "m.com", "finance", "accounting", "economics", "chartered accountant"],
        broad: ["business", "bba", "mba", "mathematics", "statistics"],
    },
    "Mechanical & Core Engineering": {
        core: ["mechanical", "civil", "electrical", "automobile", "production"],
        broad: ["engineering", "b.tech", "m.tech", "diploma"],
    },
    "Healthcare & Life Sciences": {
        core: ["mbbs", "pharm", "nursing", "biotech", "medicine", "health", "physiotherapy", "dental"],
        broad: ["biology", "life science", "science", "chemistry"],
    },
    "Content & Media": {
        core: ["journalism", "mass communication", "media", "literature"],
        broad: ["english", "arts", "communication", "design", "marketing"],
    },
};

function clampLevel(value) {
    const n = Number(value);
    if (Number.isNaN(n)) return 0;
    return Math.max(0, Math.min(100, n));
}

export function educationCompatibility(education, domainName) {
    if (!education || !String(education).trim()) return null;

    const text = String(education).toLowerCase();
    const affinity = EDUCATION_DOMAIN_AFFINITY[domainName || ""];
    if (!affinity) return 0.5;

    if (affinity.core.some((k) => text.includes(k))) return 1.0;
    if (affinity.broad.some((k) => text.includes(k))) return 0.6;
    return 0.25;
}

export function getPriorityLabel(gap) {
    if (gap <= 0) return "None";
    if (gap <= 10) return "Low";
    if (gap <= 30) return "Medium";
    if (gap <= 50) return "High";
    return "Critical";
}

function getReadinessLabel(matchScore) {
    if (matchScore >= 80) return "Highly Ready";
    if (matchScore >= 60) return "Career Ready";
    if (matchScore >= 40) return "Developing";
    return "Beginner";
}

function humanJoin(items) {
    if (items.length <= 1) return items[0] || "";
    return items.slice(0, -1).join(", ") + " and " + items[items.length - 1];
}

// =====================================================
// CAREER EXPLANATION (P4) — deterministic "Why this career?"
// =====================================================

export function buildCareerExplanation(careerName, strongSkills, skillGaps, matchScore, readiness) {
    const topStrengths = [...(strongSkills || [])]
        .sort((a, b) => b.current - a.current || b.required_level - a.required_level)
        .slice(0, 3)
        .map((s) => s.skill || s.name)
        .filter(Boolean);

    const topGaps = [...(skillGaps || [])]
        .sort((a, b) => b.required_level - a.required_level || b.gap - a.gap)
        .slice(0, 2)
        .map((s) => s.skill || s.name)
        .filter(Boolean);

    const parts = [];

    if (topStrengths.length > 0) {
        parts.push(`You already have strong ${humanJoin(topStrengths)} skills.`);
    } else {
        parts.push("You have not yet built up the core skills for this role.");
    }

    if (topGaps.length > 0) {
        const verb = topGaps.length === 1 ? "is" : "are";
        const pronoun = topGaps.length === 1 ? "this skill" : "these skills";
        parts.push(
            `However, your ${humanJoin(topGaps)} ${verb} below the required level. ` +
                `Improving ${pronoun} would significantly increase your readiness as a ${careerName}.`
        );
    } else if (topStrengths.length > 0) {
        parts.push(
            `You meet every core requirement — with a ${matchScore}% match you are ${String(
                readiness
            ).toLowerCase()} for a ${careerName} role.`
        );
    }

    return parts.join(" ");
}

// =====================================================
// CORE ENGINE — score a set of required-skill rows
// =====================================================
//
// rows:        [{ skill_id, skill, category, required_level }]
// skillLevels: { [skill_id]: number (0-100) }
// options:     { education, domainName, resumeSkillIds }

function scoreRows(rows, skillLevels = {}, options = {}) {
    const resumeIds = options.resumeSkillIds
        ? new Set([...options.resumeSkillIds].map(String))
        : null;

    let weightedNum = 0;
    let weightedDen = 0;
    let skillsMet = 0;
    let resumeHits = 0;

    const gaps = rows.map((skill) => {
        const required = clampLevel(skill.required_level);
        const current = clampLevel(skillLevels[skill.skill_id]);

        if (required > 0) {
            weightedNum += Math.min(current, required) * required;
            weightedDen += required * required;
        }

        if (resumeIds && resumeIds.has(String(skill.skill_id)) && current > 0) {
            resumeHits += 1;
        }

        const gap = Math.max(required - current, 0);
        if (gap === 0) skillsMet += 1;

        return {
            ...skill,
            current,
            gap,
            priority: getPriorityLabel(gap),
        };
    });

    const totalSkills = rows.length;

    // Signals ----------------------------------------------------------
    const coverage = weightedDen > 0 ? weightedNum / weightedDen : 0;
    const strengthsRatio = totalSkills > 0 ? skillsMet / totalSkills : 0;
    const educationScore = educationCompatibility(options.education, options.domainName);
    const resumeScore = resumeIds && totalSkills > 0 ? resumeHits / totalSkills : null;

    // Weighted combination with renormalization ------------------------
    const parts = [
        [coverage, ENGINE_WEIGHTS.skillCoverage],
        [strengthsRatio, ENGINE_WEIGHTS.strengths],
    ];
    if (educationScore !== null) parts.push([educationScore, ENGINE_WEIGHTS.education]);
    if (resumeScore !== null) parts.push([resumeScore, ENGINE_WEIGHTS.resumeEvidence]);

    const totalWeight = parts.reduce((sum, [, w]) => sum + w, 0);
    const final = totalWeight > 0 ? parts.reduce((sum, [v, w]) => sum + v * w, 0) / totalWeight : 0;

    const matchScore = Math.round(final * 100);

    return {
        gaps,
        matchScore,
        readiness: getReadinessLabel(matchScore),
        scoreBreakdown: {
            skillCoverage: Math.round(coverage * 1000) / 10,
            strengths: Math.round(strengthsRatio * 1000) / 10,
            education: educationScore === null ? null : Math.round(educationScore * 1000) / 10,
            resumeEvidence: resumeScore === null ? null : Math.round(resumeScore * 1000) / 10,
            weights: { ...ENGINE_WEIGHTS },
            formula: ENGINE_FORMULA,
        },
    };
}

// =====================================================
// COMPUTE RESULTS FOR THE SELECTED CAREER
// =====================================================

export function computeResults(requiredSkills, skillLevels = {}, options = {}) {
    if (requiredSkills.length === 0) {
        return null;
    }

    const { gaps, matchScore, readiness, scoreBreakdown } = scoreRows(
        requiredSkills,
        skillLevels,
        options
    );

    const strongSkills = gaps
        .filter((skill) => skill.gap === 0)
        .sort((a, b) => b.current - a.current || b.required_level - a.required_level);

    const skillGaps = gaps
        .filter((skill) => skill.gap > 0)
        .sort((a, b) => b.gap - a.gap || b.required_level - a.required_level);

    // Recommended learning order (P2): the career's most-demanded
    // missing skills first, so learning front-loads maximum impact.
    const learningOrder = [...skillGaps]
        .sort((a, b) => b.required_level - a.required_level || b.gap - a.gap)
        .map((skill, index) => ({
            step: index + 1,
            ...skill,
            reason: `Required at ${skill.required_level}% — close a ${skill.gap}-point gap`,
        }));

    const criticalGaps = skillGaps.filter(
        (skill) => skill.priority === "Critical" || skill.priority === "High"
    );

    return {
        matchScore,
        readiness,
        gaps,
        strongSkills,
        skillGaps,
        learningOrder,
        criticalGaps,
        scoreBreakdown,
    };
}

// =====================================================
// COMPUTE ALTERNATIVE CAREER RECOMMENDATIONS (ranked)
// =====================================================
//
// domainCareerSkills: careers of the selected domain, each with
//                     a `skills` array (same shape as requiredSkills)
// selectedCareer:     id of the career being analyzed (excluded)
// skillLevels:        { [skill_id]: number }
// options:            { education, domainName } (extra engine signals)
//
// Returns up to 3 careers ranked by the weighted match score.

export function computeCareerRecommendations(
    domainCareerSkills,
    selectedCareer,
    skillLevels = {},
    options = {}
) {
    if (!selectedCareer || domainCareerSkills.length === 0) {
        return [];
    }

    return domainCareerSkills
        .filter((career) => String(career.id) !== String(selectedCareer))
        .map((career) => {
            const rows = career.skills || [];

            const overlapping = rows
                .map((skill) => {
                    const current = clampLevel(skillLevels[skill.skill_id]);

                    return {
                        ...skill,
                        current,
                        gap: Math.max(Number(skill.required_level) - current, 0),
                    };
                })
                .filter((skill) => skill.current > 0 || skill.required_level > 0);

            const { matchScore, readiness } = scoreRows(rows, skillLevels, options);

            return {
                ...career,
                overlapping,
                matchScore,
                readiness,
            };
        })
        .filter((career) => career.overlapping.length > 0)
        .sort((a, b) => b.matchScore - a.matchScore)
        .slice(0, 3);
}
