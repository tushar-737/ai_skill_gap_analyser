const steps = [
    { n: "01", title: "Choose Education", desc: "Tell us your program." },
    { n: "02", title: "Select Career Domain", desc: "Pick your field." },
    { n: "03", title: "Choose Target Career", desc: "Your dream role." },
    { n: "04", title: "Rate Your Skills", desc: "Or upload resume." },
    { n: "05", title: "Analyze Skill Gap", desc: "AI compares vs requirements." },
    { n: "06", title: "Get Recommendations", desc: "Roadmap + alternatives." },
];

export default function HowItWorks() {
    return (
        <section id="how-it-works" className="how-section">
            <div className="how-inner">
                <span className="eyebrow" style={{ background: "#0f172a", color: "white" }}>
                    HOW IT WORKS
                </span>
                <h2>From resume to roadmap in 30 seconds</h2>
                <p>The examiner can understand the complete architecture in 10 seconds.</p>
                <div className="how-grid" role="list">
                    {steps.map((s, i) => (
                        <div key={s.n} className="how-card" role="listitem">
                            <span className="how-num">{s.n}</span>
                            <h3>{s.title}</h3>
                            <p>{s.desc}</p>
                            {i < steps.length - 1 && <span className="how-arrow" aria-hidden>
                                →
                            </span>}
                        </div>
                    ))}
                </div>
            </div>
        </section>
    );
}
