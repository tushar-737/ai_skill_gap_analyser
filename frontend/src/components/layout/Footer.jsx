function Footer() {
    return (
        <footer className="footer">
            <div className="footer-container">
                <p>
                    © {new Date().getFullYear()} AI Skill Gap Analyzer.
                    All rights reserved.
                </p>

                <p>
                    Built with React, FastAPI & AI.
                </p>
            </div>
        </footer>
    );
}

export default Footer;