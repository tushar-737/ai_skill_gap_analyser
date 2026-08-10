export default function Hero() {
    function scrollToAssessment() {
        document.getElementById("assessment")?.scrollIntoView({ behavior: "smooth" });
    }

    return (
        <section className="hero">
            <div className="hero-content">
                <span className="eyebrow">AI Skill Gap Analyzer</span>

                <h1>
                    Discover the skills you need
                    <span> to reach your dream career.</span>
                </h1>

                <p className="hero-sub">
                    Analyze your skills. Identify your gaps. Find the right career path.
                </p>

                <button type="button" className="hero-cta" onClick={scrollToAssessment}>
                    Start Skill Analysis <span aria-hidden>→</span>
                </button>

                <div className="hero-pills" aria-label="Steps">
                    <span>Education</span>
                    <span className="pill-arrow" aria-hidden>
                        →
                    </span>
                    <span>Domain</span>
                    <span className="pill-arrow" aria-hidden>
                        →
                    </span>
                    <span>Career</span>
                    <span className="pill-arrow" aria-hidden>
                        →
                    </span>
                    <span>Skills</span>
                    <span className="pill-arrow" aria-hidden>
                        →
                    </span>
                    <span>Results</span>
                </div>
            </div>
        </section>
    );
}
