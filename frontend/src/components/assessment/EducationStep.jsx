import { useMemo, useState } from "react";

const POPULAR = ["BCA", "B.Tech Computer Science", "B.Sc Computer Science"];

export default function EducationStep({ education = [], value = "", onChange = () => {}, onContinue, onBack, stepLabel = "Step 1 of 5", showContinue = true }) {
    const [query, setQuery] = useState("");
    const [open, setOpen] = useState(false);

    const selected = useMemo(() => education.find((e) => String(e.id) === String(value)), [education, value]);

    const filtered = useMemo(() => {
        const q = query.trim().toLowerCase();
        if (!q) return education;
        return education.filter((e) => e.name.toLowerCase().includes(q));
    }, [education, query]);

    const popular = useMemo(() => {
        return POPULAR.map((name) => education.find((e) => e.name.toLowerCase().includes(name.toLowerCase()))).filter(Boolean);
    }, [education]);

    function select(item) {
        onChange(String(item.id));
        setQuery("");
        setOpen(false);
    }

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

            <div className="form-group">
                <label htmlFor="education-search">Your education</label>
                <div className="searchable-wrap">
                    <div className="searchable-input">
                        <span aria-hidden>🔍</span>
                        <input
                            id="education-search"
                            type="text"
                            placeholder={selected ? selected.name : "Search your degree..."}
                            value={open ? query : selected ? selected.name : query}
                            onFocus={() => setOpen(true)}
                            onChange={(e) => {
                                setQuery(e.target.value);
                                setOpen(true);
                            }}
                            onBlur={() => setTimeout(() => setOpen(false), 150)}
                            autoComplete="off"
                        />
                        {selected && (
                            <button
                                type="button"
                                className="search-clear"
                                onClick={() => {
                                    onChange("");
                                    setQuery("");
                                }}
                                aria-label="Clear education"
                            >
                                ×
                            </button>
                        )}
                    </div>

                    {open && (
                        <div className="searchable-dropdown" role="listbox">
                            {popular.length > 0 && !query && (
                                <>
                                    <div className="searchable-section">Popular programs</div>
                                    <div className="searchable-pills">
                                        {popular.map((p) => (
                                            <button key={p.id} type="button" className="searchable-pill" onMouseDown={() => select(p)}>
                                                {p.name}
                                            </button>
                                        ))}
                                    </div>
                                    <div className="searchable-section">All programs</div>
                                </>
                            )}
                            {filtered.length === 0 ? (
                                <div className="searchable-empty">No matches</div>
                            ) : (
                                filtered.map((item) => (
                                    <button
                                        key={item.id}
                                        type="button"
                                        role="option"
                                        aria-selected={String(item.id) === String(value)}
                                        className={`searchable-option ${String(item.id) === String(value) ? "selected" : ""}`}
                                        onMouseDown={() => select(item)}
                                    >
                                        {item.name}
                                    </button>
                                ))
                            )}
                        </div>
                    )}
                </div>
                <small style={{ color: "#64748b", fontSize: 12, display: "block", marginTop: 6 }}>
                    {education.length} programs • Type to filter
                </small>
            </div>

            {showContinue && (
                <div className="journey-actions">
                    {onBack && (
                        <button type="button" className="secondary-button" onClick={onBack}>
                            ← Back
                        </button>
                    )}
                    <button
                        type="button"
                        className="analyze-button"
                        style={{ maxWidth: 180, marginTop: 0 }}
                        onClick={onContinue}
                        disabled={!value}
                        title={!value ? "Select your education to continue" : ""}
                    >
                        Continue →
                    </button>
                </div>
            )}
        </section>
    );
}
