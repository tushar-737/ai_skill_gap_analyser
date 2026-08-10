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
                    <p>Rate your current level from 0 to 100. Resume upload auto-fills these.</p>
                </div>
                <span className="journey-step-badge">4</span>
            </div>

            {loading ? (
                <p className="skill-loading">Loading required skills...</p>
            ) : skills.length === 0 ? (
                <p className="skill-loading">No skills found for this career.</p>
            ) : (
                <>
                    <div className="skills-list">
                        {skills.map((skill) => {
                            const skillId = skill.skill_id;
                            const currentLevel = Number(levels[skillId]) || 0;
                            return (
                                <div className="skill-item" key={skillId}>
                                    <div className="skill-info">
                                        <label htmlFor={`skill-${skillId}`}>{skill.name || skill.skill_name || `Skill ${skillId}`}</label>
                                        <span>{currentLevel}%</span>
                                    </div>
                                    <input
                                        id={`skill-${skillId}`}
                                        type="range"
                                        min="0"
                                        max="100"
                                        step="5"
                                        value={currentLevel}
                                        onChange={(e) => onSkillChange(skillId, e.target.value)}
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
