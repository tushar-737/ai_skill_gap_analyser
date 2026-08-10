
function SkillsRater({
    skills = [],
    levels = {},
    loading = false,
    onSkillChange = () => {},
    onAnalyze = () => {},
}) {
    return (
        <section className="assessment-step skills-rater">
            <div className="step-header">
                <span className="step-number">4</span>

                <div>
                    <h2>Rate Your Skills</h2>
                    <p>
                        Rate your current skill level from 0 to 100.
                    </p>
                </div>
            </div>

            {loading ? (
                <p className="skill-loading">
                    Loading required skills...
                </p>
            ) : skills.length === 0 ? (
                <p className="skill-loading">
                    No skills found for this career.
                </p>
            ) : (
                <>
                    <div className="skills-list">
                        {skills.map((skill) => {
                            const skillId = skill.skill_id;

                            const currentLevel =
                                Number(levels[skillId]) || 0;

                            return (
                                <div
                                    className="skill-item"
                                    key={skillId}
                                >
                                    <div className="skill-info">
                                        <label
                                            htmlFor={`skill-${skillId}`}
                                        >
                                            {skill.name ||
                                                skill.skill_name ||
                                                `Skill ${skillId}`}
                                        </label>

                                        <span>
                                            {currentLevel}%
                                        </span>
                                    </div>

                                    <input
                                        id={`skill-${skillId}`}
                                        type="range"
                                        min="0"
                                        max="100"
                                        step="5"
                                        value={currentLevel}
                                        onChange={(event) =>
                                            onSkillChange(
                                                skillId,
                                                event.target.value
                                            )
                                        }
                                    />
                                </div>
                            );
                        })}
                    </div>

                    <button
                        type="button"
                        className="analyze-button"
                        onClick={onAnalyze}
                    >
                        Analyze My Skill Gap
                    </button>
                </>
            )}
        </section>
    );
}

export default SkillsRater;
