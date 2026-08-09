import StepCard from "./StepCard";

// STEP 4 — RATE YOUR SKILLS

export default function SkillsRater({
    skills,
    levels,
    loading,
    onSkillChange,
    onAnalyze,
}) {
    return (
        <StepCard
            number="04"
            title="Rate Your Skills"
            description="Rate your current proficiency from 0 to 100."
            className="skills-card"
        >
            {/* =============================================
                SKILL LOADING / EMPTY STATES
            ============================================= */}

            {loading ? (
                <div className="skill-loading">
                    Loading required skills...
                </div>
            ) : skills.length === 0 ? (
                <div className="skill-loading">
                    No skills have been configured
                    for this career yet.
                </div>
            ) : (
                <div className="skills-list">
                    {skills.map((skill) => (
                        <div
                            className="skill-row"
                            key={skill.skill_id}
                        >
                            <div className="skill-info">
                                <div>
                                    <strong>
                                        {skill.skill}
                                    </strong>

                                    <small>
                                        {skill.category}
                                    </small>
                                </div>

                                <span>
                                    {levels[
                                        skill.skill_id
                                    ] || 0}
                                    %
                                </span>
                            </div>

                            <div className="skill-requirement">
                                Required:{" "}
                                {skill.required_level}
                                %
                            </div>

                            <input
                                type="range"
                                min="0"
                                max="100"
                                step="5"
                                value={
                                    levels[
                                        skill.skill_id
                                    ] || 0
                                }
                                onChange={(event) =>
                                    onSkillChange(
                                        skill.skill_id,
                                        event.target.value
                                    )
                                }
                            />
                        </div>
                    ))}
                </div>
            )}

            {/* =============================================
                ANALYZE BUTTON
            ============================================= */}

            <button
                className="analyze-button"
                aria-label="Analyze my skills"
                onClick={onAnalyze}
                disabled={
                    loading || skills.length === 0
                }
            >
                Analyze My Skills

                <span>→</span>
            </button>
        </StepCard>
    );
}
