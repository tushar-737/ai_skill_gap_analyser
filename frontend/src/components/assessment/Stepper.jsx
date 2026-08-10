const steps = [
    { label: "Education", short: "Education" },
    { label: "Domain", short: "Domain" },
    { label: "Career", short: "Career" },
    { label: "Skills", short: "Skills" },
    { label: "Results", short: "Results" },
];

export default function Stepper({ activeStep = 0 }) {
    return (
        <div className="stepper" role="navigation" aria-label="Progress">
            {steps.map((step, index) => {
                const isCompleted = index < activeStep;
                const isActive = index === activeStep;
                const state = isActive ? "active" : isCompleted ? "completed" : "upcoming";

                return (
                    <div key={step.label} className={`step ${state}`}>
                        <div className="step-connector" aria-hidden>
                            {index > 0 && <span className="step-line" />}
                        </div>
                        <div className="step-node">
                            <div className="step-circle" aria-hidden>
                                {isCompleted ? "✓" : index + 1}
                            </div>
                            <span className="step-label">{step.label}</span>
                        </div>
                    </div>
                );
            })}
        </div>
    );
}
