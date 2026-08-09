// ASSESSMENT PROGRESS — visual stepper above the steps.
//
// activeStep (0-4): how many steps are complete + the
// current one. 0 = nothing chosen, 4 = results shown.

const STEPS = ["Education", "Domain", "Career", "Skills"];

export default function Stepper({ activeStep = 0 }) {
    return (
        <nav
            className="stepper"
            aria-label="Assessment progress"
        >
            <div className="stepper-steps">
                {STEPS.map((label, index) => {
                    const state =
                        index < activeStep
                            ? "done"
                            : index === activeStep
                              ? "active"
                              : "upcoming";

                    return (
                        <div
                            className={`stepper-step ${state}`}
                            key={label}
                        >
                            <span className="stepper-dot">
                                {index < activeStep
                                    ? "✓"
                                    : index + 1}
                            </span>

                            <span className="stepper-label">
                                {label}
                            </span>
                        </div>
                    );
                })}
            </div>

            <div className="stepper-bar">
                <div
                    className="stepper-bar-fill"
                    style={{
                        width: `${(activeStep / STEPS.length) * 100}%`,
                    }}
                />
            </div>
        </nav>
    );
}
