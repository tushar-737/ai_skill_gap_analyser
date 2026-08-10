function Footer() {
    return (
        <footer className="footer">
            <div className="footer-grid">
                <div>
                    <div className="brand" style={{ fontSize: 18, marginBottom: 8 }}>
                        <span className="brand-icon" style={{ width: 32, height: 32, fontSize: 12 }}>
                            AI
                        </span>{" "}
                        SkillGap AI
                    </div>
                    <p style={{ color: "#94a3b8", fontSize: 13, lineHeight: 1.5, maxWidth: 320 }}>
                        AI-powered career guidance and skill-gap analysis. Analyze your skills, identify gaps, find the right path.
                    </p>
                </div>

                <div>
                    <h4>Quick Links</h4>
                    <a href="#how-it-works">How It Works</a>
                    <a href="#about">About</a>
                    <a href="#assessment">Career Analysis</a>
                </div>

                <div>
                    <h4>Technology</h4>
                    <span>React</span>
                    <span>FastAPI</span>
                    <span>MySQL</span>
                    <span>Python</span>
                </div>
            </div>

            <div className="footer-bottom">
                <span>© {new Date().getFullYear()} AI Skill Gap Analyzer</span>
                <span>Built with React, FastAPI & AI (Groq/Gemini)</span>
            </div>
        </footer>
    );
}

export default Footer;
