const CATEGORY_ICON = {
    Programming: "🐍",
    "Data Analysis": "📊",
    "Data Analytics": "📊",
    Data: "📊",
    "AI & ML": "🤖",
    "Machine Learning": "🤖",
    Tools: "🛠️",
    Design: "🎨",
    default: "📦",
};

function getIcon(cat) {
    return CATEGORY_ICON[cat] || CATEGORY_ICON.default;
}

function getPriority(gap) {
    if (gap > 50) return { label: "Critical", cls: "critical" };
    if (gap > 30) return { label: "High", cls: "high" };
    if (gap > 10) return { label: "Medium", cls: "medium" };
    return { label: "Low", cls: "low" };
}

export default function SkillsRater({ skills = [], levels = {}, loading = false, onSkillChange = () => {}, onAnalyze = () => {} }) {
    // Group by category
    const grouped = skills.reduce((acc, s) => {
        const cat = s.category || "Other";
        if (!acc[cat]) acc[cat] = [];
        acc[cat].push(s);
        return acc;
    }, {});

    const total = skills.length;
    const rated = Object.keys(levels).filter((k) => Number(levels[k]) > 0).length;
    const pct = total ? Math.round((rated / total) * 100) : 0;

    // Top 3 priority preview for this page (largest gaps)
    const topGaps = [...skills]
        .map((s) => ({ ...s, gap: Math.max(0, Number(s.required_level) - (Number(levels[s.skill_id]) || 0)) }))
        .sort((a, b) => b.gap - a.gap)
        .slice(0, 3)
        .filter((s) => s.gap > 0);

    return (
        <section className="assessment-step journey-card skills-rater">
            <div className="journey-header">
                <div className="journey-icon" aria-hidden>
                    📊
                </div>
                <div>
                    <span className="journey-kicker">Step 4 — Your Skills</span>
                    <h2>How strong are your skills?</h2>
                    <p>Rate each skill honestly. Use “Not familiar” if you’ve never used it — that’s okay.</p>
                </div>
                <span className="journey-step-badge">4</span>
            </div>

            {loading ? (
                <p className="skill-loading">Loading required skills...</p>
            ) : skills.length === 0 ? (
                <p className="skill-loading">No skills found for this career.</p>
            ) : (
                <>
                    <div className="skill-intro-inline">
                        <p>
                            Move each slider to your level. <strong>0% = Beginner · 50% = Intermediate · 100% = Advanced</strong>. Your score is compared with required for your target career.
                        </p>
                        <div className="skill-progress" style={{ marginTop: 10 }}>
                            <span>
                                Skills rated: {rated} / {total}
                            </span>
                            <div className="skill-progress-track" style={{ flex: 1, maxWidth: 220, marginLeft: 10 }}>
                                <div className="skill-progress-fill" style={{ width: `${pct}%` }} />
                            </div>
                            <span>{pct}%</span>
                        </div>
                    </div>

                    <div className="skills-grouped">
                        {Object.entries(grouped).map(([cat, list]) => (
                            <div key={cat} className="skill-group">
                                <div className="skill-group-header">
                                    <span className="skill-group-icon" aria-hidden>
                                        {getIcon(cat)}
                                    </span>
                                    <h3>{cat}</h3>
                                    <span className="skill-group-count">{list.length}</span>
                                </div>
                                <div className="skills-list skills-list-v2">
                                    {list.map((skill) => {
                                        const skillId = skill.skill_id;
                                        const currentLevel = Number(levels[skillId]) ?? 0;
                                        const required = Number(skill.required_level) || 0;
                                        const gap = Math.max(0, required - currentLevel);
                                        const pctCurrent = Math.min(100, Math.max(0, currentLevel));
                                        const pctRequired = Math.min(100, Math.max(0, required));
                                        const isNotFamiliar = currentLevel === 0;
                                        const pri = getPriority(gap);

                                        return (
                                            <div className={`skill-item-v2 ${gap === 0 ? "is-strong" : "has-gap"}`} key={skillId}>
                                                <div className="skill-v2-header">
                                                    <label htmlFor={`skill-${skillId}`} className="skill-v2-name">
                                                        {skill.name || skill.skill_name || `Skill ${skillId}`}
                                                    </label>
                                                    <div className="skill-v2-meta">
                                                        <span className="skill-v2-current">{currentLevel}%</span>
                                                        <span className="skill-v2-divider">/</span>
                                                        <span className="skill-v2-required">{required}%</span>
                                                        <span className={`skill-v2-pri pri-${pri.cls}`}>{pri.label}</span>
                                                    </div>
                                                </div>

                                                <div className="skill-bar-row">
                                                    <span className="skill-bar-label">Your level ●</span>
                                                    <div className="skill-track">
                                                        <div className="skill-fill skill-fill-your" style={{ width: `${pctCurrent}%` }} />
                                                    </div>
                                                    <span className="skill-bar-value">{pctCurrent}%</span>
                                                </div>

                                                <div className="skill-bar-row required">
                                                    <span className="skill-bar-label">Required ●</span>
                                                    <div className="skill-track">
                                                        <div className="skill-fill skill-fill-required" style={{ width: `${pctRequired}%` }} />
                                                    </div>
                                                    <span className="skill-bar-value required">{pctRequired}%</span>
                                                </div>

                                                <div className="skill-item-footer">
                                                    <span className={`skill-gap-badge ${gap === 0 ? "good" : pri.cls}`}>
                                                        {gap === 0 ? "✓ Needs development: Ready" : `Gap: ${gap}% · Needs development`}
                                                    </span>
                                                    <button
                                                        type="button"
                                                        className={`not-familiar-btn ${isNotFamiliar ? "active" : ""}`}
                                                        onClick={() => onSkillChange(skillId, isNotFamiliar ? 30 : 0)}
                                                        aria-pressed={isNotFamiliar}
                                                        title="Mark as not familiar (sets to 0%)"
                                                    >
                                                        {isNotFamiliar ? "☑ Not familiar" : "☐ Not familiar"}
                                                    </button>
                                                </div>

                                                <div className="skill-scale-ticks" aria-hidden>
                                                    <span>0</span>
                                                    <span>25</span>
                                                    <span>50</span>
                                                    <span>75</span>
                                                    <span>100</span>
                                                </div>
                                                <div className="skill-scale-labels" aria-hidden>
                                                    <span>Beginner</span>
                                                    <span>Intermediate</span>
                                                    <span>Advanced</span>
                                                </div>

                                                <input
                                                    id={`skill-${skillId}`}
                                                    type="range"
                                                    min="0"
                                                    max="100"
                                                    step="5"
                                                    value={currentLevel}
                                                    onChange={(e) => onSkillChange(skillId, e.target.value)}
                                                    aria-label={`${skill.name} current ${currentLevel}%, required ${required}%, gap ${gap}%`}
                                                />
                                            </div>
                                        );
                                    })}
                                </div>
                            </div>
                        ))}
                    </div>

                    {topGaps.length > 0 && (
                        <div className="top-priority-preview">
                            <h4>Top 3 priorities</h4>
                            <div className="top-priority-list">
                                {topGaps.map((s, i) => (
                                    <span key={s.skill_id} className="top-priority-chip">
                                        0{i + 1} {s.name} <em>Gap {s.gap}%</em>
                                    </span>
                                ))}
                            </div>
                        </div>
                    )}

                    <button type="button" className="analyze-button" onClick={onAnalyze}>
                        Analyze My Skill Gap →
                    </button>
                    <small style={{ display: "block", textAlign: "center", color: "#64748b", marginTop: 8, fontSize: 12 }}>Takes about 10 seconds • Compares your skills with requirements for your target career</small>
                </>
            )}
        </section>
    );
}
