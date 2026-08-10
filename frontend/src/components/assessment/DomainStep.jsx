
function DomainStep({
    domains = [],
    value = "",
    onChange = () => {},
}) {
    return (
        <section className="assessment-step">
            <div className="step-header">
                <span className="step-number">2</span>

                <div>
                    <h2>Choose Your Career Domain</h2>
                    <p>
                        Select the field you want to explore.
                    </p>
                </div>
            </div>

            <div className="form-group">
                <label htmlFor="domain">
                    Career Domain
                </label>

                <select
                    id="domain"
                    value={value}
                    onChange={(event) =>
                        onChange(event.target.value)
                    }
                >
                    <option value="">
                        Select a career domain
                    </option>

                    {domains.map((domain) => (
                        <option
                            key={domain.id}
                            value={domain.id}
                        >
                            {domain.name}
                        </option>
                    ))}
                </select>
            </div>
        </section>
    );
}

export default DomainStep;