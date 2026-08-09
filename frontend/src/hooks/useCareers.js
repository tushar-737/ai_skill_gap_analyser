import { useEffect, useState } from "react";

import { getCareersByDomain } from "../api/api";

// =====================================================
// CAREERS FOR THE SELECTED DOMAIN
// =====================================================
//
// Refetches whenever the domain changes. Returns an empty
// list while no domain is selected. `onError` is called with
// a user-facing message when the request fails.

export function useCareers(selectedDomain, onError = () => {}) {
    const [careers, setCareers] = useState([]);
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        if (!selectedDomain) {
            setCareers([]);
            setLoading(false);
            return;
        }

        let cancelled = false;

        async function load() {
            try {
                setLoading(true);
                onError("");

                const data = await getCareersByDomain(
                    Number(selectedDomain)
                );

                if (cancelled) return;

                if (!Array.isArray(data)) {
                    throw new Error(
                        "Invalid careers response"
                    );
                }

                setCareers(data);
            } catch (error) {
                console.error("CAREERS ERROR:", error);

                if (!cancelled) {
                    setCareers([]);
                    onError("Unable to load careers.");
                }
            } finally {
                if (!cancelled) setLoading(false);
            }
        }

        load();

        return () => {
            cancelled = true;
        };
    }, [selectedDomain, onError]);

    return { careers, loading };
}
