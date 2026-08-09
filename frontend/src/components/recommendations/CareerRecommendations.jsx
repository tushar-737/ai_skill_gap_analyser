// RECOMMENDED CAREERS — alternative careers that share
// skills with the user's current profile.

export default function CareerRecommendations({
    recommendations,
}) {
    return (
        <section className="recommendation-card">
            <h3>🚀 Recommended Careers</h3>

            <p>
                These careers share skills with
                your current profile and may be
                strong alternatives.
            </p>

            <div className="recommendation-list">
                {recommendations.map((career) => (
                    <div
                        className="recommendation-item"
                        role="listitem"
                        key={career.id}
                    >
                        <div>
                            <strong>
                                {career.name}
                            </strong>

                            <small>
                                {
                                    career.overlapping
                                        .length
                                }{" "}
                                shared skill
                                {career.overlapping
                                    .length >
                                1
                                    ? "s"
                                    : ""}{" "}
                                •{" "}
                                {career.matchScore}%
                                match
                            </small>
                        </div>

                        <span>
                            {career.matchScore}%
                        </span>
                    </div>
                ))}
            </div>
        </section>
    );
}
