export default function LoadingScreen() {
    return (
        <div className="loading-screen" role="status" aria-live="polite" aria-label="Loading application data">
            <div className="loader" aria-hidden="true"></div>

            <h2>
                AI Skill Gap Analyzer
            </h2>

            <p>
                Connecting to database...
            </p>
        </div>
    );
}
