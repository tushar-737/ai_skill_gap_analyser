
import { useEffect, useMemo, useRef, useState } from "react";

export default function CareerStep({
    careers = [],
    loading = false,
    disabled = false,
    value = "",
    onChange = () => {},
    onContinue,
    onBack,
    stepLabel = "Step 3 of 5",
}) {
    const [search, setSearch] = useState("");
    const [isOpen, setIsOpen] = useState(false);
    const searchRef = useRef(null);
    const pickerRef = useRef(null);

    const selectedCareer = careers.find(
        (career) => String(career.id) === String(value)
    );

    const filteredCareers = useMemo(() => {
        const query = search.trim().toLowerCase();

        if (!query) {
            return careers;
        }

        return careers.filter((career) =>
            String(career.name || "")
                .toLowerCase()
                .includes(query)
        );
    }, [careers, search]);

    useEffect(() => {
        function handleOutsideClick(event) {
            if (
                pickerRef.current &&
                !pickerRef.current.contains(event.target)
            ) {
                setIsOpen(false);
            }
        }

        document.addEventListener("mousedown", handleOutsideClick);

        return () => {
            document.removeEventListener(
                "mousedown",
                handleOutsideClick
            );
        };
    }, []);

    function handleSearchChange(event) {
        setSearch(event.target.value);
        setIsOpen(true);
    }

    function handleSelectCareer(career) {
        onChange(String(career.id));
        setSearch("");
        setIsOpen(false);
    }

    function handleClearSearch() {
        setSearch("");
        setIsOpen(true);
        searchRef.current?.focus();
    }

    function handleKeyDown(event) {
        if (event.key === "Escape") {
            setIsOpen(false);
            searchRef.current?.blur();
        }

        if (event.key === "Enter" && filteredCareers.length === 1) {
            event.preventDefault();
            handleSelectCareer(filteredCareers[0]);
        }
    }

    const showResults =
        !disabled &&
        !loading &&
        isOpen &&
        filteredCareers.length > 0;

    return (
        <section className="assessment-step journey-card">
            <div className="journey-header">
                <div className="journey-icon" aria-hidden>
                    💼
                </div>

                <div>
                    <span className="journey-kicker">
                        {stepLabel} — Target Career
                    </span>

                    <h2>What&apos;s your target career?</h2>

                    <p>
                        We&apos;ll compare your skills with the
                        requirements of this career.
                    </p>
                </div>

                <span className="journey-step-badge">3</span>
            </div>

            <div className="form-group career-picker-group">
                <label htmlFor="career-search">
                    Which role are you targeting?
                </label>

                <div
                    ref={pickerRef}
                    className={`career-picker ${
                        isOpen ? "is-open" : ""
                    }`}
                >
                    {/* Search */}
                    <div className="career-search-wrapper">
                        <span
                            className="career-search-icon"
                            aria-hidden
                        >
                            🔎
                        </span>

                        <input
                            ref={searchRef}
                            id="career-search"
                            type="text"
                            value={
                                search ||
                                (!isOpen && selectedCareer
                                    ? selectedCareer.name
                                    : "")
                            }
                            onChange={handleSearchChange}
                            onFocus={() => {
                                if (!disabled && !loading) {
                                    setIsOpen(true);
                                }
                            }}
                            onKeyDown={handleKeyDown}
                            disabled={disabled || loading}
                            placeholder={
                                loading
                                    ? "Loading careers..."
                                    : disabled
                                      ? "Select a domain first"
                                      : "Search career... e.g. Data Scientist"
                            }
                            autoComplete="off"
                            aria-expanded={isOpen}
                            aria-controls="career-results"
                            aria-autocomplete="list"
                        />

                        {(search || selectedCareer) && !disabled && !loading && (
                            <button
                                type="button"
                                className="career-search-clear"
                                onClick={() => {
                                    setSearch("");
                                    onChange("");
                                    setIsOpen(true);
                                    searchRef.current?.focus();
                                }}
                                aria-label="Clear selected career"
                            >
                                ×
                            </button>
                        )}
                    </div>

                    {/* Selected career */}
                    {selectedCareer && !isOpen && (
                        <div className="selected-career-preview">
                            <span
                                className="selected-career-check"
                                aria-hidden
                            >
                                ✓
                            </span>

                            <div>
                                <small>Selected career</small>
                                <strong>
                                    {selectedCareer.name}
                                </strong>
                            </div>

                            <button
                                type="button"
                                onClick={() => {
                                    setIsOpen(true);
                                    setSearch("");
                                    setTimeout(
                                        () =>
                                            searchRef.current?.focus(),
                                        0
                                    );
                                }}
                                className="change-career-button"
                            >
                                Change
                            </button>
                        </div>
                    )}

                    {/* Results */}
                    {showResults && (
                        <div
                            id="career-results"
                            className="career-results"
                            role="listbox"
                            aria-label="Available careers"
                        >
                            <div className="career-results-header">
                                <span>
                                    {filteredCareers.length}{" "}
                                    {filteredCareers.length === 1
                                        ? "career"
                                        : "careers"}{" "}
                                    found
                                </span>

                                {search && (
                                    <span>
                                        for &quot;{search}&quot;
                                    </span>
                                )}
                            </div>

                            <div className="career-results-list">
                                {filteredCareers.map((career) => {
                                    const isSelected =
                                        String(career.id) ===
                                        String(value);

                                    return (
                                        <button
                                            key={career.id}
                                            type="button"
                                            className={`career-option ${
                                                isSelected
                                                    ? "selected"
                                                    : ""
                                            }`}
                                            onClick={() =>
                                                handleSelectCareer(
                                                    career
                                                )
                                            }
                                            role="option"
                                            aria-selected={
                                                isSelected
                                            }
                                        >
                                            <span
                                                className="career-option-icon"
                                                aria-hidden
                                            >
                                                💼
                                            </span>

                                            <span className="career-option-content">
                                                <strong>
                                                    {career.name}
                                                </strong>

                                                <small>
                                                    View required skills
                                                    and compare your
                                                    current level
                                                </small>
                                            </span>

                                            {isSelected && (
                                                <span
                                                    className="career-option-check"
                                                    aria-hidden
                                                >
                                                    ✓
                                                </span>
                                            )}
                                        </button>
                                    );
                                })}
                            </div>
                        </div>
                    )}

                    {/* No results */}
                    {!disabled &&
                        !loading &&
                        isOpen &&
                        search.trim() &&
                        filteredCareers.length === 0 && (
                            <div className="career-empty">
                                <span
                                    className="career-empty-icon"
                                    aria-hidden
                                >
                                    🔎
                                </span>

                                <strong>
                                    No careers found
                                </strong>

                                <p>
                                    Try another keyword or a
                                    different career name.
                                </p>

                                <button
                                    type="button"
                                    onClick={handleClearSearch}
                                >
                                    Clear search
                                </button>
                            </div>
                        )}

                    {/* Initial helper */}
                    {!disabled &&
                        !loading &&
                        isOpen &&
                        !search &&
                        careers.length > 0 && (
                            <div className="career-picker-hint">
                                <span>⌨️</span>
                                <span>
                                    Start typing to quickly find
                                    your career
                                </span>
                            </div>
                        )}
                </div>

                {!loading &&
                    !disabled &&
                    careers.length > 0 && (
                        <small className="career-count">
                            {careers.length} careers available in
                            this domain
                        </small>
                    )}
            </div>

            <div className="journey-actions">
                <button
                    type="button"
                    className="secondary-button"
                    onClick={onBack}
                >
                    ← Back
                </button>

                <button
                    type="button"
                    className="analyze-button"
                    style={{
                        maxWidth: 180,
                        marginTop: 0,
                    }}
                    onClick={onContinue}
                    disabled={!value || disabled}
                >
                    Continue →
                </button>
            </div>
        </section>
    );
}
