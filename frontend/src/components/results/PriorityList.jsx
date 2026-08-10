import { getLearningLinks } from "../../lib/resources";

// PRIORITY LEARNING — top 5 skill gaps to focus on first,
// each with curated learning resources.

export default function PriorityList({ skills }) {
    if (skills.length === 0) return null;

    return (
        <div className="result-card priority-card">
            <div className="result-card-header">
                <h3>🎯 Priority Learning</h3>
            </div>

            <p className="priority-description">
                Focus on these skills first. They
                have the largest gaps compared with
                your target career requirements.
            </p>

            <div
                className="priority-list"
                role="list"
            >
                {skills.slice(0, 5).map((skill, index) => (
                    <div
                        className="priority-item"
                        role="listitem"
                        key={skill.skill_id}
                    >
                        <span className="priority-number">
                            {index + 1}
                        </span>

                        <div>
                            <strong>
                                {skill.name}
                            </strong>

                            <small>
                                Current:{" "}
                                {skill.current}%
                                {" • "}
                                Required:{" "}
                                {skill.required_level}%
                            </small>

                            <div className="learn-links">
                                {getLearningLinks(
                                    skill.name
                                ).map((link) => (
                                    <a
                                        key={link.url}
                                        className="learn-link"
                                        href={link.url}
                                        target="_blank"
                                        rel="noopener noreferrer"
                                    >
                                        📚 {link.label}
                                    </a>
                                ))}
                            </div>
                        </div>

                        <span className="priority-gap">
                            Gap: {skill.gap}%
                        </span>
                    </div>
                ))}
            </div>
        </div>
    );
}
