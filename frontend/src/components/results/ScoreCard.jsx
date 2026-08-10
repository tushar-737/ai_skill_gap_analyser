import { useEffect, useState } from "react";

import MatchChart from "../ui/MatchChart";

export default function ScoreCard({ results, careerName, subtitle }) {
    const [display, setDisplay] = useState(0);

    useEffect(() => {
        if (window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
            setDisplay(results.matchScore);
            return;
        }
        let frame;
        const duration = 900;
        const start = performance.now();
        const tick = (now) => {
            const progress = Math.min((now - start) / duration, 1);
            const eased = 1 - Math.pow(1 - progress, 3);
            setDisplay(Math.round(results.matchScore * eased));
            if (progress < 1) frame = requestAnimationFrame(tick);
        };
        frame = requestAnimationFrame(tick);
        return () => cancelAnimationFrame(frame);
    }, [results.matchScore]);

    return (
        <div className="score-card score-card-dashboard">
            <div className="score-circle">
                <MatchChart score={display} ariaScore={results.matchScore} size={132} stroke={12} />
            </div>
            <div className="score-details">
                <span className="score-kicker">Career Match</span>
                <h3>{careerName}</h3>
                <p>{subtitle || "Your current career readiness"}</p>
                <strong className="readiness">{results.readiness}</strong>
                <div className="score-meta">
                    <span>{results.matchScore}% match</span>
                    <span>•</span>
                    <span>{results.gaps.length} skills analyzed</span>
                </div>
            </div>
        </div>
    );
}
