export default function DomainStep({ domains = [], value = "", onChange = () => {}, onContinue, onBack, stepLabel = "Step 2 of 5" }) {
    return (
        <section className="assessment-step journey-card">
            <div className="journey-header">
                <div className="journey-icon" aria-hidden>
                    🎯
                </div>
                <div>
                    <span className="journey-kicker">{stepLabel} — Career Field</span>
                    <h2>Which career field interests you?</h2>
                    <p>Choose the domain you&apos;re interested in exploring. This helps narrow suitable careers.</p>
                </div>
                <span className="journey-step-badge">2</span>
            </div>

            <div className="form-group">
                <label htmlFor="domain">Which field</label>
                <select id="domain" value={value} onChange={(e) => onChange(e.target.value)}>
                    <option value="">Select a career domain</option>
                    {domains.map((domain) => (
                        <option key={domain.id} value={domain.id}>
                            {domain.name}
                        </option>
                    ))}
                </select>
                <small style={{ color: "#64748b", fontSize: 12, display: "block", marginTop: 6 }}>Domain = the broader field • Career = specific role</small>
            </div>

            <div className="journey-actions">
                <button type="button" className="secondary-button" onClick={onBack}>
                    ← Back
                </button>
                <button type="button" className="analyze-button" style={{ maxWidth: 180, marginTop: 0 }} onClick={onContinue} disabled={!value}>
                    Continue →
                </button>
            </div>
        </section>
    );
}
