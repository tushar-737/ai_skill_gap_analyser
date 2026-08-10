export default function Header() {
    return (
        <header className="header">
            <div className="header-inner">
                <div className="brand">
                    <span className="brand-icon">AI</span>
                    SkillGap
                    <span className="brand-highlight">AI</span>
                </div>
                <nav className="nav-links" aria-label="Primary">
                    <a href="#how-it-works">How It Works</a>
                    <a href="#about">About</a>
                    <a href="#assessment" className="nav-cta">
                        Start Analysis
                    </a>
                </nav>
            </div>
        </header>
    );
}
