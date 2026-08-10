// AI CAREER RECOMMENDATION — shows a personalized, AI-generated
// learning roadmap (via the backend /api/ai/roadmap endpoint).
// While that's loading, or if it's unavailable, falls back to a
// short rule-based summary so the section is never empty.

function fallbackSummary(matchScore) {
    if (matchScore >= 80) {
        return "Excellent progress! You already have a strong foundation for this career. Focus on advanced projects, real-world experience, internships, and specialization.";
    }

    if (matchScore >= 60) {
        return "Good progress! You have a solid foundation for this career. Focus on your highest-priority skill gaps to improve your readiness.";
    }

    if (matchScore >= 40) {
        return "You're developing! You have started building the required foundation. Concentrate on the priority skills above and practice them through projects.";
    }

    return "Start with the fundamentals. Build your core skills step by step, complete practical projects, and gradually work toward the requirements of your target career.";
}

export default function AiRecommendation({
    matchScore,
    roadmap,
    loading,
    error,
}) {
    return (
        <div className="recommendation-card">
            <h3>🤖 AI Career Recommendation</h3>

            {loading && (
                <p className="skill-loading">
                    Generating your personalized roadmap...
                </p>
            )}

            {!loading && (
                <p>
                    <strong>
                        {roadmap?.summary ||
                            fallbackSummary(matchScore)}
                    </strong>
                </p>
            )}

            {!loading && error && !roadmap && (
                <p className="skill-loading">{error}</p>
            )}

            {!loading && roadmap?.steps?.length > 0 && (
                <div className="roadmap-steps">
                    {roadmap.steps.map((step, index) => (
                        <div
                            className="roadmap-step"
                            key={`${step.title}-${index}`}
                        >
                            <h4>{step.title}</h4>
                            <p>{step.description}</p>

                            {step.resources?.length > 0 && (
                                <ul className="roadmap-resources">
                                    {step.resources.map(
                                        (resource, rIndex) => (
                                            <li
                                                key={`${resource.name}-${rIndex}`}
                                            >
                                                <span className="resource-type">
                                                    {resource.type}
                                                </span>{" "}
                                                {resource.name}
                                            </li>
                                        )
                                    )}
                                </ul>
                            )}
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
}
