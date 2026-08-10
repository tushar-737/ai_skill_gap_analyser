export default function CareerStep({ careers = [], loading = false, disabled = false, value = "", onChange = () => {} }) {
    return (
        <section className="assessment-step journey-card">
            <div className="journey-header">
                <div className="journey-icon" aria-hidden>
                    💼
                </div>
                <div>
                    <span className="journey-kicker">Step 3 — Target Career</span>
                    <h2>Choose Your Target Career</h2>
                    <p>Which career do you want to pursue?</p>
                </div>
                <span className="journey-step-badge">3</span>
            </div>

            <div className="form-group">
                <label htmlFor="career">Target Career</label>
                <select id="career" value={value} onChange={(e) => onChange(e.target.value)} disabled={disabled || loading}>
                    <option value="">
                        {loading ? "Loading careers..." : disabled ? "Select a domain first" : "Select a career"}
                    </option>
                    {!loading &&
                        careers.map((career) => (
                            <option key={career.id} value={career.id}>
                                {career.name}
                            </option>
                        ))}
                </select>
            </div>
        </section>
    );
}
