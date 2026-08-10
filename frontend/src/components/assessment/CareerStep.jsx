export default function CareerStep({ careers = [], loading = false, disabled = false, value = "", onChange = () => {}, onContinue, onBack, stepLabel = "Step 3 of 5" }) {
    return (
        <section className="assessment-step journey-card">
            <div className="journey-header">
                <div className="journey-icon" aria-hidden>
                    💼
                </div>
                <div>
                    <span className="journey-kicker">{stepLabel} — Target Career</span>
                    <h2>What&apos;s your target career?</h2>
                    <p>We&apos;ll compare your skills with the requirements of this career.</p>
                </div>
                <span className="journey-step-badge">3</span>
            </div>

            <div className="form-group">
                <label htmlFor="career">Which role are you targeting?</label>
                <select id="career" value={value} onChange={(e) => onChange(e.target.value)} disabled={disabled || loading}>
                    <option value="">{loading ? "Loading careers..." : disabled ? "Select a domain first" : "Select a career"}</option>
                    {!loading &&
                        careers.map((career) => (
                            <option key={career.id} value={career.id}>
                                {career.name}
                            </option>
                        ))}
                </select>
            </div>

            <div className="journey-actions">
                <button type="button" className="secondary-button" onClick={onBack}>
                    ← Back
                </button>
                <button type="button" className="analyze-button" style={{ maxWidth: 180, marginTop: 0 }} onClick={onContinue} disabled={!value || disabled}>
                    Continue →
                </button>
            </div>
        </section>
    );
}
