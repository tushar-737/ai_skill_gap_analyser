// Reusable skill list card — used for both "Strong Skills"
// and "Skills You Need to Improve".
//
// variant="strong": shows "Your level: X%" + ✓ Ready
// variant="gap":    shows "Your level / Required / Gap"

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

                            <div>
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
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
}
