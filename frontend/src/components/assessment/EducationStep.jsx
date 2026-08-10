
function EducationStep({
    education = [],
    value = "",
    onChange = () => {},
}) {
    return (
        <section className="assessment-step">
            <div className="step-header">
                <span className="step-number">1</span>

                <div>
                    <h2>Select Your Education</h2>
                    <p>
                        Choose your current education level or program.
                    </p>
                </div>
            </div>

            <div className="form-group">
                <label htmlFor="education">
                    Education
                </label>

                <select
                    id="education"
                    value={value}
                    onChange={(event) =>
                        onChange(event.target.value)
                    }
                >
                    <option value="">
                        Select your education
                    </option>

                    {education.map((item) => (
                        <option
                            key={item.id}
                            value={item.id}
                        >
                            {item.name}
                        </option>
                    ))}
                </select>
            </div>
        </section>
    );
}

export default EducationStep;
