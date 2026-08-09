import { getLearningLinks } from "../../lib/resources";

// Reusable skill list card — used for both "Strong Skills"
// and "Skills You Need to Improve".
//
// variant="strong": shows "Your level: X%" + ✓ Ready
// variant="gap":    shows "Your level / Required / Gap"
//                   plus "Learn it" links per skill gap.

export default function SkillListCard({
    title,
    count,
    variant,
    skills,
    emptyMessage,
}) {
    const isGap = variant === "gap";

    return (
        <div className="result-card">
            <div className="result-card-header">
                <h3>{title}</h3>

                <span>{count}</span>
            </div>

            {skills.length === 0 ? (
                <p className="empty-message">
                    {emptyMessage}
                </p>
            ) : (
                <div
                    className="result-list"
                    role="list"
                >
                    {skills.map((skill) => (
                        <div
                            className={`result-skill ${
                                isGap
                                    ? "gap-skill"
                                    : "strong-skill"
                            }`}
                            role="listitem"
                            key={skill.skill_id}
                        >
                            <div>
                                <strong>
                                    {skill.skill}
                                </strong>

                                <span>
                                    {skill.category}
                                </span>
                            </div>

                            <div className="result-skill-meta">
                                <span>
                                    Your level:{" "}
                                    {skill.current}%
                                </span>

                                {isGap ? (
                                    <>
                                        <span>
                                            Required:{" "}
                                            {
                                                skill.required_level
                                            }
                                            %
                                        </span>

                                        <span className="gap">
                                            Gap:{" "}
                                            {skill.gap}%
                                        </span>
                                    </>
                                ) : (
                                    <span className="good">
                                        ✓ Ready
                                    </span>
                                )}
                            </div>

                            {isGap && (
                                <div className="learn-links">
                                    {getLearningLinks(
                                        skill.skill
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
                            )}
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
}
