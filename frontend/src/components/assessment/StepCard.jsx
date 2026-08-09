// Shared card shell for the four assessment steps.
// Renders the step number, title, description and children.

export default function StepCard({
    number,
    title,
    description,
    className = "",
    children,
}) {
    return (
        <section
            className={`card ${className}`.trim()}
        >
            <div className="step-number">
                {number}
            </div>

            <div className="step-content">
                <h2>{title}</h2>

                <p>{description}</p>

                {children}
            </div>
        </section>
    );
}
