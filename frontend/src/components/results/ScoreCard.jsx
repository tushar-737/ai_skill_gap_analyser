import MatchChart from "../ui/MatchChart";

// CAREER MATCH SCORE CARD

export default function ScoreCard({ results, careerName }) {
    return (
        <div className="score-card">
            <div className="score-circle">
                <MatchChart
                    score={results.matchScore}
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
