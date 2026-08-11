import { useEffect, useMemo, useRef, useState } from "react";
import { getAiRoadmap } from "../api/api";

const CACHE_TTL_MS = 5 * 60 * 1000;

// Fetches a roadmap only when the meaningful assessment inputs change. Results
// are cached in-memory for five minutes and obsolete requests are aborted.
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
    const cacheRef = useRef(new Map());

    const requestKey = useMemo(
        () => JSON.stringify({ careerName, matchScore, skillGaps, strongSkills, education }),
        [careerName, matchScore, skillGaps, strongSkills, education]
    );

    useEffect(() => {
        if (!active || !careerName) {
            setRoadmap(null);
            setLoading(false);
            return undefined;
        }

        const cached = cacheRef.current.get(requestKey);
        if (cached && Date.now() - cached.createdAt < CACHE_TTL_MS) {
            setRoadmap(cached.data);
            setError("");
            setLoading(false);
            return undefined;
        }

        const controller = new AbortController();

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
                    signal: controller.signal,
                });

                cacheRef.current.set(requestKey, {
                    data,
                    createdAt: Date.now(),
                });
                setRoadmap(data);
            } catch (err) {
                if (err.name !== "AbortError") {
                    console.error("AI ROADMAP ERROR:", err);
                    setError("Couldn't generate a personalized roadmap right now.");
                }
            } finally {
                if (!controller.signal.aborted) {
                    setLoading(false);
                }
            }
        }

        loadRoadmap();
        return () => controller.abort();
    }, [
        active,
        careerName,
        matchScore,
        skillGaps,
        strongSkills,
        education,
        requestKey,
    ]);

    return { roadmap, loading, error };
}
