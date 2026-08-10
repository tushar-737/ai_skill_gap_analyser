export default function SkillGapChart({ results }) {
    if (!results || !results.gaps || results.gaps.length === 0) return null;

    // Show all gaps sorted by gap desc, but limit to 8 for chart clarity
    const items = [...results.gaps].sort((a, b) => b.gap - a.gap).slice(0, 8);

    return (
        <div className="result-card chart-card">
            <div className="result-card-header">
                <h3>📊 Skill Gap Chart</h3>
                <span>Your vs Required</span>
            </div>
            <p className="priority-description">Horizontal view — blue is your current level, slate is required. The gap is the core of your analysis.</p>
            <div className="gap-chart" role="list">
                {items.map((skill) => {
                    const current = Number(skill.current) || 0;
                    const required = Number(skill.required_level) || 0;
                    const gap = Number(skill.gap) || 0;
                    return (
                        <div key={skill.skill_id} className="gap-chart-row" role="listitem">
                            <div className="gap-chart-label">
                                <strong>{skill.name || skill.skill}</strong>
                                <small>Gap {gap}%</small>
                            </div>
                            <div className="gap-chart-bars">
                                <div className="gap-bar">
                                    <span className="gap-bar-name">Your</span>
                                    <div className="gap-track">
                                        <div className="gap-fill gap-fill-your" style={{ width: `${Math.min(100, current)}%` }} />
                                    </div>
                                    <span className="gap-value">{current}%</span>
                                </div>
                                <div className="gap-bar">
                                    <span className="gap-bar-name">Need</span>
                                    <div className="gap-track">
                                        <div className="gap-fill gap-fill-need" style={{ width: `${Math.min(100, required)}%` }} />
                                    </div>
                                    <span className="gap-value need">{required}%</span>
                                </div>
                            </div>
                        </div>
                    );
                })}
            </div>
        </div>
    );
}
