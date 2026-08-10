export default function About() {
    return (
        <section id="about" className="about-section">
            <div className="about-inner">
                <span className="eyebrow" style={{ background: "#0f172a", color: "white" }}>
                    ABOUT
                </span>
                <h2>What is SkillGap AI?</h2>
                <p className="about-lead">
                    SkillGap AI helps students and job seekers understand how their current skills compare with the requirements of different careers.
                </p>

                <div className="about-grid">
                    <div className="about-card">
                        <span className="about-icon">🔍</span>
                        <h3>Assess</h3>
                        <p>Understand your current skills — rate them or upload your resume.</p>
                    </div>
                    <div className="about-card">
                        <span className="about-icon">📊</span>
                        <h3>Analyze</h3>
                        <p>Identify the biggest skill gaps for your target career.</p>
                    </div>
                    <div className="about-card">
                        <span className="about-icon">🎯</span>
                        <h3>Recommend</h3>
                        <p>Suggest suitable career paths based on your profile.</p>
                    </div>
                    <div className="about-card">
                        <span className="about-icon">🗺️</span>
                        <h3>Guide</h3>
                        <p>Create a practical, prioritized learning roadmap.</p>
                    </div>
                </div>

                <p className="about-foot">Find the skills you need for your career — simple language, actionable steps.</p>
            </div>
        </section>
    );
}
