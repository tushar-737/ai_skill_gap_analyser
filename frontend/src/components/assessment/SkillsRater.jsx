function SkillsRater({ skills = [], levels = {}, loading = false, onSkillChange = () => {}, onAnalyze = () => {} }) {
    return (
        <section className="assessment-step journey-card skills-rater">
            <div className="journey-header">
                <div className="journey-icon" aria-hidden>
                    📊
                </div>
                <div>
                    <span className="journey-kicker">Step 4 — Your Skills</span>
                    <h2>Rate Your Skills</h2>
                    <p>Move the slider — see your level vs required level instantly.</p>
                </div>
                <span className="journey-step-badge">4</span>
            </div>

            {loading ? (
                <p className="skill-loading">Loading required skills...</p>
            ) : skills.length === 0 ? (
                <p className="skill-loading">No skills found for this career.</p>
            ) : (
                <>
                    <div className="skills-list skills-list-v2">
                        {skills.map((skill) => {
                            const skillId = skill.skill_id;
                            const currentLevel = Number(levels[skillId]) || 0;
                            const required = Number(skill.required_level) || 0;
                            const gap = Math.max(0, required - currentLevel);
                            const pctCurrent = Math.min(100, Math.max(0, currentLevel));
                            const pctRequired = Math.min(100, Math.max(0, required));
                            const isGap = gap > 0;

                            return (
                                <div className={`skill-item-v2 ${isGap ? "has-gap" : "is-strong"}`} key={skillId}>
                                    <div className="skill-v2-header">
                                        <label htmlFor={`skill-${skillId}`} className="skill-v2-name">
                                            {skill.name || skill.skill_name || `Skill ${skillId}`}
                                        </label>
                                        <div className="skill-v2-meta">
                                            <span className="skill-v2-current">{currentLevel}%</span>
                                            <span className="skill-v2-divider">/</span>
                                            <span className="skill-v2-required">{required}%</span>
                                        </div>
                                    </div>

                                    {/* Your level bar */}
                                    <div className="skill-bar-row">
                                        <span className="skill-bar-label">
                                            Your level <span aria-hidden>●</span>
                                        </span>
                                        <div className="skill-track">
                                            <div className="skill-fill skill-fill-your" style={{ width: `${pctCurrent}%` }} />
                                        </div>
                                        <span className="skill-bar-value">{pctCurrent}%</span>
                                    </div>

                                    {/* Required level bar */}
                                    <div className="skill-bar-row required">
                                        <span className="skill-bar-label">
                                            Required <span aria-hidden>●</span>
                                        </span>
                                        <div className="skill-track">
                                            <div className="skill-fill skill-fill-required" style={{ width: `${pctRequired}%` }} />
                                        </div>
                                        <span className="skill-bar-value required">{pctRequired}%</span>
                                    </div>

                                    <div className="skill-item-footer">
                                        <span className={`skill-gap-badge ${gap === 0 ? "good" : gap > 30 ? "high" : gap > 10 ? "medium" : "low"}`}>
                                            {gap === 0 ? "✓ Ready" : `Gap: ${gap}%`}
                                        </span>
                                        <span className="skill-category">{skill.category || ""}</span>
                                    </div>

                                    <input
                                        id={`skill-${skillId}`}
                                        type="range"
                                        min="0"
                                        max="100"
                                        step="5"
                                        value={currentLevel}
                                        onChange={(e) => onSkillChange(skillId, e.target.value)}
                                        aria-label={`${skill.name} current level ${currentLevel} percent, required ${required} percent`}
                                    />
                                </div>
                            );
                        })}
                    </div>

                    <button type="button" className="analyze-button" onClick={onAnalyze}>
                        Analyze My Skill Gap
                    </button>
                </>
            )}
        </section>
    );
}

export default SkillsRater;
