import { useEffect, useState } from "react";

import { getCareerSkills } from "../api/api";

// =====================================================
// REQUIRED SKILLS FOR THE SELECTED CAREER
// =====================================================
//
// Refetches whenever the career changes. Returns an empty
// list while no career is selected. `onError` is called with
// a user-facing message when the request fails or returns
// invalid data.

export function useCareerSkills(
    selectedCareer,
    onError = () => {}
) {
    const [requiredSkills, setRequiredSkills] = useState([]);
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        if (!selectedCareer) {
            setRequiredSkills([]);
            setLoading(false);
            return;
        }

        let cancelled = false;

        async function load() {
            try {
                setLoading(true);
                onError("");

                const data = await getCareerSkills(
                    Number(selectedCareer)
                );

                if (cancelled) return;

                if (!Array.isArray(data)) {
                    console.error(
                        "Invalid skills response:",
                        data
                    );

                    setRequiredSkills([]);
                    onError(
                        "Invalid skills data received from backend."
                    );
                    return;
                }

                setRequiredSkills(data);
            } catch (error) {
                console.error(
                    "ERROR LOADING CAREER SKILLS:",
                    error
                );

                if (!cancelled) {
                    setRequiredSkills([]);
                    onError(
                        "Unable to load skills for this career."
                    );
                }
            } finally {
                if (!cancelled) setLoading(false);
            }
        }

        load();

        return () => {
            cancelled = true;
        };
    }, [selectedCareer, onError]);

    return { requiredSkills, loading };
}
