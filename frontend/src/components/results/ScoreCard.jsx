import { useEffect, useState } from "react";

import MatchChart from "../ui/MatchChart";

// CAREER MATCH SCORE CARD — the number counts up when
// the results appear (respects prefers-reduced-motion).

export default function ScoreCard({ results, careerName }) {
    const [display, setDisplay] = useState(0);

    useEffect(() => {
        // Jump straight to the final value when the user prefers
        // reduced motion.
        if (
            window.matchMedia &&
            window.matchMedia(
                "(prefers-reduced-motion: reduce)"
            ).matches
        ) {
            setDisplay(results.matchScore);
            return;
        }

        let frame;
        const duration = 900;
        const start = performance.now();

        const tick = (now) => {
            const progress = Math.min(
                (now - start) / duration,
                1
            );

            // Ease-out curve
            const eased =
                1 - Math.pow(1 - progress, 3);

            setDisplay(
                Math.round(results.matchScore * eased)
            );

            if (progress < 1) {
                frame = requestAnimationFrame(tick);
            }
        };

        frame = requestAnimationFrame(tick);

        return () => cancelAnimationFrame(frame);
    }, [results.matchScore]);

    return (
        <div className="score-card">
            <div className="score-circle">
                <MatchChart
                    score={display}
                    ariaScore={results.matchScore}
                    size={120}
                    stroke={12}
                />
            </div>

            <div className="score-details">
                <h3>{careerName}</h3>

                <p>
                    Your current career readiness
                </p>

                <strong className="readiness">
                    {results.readiness}
                </strong>
            </div>
        </div>
    );
}
