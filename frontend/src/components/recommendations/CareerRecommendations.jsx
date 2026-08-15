export default function CareerRecommendations({ recommendations }) {
    if (!recommendations || recommendations.length === 0) return null;

    return (
        <section className="recommendation-card alt-careers-v2">
            <span className="eyebrow" style={{ color: "#ea580c" }}>
                🏆 CAREER RANKING
            </span>
            <h3>Other careers you’re close to</h3>
            <p>Ranked by the weighted engine — coverage, strengths and education fit. Strong alternatives if you want to pivot.</p>

            <div className="alt-list">
                {recommendations.slice(0, 3).map((career, index) => {
                    const pct = Math.min(100, Math.max(0, career.matchScore || 0));
                    const whySkills = (career.overlapping || [])
                        .filter((s) => s.current >= s.required_level * 0.7)
                        .slice(0, 2)
                        .map((s) => s.skill || s.name)
                        .join(", ");
                    const fallbackWhy =
                        (career.overlapping || [])
                            .slice(0, 2)
                            .map((s) => s.skill || s.name)
                            .join(", ") || "your current skill mix";
                    return (
                        <div key={career.id} className="alt-card" role="listitem">
                            <div className="alt-card-header">
                                <strong>
                                    <span className="rank-badge">#{index + 1}</span> {career.name}
                                </strong>
                                <span className="alt-pct">
                                    {pct}% Match{career.readiness ? ` · ${career.readiness}` : ""}
                                </span>
                            </div>
                            <div className="alt-track" aria-label={`${pct} percent match`}>
                                <div className="alt-fill" style={{ width: `${pct}%` }} />
                            </div>
                            <small className="alt-why">
                                Why this career? You already have strength in <b>{whySkills || fallbackWhy}</b> — {career.overlapping?.length || 0} shared skills.
                            </small>
                        </div>
                    );
                })}
            </div>
        </section>
    );
}
