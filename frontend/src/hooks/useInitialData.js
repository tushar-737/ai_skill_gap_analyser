import { useEffect, useState } from "react";

import { getEducationPrograms, getDomains } from "../api/api";

// =====================================================
// INITIAL DATA (education programs + career domains)
// =====================================================
//
// Loads both lists once when the app starts. `onError` is
// called with a user-facing message when the backend cannot
// be reached (App renders it in the global error banner).

export function useInitialData(onError = () => {}) {
    const [education, setEducation] = useState([]);
    const [domains, setDomains] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        let cancelled = false;

        async function load() {
            try {
                setLoading(true);
                onError("");

                const [educationData, domainData] =
                    await Promise.all([
                        getEducationPrograms(),
                        getDomains(),
                    ]);

                if (cancelled) return;

                setEducation(
                    Array.isArray(educationData)
                        ? educationData
                        : []
                );

                setDomains(
                    Array.isArray(domainData)
                        ? domainData
                        : []
                );
            } catch (error) {
                console.error(
                    "INITIAL DATA ERROR:",
                    error
                );

                if (!cancelled) {
                    onError(
                        "Unable to connect to the backend."
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
    }, [onError]);

    return { education, domains, loading };
}
