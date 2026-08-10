export default function DomainStep({ domains = [], value = "", onChange = () => {} }) {
    return (
        <section className="assessment-step journey-card">
            <div className="journey-header">
                <div className="journey-icon" aria-hidden>
                    🎯
                </div>
                <div>
                    <span className="journey-kicker">Step 2 — Career Domain</span>
                    <h2>Choose Your Career Domain</h2>
                    <p>What area are you interested in?</p>
                </div>
                <span className="journey-step-badge">2</span>
            </div>

            <div className="form-group">
                <label htmlFor="domain">Career Domain</label>
                <select id="domain" value={value} onChange={(e) => onChange(e.target.value)}>
                    <option value="">Select a career domain</option>
                    {domains.map((domain) => (
                        <option key={domain.id} value={domain.id}>
                            {domain.name}
                        </option>
                    ))}
                </select>
            </div>
        </section>
    );
}
