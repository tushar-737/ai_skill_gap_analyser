export default function Architecture() {
    return (
        <section id="about" className="arch-section">
            <div className="arch-inner">
                <span className="eyebrow" style={{ background: "#ea580c", color: "white" }}>
                    AI ARCHITECTURE
                </span>
                <h2>How the intelligence flows</h2>
                <p>Present this as your technical diagram — React → FastAPI → MySQL + Scoring Engine → Recommendations</p>

                <div className="arch-diagram" role="img" aria-label="Architecture: User to React to FastAPI to MySQL and Scoring Engine to Recommendations">
                    <div className="arch-row">
                        <div className="arch-node user">USER</div>
                    </div>
                    <div className="arch-arrow">▼</div>
                    <div className="arch-row">
                        <div className="arch-node frontend">React Frontend</div>
                    </div>
                    <div className="arch-arrow">▼</div>
                    <div className="arch-row">
                        <div className="arch-node api">FastAPI API</div>
                    </div>
                    <div className="arch-split">
                        <div className="arch-branch">
                            <div className="arch-node db">MySQL Database</div>
                            <small>Workbench • skills_v2, careers_v2, resume_analyses</small>
                        </div>
                        <div className="arch-branch">
                            <div className="arch-node engine">Scoring Engine</div>
                            <small>Rule + AI (Groq/Gemini)</small>
                        </div>
                    </div>
                    <div className="arch-row" style={{ marginTop: 14 }}>
                        <div className="arch-node scoring">Skill Gap Analysis + Career Matching</div>
                    </div>
                    <div className="arch-arrow">▼</div>
                    <div className="arch-row">
                        <div className="arch-node rec">Recommendations</div>
                    </div>
                    <small className="arch-legend">Your backend currently performs rule/database-based scoring with AI passkey for resume/roadmap — explain as “AI-powered recommendation system” (Groq/Gemini) or “intelligent rule-based” if you prefer.</small>
                </div>
            </div>
        </section>
    );
}
