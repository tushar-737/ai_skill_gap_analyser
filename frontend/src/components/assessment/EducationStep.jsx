import SearchableSelect from "../ui/SearchableSelect";

const POPULAR_EDU = ["BCA", "B.Tech Computer Science", "B.Sc Computer Science"];

export default function EducationStep({ education = [], value = "", onChange = () => {}, onContinue, onBack, stepLabel = "Step 1 of 5" }) {
    return (
        <section className="assessment-step journey-card" id="assessment">
            <div className="journey-header">
                <div className="journey-icon" aria-hidden>
                    🎓
                </div>
                <div>
                    <span className="journey-kicker">{stepLabel} — Your Education</span>
                    <h2>What&apos;s your current education?</h2>
                    <p>Select the degree or program you&apos;re currently pursuing. This helps us understand your academic background.</p>
                </div>
                <span className="journey-step-badge">1</span>
            </div>

            <SearchableSelect
                id="education"
                label="Your education"
                options={education}
                value={value}
                onChange={onChange}
                placeholder="Search your degree... (e.g., BCA)"
                popular={POPULAR_EDU}
            />
            <small style={{ color: "#64748b", fontSize: 12, display: "block", marginTop: 6 }}>{education.length} programs • Type to filter • Use ↓ ↑ Enter Esc</small>

            <div className="journey-actions">
                {onBack && (
                    <button type="button" className="secondary-button" onClick={onBack}>
                        ← Back
                    </button>
                )}
                <button type="button" className="analyze-button" style={{ maxWidth: 180, marginTop: 0 }} onClick={onContinue} disabled={!value} title={!value ? "Select your education to continue" : ""}>
                    Continue →
                </button>
            </div>
        </section>
    );
}
