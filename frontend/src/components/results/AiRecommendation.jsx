function fallbackSummary(matchScore) {
    if (matchScore >= 80) return "Excellent progress! You already have a strong foundation for this career. Focus on advanced projects, real-world experience, internships, and specialization.";
    if (matchScore >= 60) return "Good progress! You have a solid foundation for this career. Focus on your highest-priority skill gaps to improve your readiness.";
    if (matchScore >= 40) return "You're developing! You have started building the required foundation. Concentrate on the priority skills above and practice them through projects.";
    return "Start with the fundamentals. Build your core skills step by step, complete practical projects, and gradually work toward the requirements of your target career.";
}

function getPriority(gap) {
    if (gap > 50) return { label: "CRITICAL", cls: "critical" };
    if (gap > 30) return { label: "HIGH", cls: "high" };
    if (gap > 10) return { label: "MEDIUM", cls: "medium" };
    return { label: "LOW", cls: "low" };
}

export default function AiRecommendation({ matchScore, roadmap, loading, error, skillGaps = [] }) {
    // Map skill name -> gap for roadmap steps
    const gapMap = new Map(skillGaps.map((s) => [s.name, s.gap]));

    const levelPath =
        matchScore >= 80 ? "Career Ready → Specialize → Lead" : matchScore >= 60 ? "Intermediate → Career Ready → Specialize" : matchScore >= 40 ? "Beginner → Intermediate → Career Ready" : "Beginner → Foundation → Intermediate";

    return (
        <div className="recommendation-card roadmap-v2">
            <div className="roadmap-header">
                <span className="eyebrow" style={{ color: "#e11d48" }}>
                    🤖 AI ANALYSIS
                </span>
                <h3>Your Recommended Learning Roadmap</h3>
                <p className="roadmap-subtitle">AI-powered — based on your current skill profile, gaps are prioritized by size. Follow the order.</p>
            </div>

            {loading && <p className="skill-loading">Generating your personalized roadmap with AI...</p>}

            {!loading && (
                <p className="roadmap-summary">
                    <strong>{roadmap?.summary || fallbackSummary(matchScore)}</strong>
                </p>
            )}

            {!loading && error && !roadmap && <p className="skill-loading">{error}</p>}

            {!loading && roadmap?.steps?.length > 0 && (
                <>
                    <div className="roadmap-steps-v2">
                        {roadmap.steps.map((step, index) => {
                            // Try to infer priority from first skill in step
                            const firstSkill = step.skills?.[0];
                            const gap = firstSkill ? gapMap.get(firstSkill) ?? null : null;
                            const pri = gap !== null ? getPriority(gap) : null;
                            return (
                                <div className="roadmap-step-v2" key={`${step.title}-${index}`}>
                                    <div className="roadmap-step-num">0{index + 1}</div>
                                    <div className="roadmap-step-main">
                                        <div className="roadmap-step-top">
                                            <h4>{step.title.replace(/^Phase \d+:\s*/i, "") || step.title}</h4>
                                            {pri && <span className={`priority-badge priority-badge-${pri.cls}`}>{pri.label}</span>}
                                            {gap !== null && <span className="roadmap-gap">Gap {gap}%</span>}
                                        </div>
                                        <p>{step.description}</p>
                                        {step.skills?.length > 0 && <div className="roadmap-skills">{step.skills.join(" • ")}</div>}
                                        {step.resources?.length > 0 && (
                                            <ul className="roadmap-resources">
                                                {step.resources.slice(0, 2).map((r, i) => (
                                                    <li key={`${r.name}-${i}`}>
                                                        <span className="resource-type">{r.type}</span> {r.name}
                                                    </li>
                                                ))}
                                            </ul>
                                        )}
                                    </div>
                                </div>
                            );
                        })}
                    </div>

                    <div className="learning-path">
                        <span className="learning-path-kicker">Estimated learning path</span>
                        <div className="learning-path-track">
                            {levelPath.split("→").map((lvl, i, arr) => (
                                <span key={lvl}>
                                    <span className={`path-node ${i === 0 ? "active" : ""}`}>{lvl.trim()}</span>
                                    {i < arr.length - 1 && <span className="path-arrow">→</span>}
                                </span>
                            ))}
                        </div>
                    </div>
                </>
            )}

            {!loading && roadmap?.source && (
                <small style={{ color: "#64748b", display: "block", marginTop: 10, fontSize: 11 }}>
                    Source: {roadmap.source === "ai" || roadmap.source === "groq" || roadmap.source === "gemini" ? "AI (Groq/Gemini)" : "Rule-based fallback"} • Your roadmap updates when your gaps change.
                </small>
            )}
        </div>
    );
}
