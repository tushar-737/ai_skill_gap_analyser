import StepCard from "./StepCard";

// STEP 1 — EDUCATION BACKGROUND

export default function EducationStep({
    education,
    value,
    onChange,
}) {
    return (
        <StepCard
            number="01"
            title="Education Background"
            description="Select your current degree or educational program."
        >
            <select
                aria-label="Education program"
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

                        {item.level
                            ? ` — ${item.level}`
                            : ""}
                    </option>
                ))}
            </select>
        </StepCard>
    );
}
