
import { useState } from "react";

import { buildCareerExplanation } from "../../lib/scoring";

import AiRecommendation from "./AiRecommendation";
import PriorityList from "./PriorityList";
import ScoreCard from "./ScoreCard";
import SkillListCard from "./SkillListCard";
import SkillGapChart from "./SkillGapChart";

const BREAKDOWN_ROWS = [
    { key: "skillCoverage", label: "Skill coverage", weight: "70%" },
    { key: "strengths", label: "Strengths bonus", weight: "10%" },
    { key: "education", label: "Education fit", weight: "10%" },
    { key: "resumeEvidence", label: "Resume evidence", weight: "10%" },
];

export default function ResultsSection({
    results,
    careerName,
    onCopyShareLink,
    aiRoadmap,
    loadingRoadmap,
    roadmapError,
}) {
    const [copied, setCopied] = useState(false);

    async function handleShare() {
        const ok = await onCopyShareLink();

        if (ok) {
            setCopied(true);

            setTimeout(() => {
                setCopied(false);
            }, 2000);
        }
    }

    const criticalGaps = (
        results.criticalGaps ||
        results.skillGaps.filter((s) => s.gap > 50)
    ).length;

    // P4: deterministic explanation built from the user's own data
    const explanation = buildCareerExplanation(
        careerName,
        results.strongSkills,
        results.skillGaps,
        results.matchScore,
        results.readiness
    );

    const learningOrder = (results.learningOrder || []).slice(0, 5);

    const biggestGap = results.skillGaps[0];

    const strongestSkills = results.strongSkills
        .slice(0, 2)
        .map((s) => s.name)
        .filter(Boolean);

    const readinessSentence =
        results.matchScore >= 80
            ? "You're a strong match for this career."
            : results.matchScore >= 60
              ? "You're on the right track — close your gaps to become career-ready."
              : results.matchScore >= 40
                ? "You have a foundation — focus on your high-priority gaps."
                : "You're at the beginning — build your fundamentals first.";

    const matchStatus =
        results.matchScore >= 80
            ? {
                  label: "Strong Match",
                  icon: "🟢",
                  className: "strong",
              }
            : results.matchScore >= 60
              ? {
                    label: "Developing",
                    icon: "🟡",
                    className: "developing",
                }
              : results.matchScore >= 40
                ? {
                      label: "Needs Improvement",
                      icon: "🟠",
                      className: "improving",
                  }
                : {
                      label: "Starting Point",
                      icon: "🔴",
                      className: "starting",
                  };

    function handleDownload() {
        const payload = {
            career: careerName,
            matchScore: results.matchScore,
            readiness: results.readiness,
            strongSkills: results.strongSkills,
            skillGaps: results.skillGaps,
            generatedAt: new Date().toISOString(),
        };

        const blob = new Blob(
            [JSON.stringify(payload, null, 2)],
            { type: "application/json" }
        );

        const url = URL.createObjectURL(blob);
        const a = document.createElement("a");

        a.href = url;
        a.download = `${(
            careerName || "career"
        ).replace(/\s+/g, "_")}_gap_analysis.json`;

        a.click();

        URL.revokeObjectURL(url);
    }

    return (
        <section id="results" className="results-section">
            {/* =====================================================
                RESULT HEADER
               ===================================================== */}

            <div className="results-header">
                <span className="badge">
                    ✨ ANALYSIS COMPLETE
                </span>

                <span
                    className="eyebrow"
                    style={{
                        display: "block",
                        marginBottom: 6,
                        color: "#ea580c",
                        fontWeight: 800,
                        fontSize: 12,
                        letterSpacing: "0.08em",
                    }}
                >
                    YOUR CAREER ANALYSIS
                </span>

                <h2>{careerName || "Your Career Analysis"}</h2>

                <p className="results-description">
                    Your current skills have been compared with the
                    requirements for your target career.
                </p>

                {/* Match status */}
                <div
                    className={`result-match-status ${matchStatus.className}`}
                >
                    <span aria-hidden>
                        {matchStatus.icon}
                    </span>

                    <strong>{matchStatus.label}</strong>

                    <span>
                        {results.matchScore}% career match
                    </span>
                </div>

                <p
                    style={{
                        fontSize: 13,
                        color: "#475569",
                        maxWidth: 620,
                        margin: "12px auto 0",
                        lineHeight: 1.6,
                    }}
                >
                    {readinessSentence}
                </p>

                {/* =================================================
                    QUICK INSIGHTS
                   ================================================= */}

                <div className="result-insights">
                    <div className="result-insight-card">
                        <span className="result-insight-icon">
                            💪
                        </span>

                        <div>
                            <small>Strongest skills</small>

                            <strong>
                                {strongestSkills.length > 0
                                    ? strongestSkills.join(", ")
                                    : "Build your foundation"}
                            </strong>
                        </div>
                    </div>

                    <div className="result-insight-card">
                        <span className="result-insight-icon">
                            🎯
                        </span>

                        <div>
                            <small>Biggest skill gap</small>

                            <strong>
                                {biggestGap
                                    ? `${biggestGap.name} — ${biggestGap.gap}% gap`
                                    : "No major gaps"}
                            </strong>
                        </div>
                    </div>

                    <div className="result-insight-card">
                        <span className="result-insight-icon">
                            🚨
                        </span>

                        <div>
                            <small>Critical gaps</small>

                            <strong>
                                {criticalGaps === 0
                                    ? "None"
                                    : `${criticalGaps} skill${
                                          criticalGaps === 1
                                              ? ""
                                              : "s"
                                      }`}
                            </strong>
                        </div>
                    </div>
                </div>

                {/* =================================================
                    ACTIONS
                   ================================================= */}

                {onCopyShareLink && (
                    <div
                        style={{
                            display: "flex",
                            gap: 10,
                            justifyContent: "center",
                            marginTop: 16,
                            flexWrap: "wrap",
                        }}
                    >
                        <button
                            className="share-button"
                            onClick={handleShare}
                            aria-label="Copy a link to this result"
                        >
                            {copied
                                ? "✓ Link Copied!"
                                : "🔗 Share Result Link"}
                        </button>

                        <button
                            className="share-button"
                            onClick={handleDownload}
                            aria-label="Download results as JSON"
                        >
                            ⬇ Download JSON
                        </button>
                    </div>
                )}
            </div>

            {/* =====================================================
                MAIN SCORE
               ===================================================== */}

            <ScoreCard
                results={results}
                careerName={careerName}
                subtitle={readinessSentence}
            />

            {/* =====================================================
                SUMMARY METRICS
               ===================================================== */}

            <div className="analysis-summary metrics-4">
                <div className="summary-box metric-card">
                    <span
                        className="summary-icon"
                        aria-hidden
                    >
                        🎯
                    </span>

                    <div>
                        <strong>{results.matchScore}%</strong>
                        <small>Career Match</small>
                    </div>
                </div>

                <div className="summary-box metric-card">
                    <span
                        className="summary-icon"
                        aria-hidden
                    >
                        ✅
                    </span>

                    <div>
                        <strong>
                            {results.strongSkills.length}
                        </strong>
                        <small>Strong Skills</small>
                    </div>
                </div>

                <div className="summary-box metric-card">
                    <span
                        className="summary-icon"
                        aria-hidden
                    >
                        ⚠️
                    </span>

                    <div>
                        <strong>
                            {results.skillGaps.length}
                        </strong>
                        <small>Skill Gaps</small>
                    </div>
                </div>

                <div className="summary-box metric-card">
                    <span
                        className="summary-icon"
                        aria-hidden
                    >
                        🔴
                    </span>

                    <div>
                        <strong>{criticalGaps}</strong>
                        <small>Critical Gaps</small>
                    </div>
                </div>
            </div>

            {/* =====================================================
                WHY THIS CAREER (P4) + SCORE BREAKDOWN (P3)
               ===================================================== */}

            <div className="result-card why-card">
                <div className="result-card-header">
                    <h3>💡 Why {careerName || "this career"}?</h3>
                </div>

                <p className="why-explanation">{explanation}</p>

                {results.scoreBreakdown && (
                    <div className="score-breakdown">
                        <small className="score-breakdown-title">
                            How your {results.matchScore}% is calculated
                            (weighted engine):
                        </small>

                        {BREAKDOWN_ROWS.map((row) => {
                            const value =
                                results.scoreBreakdown[row.key];
                            return (
                                <div
                                    key={row.key}
                                    className={`breakdown-row ${
                                        value === null
                                            ? "breakdown-missing"
                                            : ""
                                    }`}
                                >
                                    <span className="breakdown-label">
                                        {row.label}
                                        <em>weight {row.weight}</em>
                                    </span>
                                    <span className="breakdown-track">
                                        <span
                                            className="breakdown-fill"
                                            style={{
                                                width: `${Math.min(
                                                    100,
                                                    Math.max(0, value ?? 0)
                                                )}%`,
                                            }}
                                        />
                                    </span>
                                    <span className="breakdown-value">
                                        {value === null
                                            ? "n/a"
                                            : `${value}%`}
                                    </span>
                                </div>
                            );
                        })}
                    </div>
                )}
            </div>

            {/* =====================================================
                SKILL GAP VISUALIZATION
               ===================================================== */}

            <SkillGapChart results={results} />

            {/* =====================================================
                STRONG SKILLS
               ===================================================== */}

            <SkillListCard
                title="🟢 Your Strong Skills"
                count={results.strongSkills.length}
                variant="strong"
                skills={results.strongSkills}
                emptyMessage="No skills have reached the required level yet."
            />

            {/* =====================================================
                SKILL GAPS
               ===================================================== */}

            <SkillListCard
                title="🔴 Skills You Need to Improve"
                count={results.skillGaps.length}
                variant="gap"
                skills={results.skillGaps}
                emptyMessage="🎉 Excellent! You don't have any major skill gaps."
            />

            {/* =====================================================
                PRIORITY LEARNING
               ===================================================== */}

            {results.skillGaps.length > 0 && (
                <PriorityList
                    skills={results.skillGaps}
                />
            )}

            {/* =====================================================
                RECOMMENDED LEARNING ORDER (P2)
               ===================================================== */}

            {learningOrder.length > 0 && (
                <div className="result-card learning-order-card">
                    <div className="result-card-header">
                        <h3>🪜 Recommended Learning Order</h3>
                        <span>{learningOrder.length}</span>
                    </div>

                    <p className="priority-description">
                        Ordered by how much the career demands each
                        skill — close these in sequence for the fastest
                        path to job-ready.
                    </p>

                    <ol className="learning-order-list">
                        {learningOrder.map((skill) => (
                            <li
                                key={skill.skill_id}
                                className="learning-order-item"
                            >
                                <span className="learning-order-step">
                                    {skill.step}
                                </span>
                                <div className="learning-order-main">
                                    <strong>
                                        {skill.skill || skill.name}
                                    </strong>
                                    <small>
                                        {skill.current}% →{" "}
                                        {skill.required_level}% ·{" "}
                                        {skill.reason}
                                    </small>
                                </div>
                                <span
                                    className={`priority-badge priority-badge-${String(
                                        skill.priority || ""
                                    ).toLowerCase()}`}
                                >
                                    {skill.priority}
                                </span>
                            </li>
                        ))}
                    </ol>
                </div>
            )}

            {/* =====================================================
                AI ROADMAP
               ===================================================== */}

            <AiRecommendation
                matchScore={results.matchScore}
                roadmap={aiRoadmap}
                loading={loadingRoadmap}
                error={roadmapError}
                skillGaps={results.skillGaps}
            />
        </section>
    );
}
