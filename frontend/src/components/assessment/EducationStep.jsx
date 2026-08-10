export default function EducationStep({ education = [], value = "", onChange = () => {} }) {
    return (
        <section className="assessment-step journey-card" id="assessment">
            <div className="journey-header">
                <div className="journey-icon" aria-hidden>
                    🎓
                </div>
                <div>
                    <span className="journey-kicker">Step 1 — Your Education</span>
                    <h2>Select Your Education</h2>
                    <p>Choose your current program.</p>
                </div>
                <span className="journey-step-badge">1</span>
            </div>

            <div className="form-group">
                <label htmlFor="education">Education</label>
                <select id="education" value={value} onChange={(e) => onChange(e.target.value)}>
                    <option value="">Select your education</option>
                    {education.map((item) => (
                        <option key={item.id} value={item.id}>
                            {item.name}
                        </option>
                    ))}
                </select>
            </div>
        </section>
    );
}
