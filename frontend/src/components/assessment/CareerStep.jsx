import SearchableSelect from "../ui/SearchableSelect";

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

            <SearchableSelect
                id="career"
                label="Which role are you targeting?"
                options={careers}
                value={value}
                onChange={onChange}
                placeholder={loading ? "Loading careers..." : disabled ? "Select a domain first" : "Search target career... (e.g., Scientist)"}
                disabled={disabled || loading}
            />

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
