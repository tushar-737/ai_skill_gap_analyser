import StepCard from "./StepCard";

// STEP 3 — TARGET CAREER

export default function CareerStep({
    careers,
    loading,
    disabled,
    value,
    onChange,
}) {
    return (
        <StepCard
            number="03"
            title="Target Career"
            description="Select the career you want to analyze your skills for."
        >
            <select
                aria-label="Target career"
                value={value}
                onChange={(event) =>
                    onChange(event.target.value)
                }
                disabled={disabled || loading}
            >
                <option value="">
                    {loading
                        ? "Loading careers..."
                        : "Select a career"}
                </option>

                {careers.map((career) => (
                    <option
                        key={career.id}
                        value={career.id}
                    >
                        {career.name}
                    </option>
                ))}
            </select>
        </StepCard>
    );
}
