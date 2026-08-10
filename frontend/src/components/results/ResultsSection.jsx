import { useState } from "react";

import AiRecommendation from "./AiRecommendation";
import PriorityList from "./PriorityList";
import ScoreCard from "./ScoreCard";
import SkillListCard from "./SkillListCard";
import SummaryCards from "./SummaryCards";

// FULL RESULTS SECTION — score, summary, strong skills,
// skill gaps, priority learning, AI recommendation and a
// share button. Keeps id="results" so the analyze button
// can scroll here.

export default function ResultsSection({
    results,
    careerName,
    onCopyShareLink,
    aiRoadmap,
    loadingRoadmap,
    roadmapError,
}) {
    const [copied, setCopied] = useState(false);

    async function handleShare() {
        const ok = await onCopyShareLink();

        if (ok) {
            setCopied(true);
            setTimeout(() => setCopied(false), 2000);
        }
    }

    return (
        <section
            id="results"
            className="results-section"
        >
            <div className="results-header">
                <span className="badge">
                    ✨ ANALYSIS COMPLETE
                </span>

                <h2>Your Career Analysis</h2>

                <p>
                    Here's how prepared you are for
                    your selected career.
                </p>

                {onCopyShareLink && (
                    <button
                        className="share-button"
                        onClick={handleShare}
                        aria-label="Copy a link to this result"
                    >
                        {copied
                            ? "✓ Link Copied!"
                            : "🔗 Share Result Link"}
                    </button>
                )}
            </div>

            <ScoreCard
                results={results}
                careerName={careerName}
            />

            <SummaryCards results={results} />

            <SkillListCard
                title="🟢 Your Strong Skills"
                count={results.strongSkills.length}
                variant="strong"
                skills={results.strongSkills}
                emptyMessage="No skills have reached the required level yet."
            />

            <SkillListCard
                title="🔴 Skills You Need to Improve"
                count={results.skillGaps.length}
                variant="gap"
                skills={results.skillGaps}
                emptyMessage="🎉 Excellent! You don't have any major skill gaps."
            />

            {results.skillGaps.length > 0 && (
                <PriorityList skills={results.skillGaps} />
            )}

            <AiRecommendation
                matchScore={results.matchScore}
                roadmap={aiRoadmap}
                loading={loadingRoadmap}
                error={roadmapError}
            />
        </section>
    );
}
