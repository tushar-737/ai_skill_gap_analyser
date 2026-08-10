import { useState } from "react";

export default function Header({ onReset }) {
    const [open, setOpen] = useState(false);
    return (
        <header className="header">
            <div className="header-inner">
                <div className="brand">
                    <span className="brand-icon">AI</span>
                    SkillGap
                    <span className="brand-highlight">AI</span>
                </div>

                <button
                    type="button"
                    className="hamburger"
                    aria-label={open ? "Close menu" : "Open menu"}
                    aria-expanded={open}
                    onClick={() => setOpen((v) => !v)}
                >
                    <span />
                    <span />
                    <span />
                </button>

                <nav className={`nav-links ${open ? "open" : ""}`} aria-label="Primary">
                    <a href="#how-it-works" onClick={() => setOpen(false)}>
                        How It Works
                    </a>
                    <a href="#about" onClick={() => setOpen(false)}>
                        About
                    </a>
                    <a href="#assessment" className="nav-cta" onClick={() => setOpen(false)}>
                        Start Analysis
                    </a>
                    {onReset && (
                        <button type="button" className="nav-reset" onClick={() => { setOpen(false); onReset(); }}>
                            ↺ Reset
                        </button>
                    )}
                </nav>
            </div>
        </header>
    );
}
