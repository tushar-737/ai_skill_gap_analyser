import { getLearningLinks } from "../../lib/resources";

function getPriority(gap) {
    if (gap > 50) return { label: "CRITICAL", emoji: "🔴", cls: "critical" };
    if (gap > 30) return { label: "HIGH", emoji: "🔴", cls: "high" };
    if (gap > 10) return { label: "MEDIUM", emoji: "🟡", cls: "medium" };
    return { label: "LOW", emoji: "🟢", cls: "low" };
}

export default function PriorityList({ skills }) {
    if (skills.length === 0) return null;

    return (
        <div className="result-card priority-card-v2">
            <div className="result-card-header">
                <h3>🎯 Priority Learning — Focus First</h3>
                <span>{skills.slice(0, 5).length}</span>
            </div>

            <p className="priority-description">
                The system doesn’t just find gaps — it <strong>prioritizes them by gap size</strong>. Start with <strong>HIGH</strong>.
            </p>

            <div className="priority-list-v2" role="list">
                {skills.slice(0, 5).map((skill, index) => {
                    const p = getPriority(skill.gap);
                    return (
                        <div key={skill.skill_id} className={`priority-item-v2 priority-${p.cls}`} role="listitem">
                            <div className="priority-index">
                                <span className="priority-num">0{index + 1}</span>
                                <span className={`priority-badge priority-badge-${p.cls}`}>
                                    {p.emoji} {p.label} PRIORITY
                                </span>
                            </div>
                            <div className="priority-main">
                                <strong>{skill.name}</strong>
                                <div className="priority-meta">
                                    <span>
                                        Current: <b>{skill.current}%</b>
                                    </span>
                                    <span>
                                        Required: <b>{skill.required_level}%</b>
                                    </span>
                                    <span className="gap">
                                        Gap: <b>{skill.gap}%</b>
                                    </span>
                                </div>
                                <div className="priority-bar">
                                    <div className="priority-track">
                                        <div className="priority-fill" style={{ width: `${Math.min(100, skill.gap)}%` }} />
                                    </div>
                                    <span>{skill.gap}% gap</span>
                                </div>
                                <div className="learn-links">
                                    {getLearningLinks(skill.name)
                                        .slice(0, 2)
                                        .map((link) => (
                                            <a key={link.url} className="learn-link" href={link.url} target="_blank" rel="noopener noreferrer">
                                                📚 {link.label}
                                            </a>
                                        ))}
                                    <a className="learn-link learn-link-cta" href={getLearningLinks(skill.name)[0]?.url} target="_blank" rel="noopener noreferrer">
                                        Start Learning →
                                    </a>
                                </div>
                            </div>
                        </div>
                    );
                })}
            </div>
        </div>
    );
}
