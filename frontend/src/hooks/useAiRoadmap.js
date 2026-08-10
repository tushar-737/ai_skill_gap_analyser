import { useEffect, useState } from "react";
import { getAiRoadmap } from "../api/api";

// Fetches the AI-generated learning roadmap whenever results are
// shown for a given career + skill state. Re-fetches only when the
// underlying inputs actually change (not on every render).

export function useAiRoadmap({
    active,
    careerName,
    matchScore,
    skillGaps,
    strongSkills,
    education,
}) {
    const [roadmap, setRoadmap] = useState(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");

    useEffect(() => {
        if (!active || !careerName) {
            return;
        }

        let cancelled = false;

        async function loadRoadmap() {
            try {
                setLoading(true);
                setError("");

                const data = await getAiRoadmap({
                    careerName,
                    matchScore,
                    skillGaps,
                    strongSkills,
                    education,
                });

                if (!cancelled) {
                    setRoadmap(data);
                }
            } catch (err) {
                console.error("AI ROADMAP ERROR:", err);

                if (!cancelled) {
                    setError(
                        "Couldn't generate a personalized roadmap right now."
                    );
                }
            } finally {
                if (!cancelled) {
                    setLoading(false);
                }
            }
        }

        loadRoadmap();

        return () => {
            cancelled = true;
        };
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [
        active,
        careerName,
        matchScore,
        JSON.stringify(skillGaps),
        JSON.stringify(strongSkills),
        education,
    ]);

    return { roadmap, loading, error };
}
