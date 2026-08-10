function CareerStep({
    careers = [],
    loading = false,
    disabled = false,
    value = "",
    onChange = () => {},
}) {
    return (
        <section className="assessment-step">
            <div className="step-header">
                <span className="step-number">3</span>

                <div>
                    <h2>Choose Your Target Career</h2>
                    <p>
                        Select the career you want to analyze your
                        skills against.
                    </p>
                </div>
            </div>

            <div className="form-group">
                <label htmlFor="career">
                    Target Career
                </label>

                <select
                    id="career"
                    value={value}
                    onChange={(event) =>
                        onChange(event.target.value)
                    }
                    disabled={disabled || loading}
                >
                    <option value="">
                        {loading
                            ? "Loading careers..."
                            : disabled
                              ? "Select a domain first"
                              : "Select a career"}
                    </option>

                    {!loading &&
                        careers.map((career) => (
                            <option
                                key={career.id}
                                value={career.id}
                            >
                                {career.name}
                            </option>
                        ))}
                </select>
            </div>
        </section>
    );
}

export default CareerStep;