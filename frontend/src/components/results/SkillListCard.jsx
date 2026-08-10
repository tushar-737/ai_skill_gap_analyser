import { getLearningLinks } from "../../lib/resources";

function getPriority(gap) {
    if (gap > 50) return { label: "CRITICAL", cls: "critical" };
    if (gap > 30) return { label: "HIGH", cls: "high" };
    if (gap > 10) return { label: "MEDIUM", cls: "medium" };
    return { label: "LOW", cls: "low" };
}

export default function SkillListCard({ title, count, variant, skills, emptyMessage }) {
    const isGap = variant === "gap";

    return (
        <div className="result-card">
            <div className="result-card-header">
                <h3>{title}</h3>
                <span>{count}</span>
            </div>

            {skills.length === 0 ? (
                <p className="empty-message">{emptyMessage}</p>
            ) : (
                <div className="result-list" role="list">
                    {skills.map((skill) => {
                        const pri = isGap ? getPriority(skill.gap) : null;
                        return (
                            <div className={`result-skill ${isGap ? "gap-skill" : "strong-skill"}`} role="listitem" key={skill.skill_id}>
                                <div>
                                    <strong>{skill.name}</strong>
                                    <span>{skill.category}</span>
                                </div>

                                <div className="result-skill-meta">
                                    <span>Your level: {skill.current}%</span>
                                    {isGap ? (
                                        <>
                                            <span>Required: {skill.required_level}%</span>
                                            <span className="gap">Gap: {skill.gap}%</span>
                                            <span className={`priority-badge priority-badge-${pri.cls}`} style={{ marginLeft: 6 }}>
                                                {pri.label}
                                            </span>
                                        </>
                                    ) : (
                                        <span className="good">✓ Ready</span>
                                    )}
                                </div>

                                {isGap && (
                                    <div className="learn-links">
                                        {getLearningLinks(skill.name).map((link) => (
                                            <a key={link.url} className="learn-link" href={link.url} target="_blank" rel="noopener noreferrer">
                                                📚 {link.label}
                                            </a>
                                        ))}
                                    </div>
                                )}
                            </div>
                        );
                    })}
                </div>
            )}
        </div>
    );
}
