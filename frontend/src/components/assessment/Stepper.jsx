const steps = [
    "Education",
    "Domain",
    "Career",
    "Skills",
    "Results",
];

function Stepper({ activeStep = 0 }) {
    return (
        <div className="stepper">
            {steps.map((step, index) => (
                <div
                    key={step}
                    className={`step ${
                        index === activeStep
                            ? "active"
                            : index < activeStep
                            ? "completed"
                            : ""
                    }`}
                >
                    <div className="step-number">
                        {index + 1}
                    </div>

                    <div className="step-label">
                        {step}
                    </div>
                </div>
            ))}
        </div>
    );
}

export default Stepper;