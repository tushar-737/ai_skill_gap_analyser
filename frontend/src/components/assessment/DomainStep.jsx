import StepCard from "./StepCard";

// STEP 2 — CAREER DOMAIN

export default function DomainStep({
    domains,
    value,
    onChange,
}) {
    return (
        <StepCard
            number="02"
            title="Career Domain"
            description="Choose the area you want to build your career in."
        >
            <select
                aria-label="Career domain"
                value={value}
                onChange={(event) =>
                    onChange(event.target.value)
                }
            >
                <option value="">
                    Select a domain
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
        </StepCard>
    );
}
