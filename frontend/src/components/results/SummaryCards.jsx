// SUMMARY CARDS — strong skills / skill gaps / required skills

export default function SummaryCards({ results }) {
    const items = [
        {
            icon: "✓",
            value: results.strongSkills.length,
            label: "Strong Skills",
        },
        {
            icon: "!",
            value: results.skillGaps.length,
            label: "Skill Gaps",
        },
        {
            icon: "🎯",
            value: results.gaps.length,
            label: "Required Skills",
        },
    ];

    return (
        <div className="analysis-summary">
            {items.map((item) => (
                <div
                    className="summary-box"
                    key={item.label}
                >
                    <span className="summary-icon">
                        {item.icon}
                    </span>

                    <div>
                        <strong>{item.value}</strong>

                        <small>{item.label}</small>
                    </div>
                </div>
            ))}
        </div>
    );
}
