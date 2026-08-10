import { useState } from "react";

import AiRecommendation from "./AiRecommendation";
import PriorityList from "./PriorityList";
import ScoreCard from "./ScoreCard";
import SkillListCard from "./SkillListCard";
import SkillGapChart from "./SkillGapChart";

export default function ResultsSection({ results, careerName, onCopyShareLink, aiRoadmap, loadingRoadmap, roadmapError }) {
    const [copied, setCopied] = useState(false);

    async function handleShare() {
        const ok = await onCopyShareLink();
        if (ok) {
            setCopied(true);
            setTimeout(() => setCopied(false), 2000);
        }
    }

    const criticalGaps = results.skillGaps.filter((s) => s.gap > 50).length;

    const readinessSentence =
        results.matchScore >= 80
            ? "You're a strong match for this career."
            : results.matchScore >= 60
              ? "You're on the right track — close your gaps to be career-ready."
              : results.matchScore >= 40
                ? "You have a foundation — focus on high-priority gaps."
                : "You’re at the start — build fundamentals first.";

    return (
        <section id="results" className="results-section">
            <div className="results-header">
                <span className="badge">✨ ANALYSIS COMPLETE</span>
                <span className="eyebrow" style={{ display: "block", marginBottom: 6, color: "#2563eb", fontWeight: 800, fontSize: 12, letterSpacing: "0.08em" }}>
                    YOUR CAREER ANALYSIS
                </span>
                <h2>{careerName || "Your Career Analysis"}</h2>
                <p>Here’s how prepared you are for your selected career.</p>
                {onCopyShareLink && (
                    <button className="share-button" onClick={handleShare} aria-label="Copy a link to this result">
                        {copied ? "✓ Link Copied!" : "🔗 Share Result Link"}
                    </button>
                )}
            </div>

            <ScoreCard results={results} careerName={careerName} subtitle={readinessSentence} />

            {/* 4 metric cards — Career Match | Strong | Gaps | Critical */}
            <div className="analysis-summary metrics-4">
                <div className="summary-box metric-card">
                    <span className="summary-icon" aria-hidden>
                        🎯
                    </span>
                    <div>
                        <strong>{results.matchScore}%</strong>
                        <small>Career Match</small>
                    </div>
                </div>
                <div className="summary-box metric-card">
                    <span className="summary-icon" aria-hidden>
                        ✅
                    </span>
                    <div>
                        <strong>{results.strongSkills.length}</strong>
                        <small>Strong Skills</small>
                    </div>
                </div>
                <div className="summary-box metric-card">
                    <span className="summary-icon" aria-hidden>
                        ⚠️
                    </span>
                    <div>
                        <strong>{results.skillGaps.length}</strong>
                        <small>Skill Gaps</small>
                    </div>
                </div>
                <div className="summary-box metric-card">
                    <span className="summary-icon" aria-hidden>
                        🔴
                    </span>
                    <div>
                        <strong>{criticalGaps}</strong>
                        <small>Critical Gaps</small>
                    </div>
                </div>
            </div>

            <SkillGapChart results={results} />

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

            {results.skillGaps.length > 0 && <PriorityList skills={results.skillGaps} />}

            <AiRecommendation matchScore={results.matchScore} roadmap={aiRoadmap} loading={loadingRoadmap} error={roadmapError} />
        </section>
    );
}
