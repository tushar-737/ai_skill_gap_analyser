// AI CAREER RECOMMENDATION — rule-based guidance per match tier

export default function AiRecommendation({ matchScore }) {
    let content;

    if (matchScore >= 80) {
        content = (
            <p>
                <strong>Excellent progress!</strong>{" "}
                You already have a strong
                foundation for this career. Focus
                on advanced projects, real-world
                experience, internships, and
                specialization.
            </p>
        );
    } else if (matchScore >= 60) {
        content = (
            <p>
                <strong>Good progress!</strong>{" "}
                You have a solid foundation for
                this career. Focus on your
                highest-priority skill gaps to
                improve your readiness.
            </p>
        );
    } else if (matchScore >= 40) {
        content = (
            <p>
                <strong>You're developing!</strong>{" "}
                You have started building the
                required foundation. Concentrate on
                the priority skills above and
                practice them through projects.
            </p>
        );
    } else {
        content = (
            <p>
                <strong>
                    Start with the fundamentals.
                </strong>{" "}
                Build your core skills step by
                step, complete practical projects,
                and gradually work toward the
                requirements of your target career.
            </p>
        );
    }

    return (
        <div className="recommendation-card">
            <h3>🤖 AI Career Recommendation</h3>

            {content}
        </div>
    );
}
