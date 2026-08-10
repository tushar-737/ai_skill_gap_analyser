import { useEffect, useState } from "react";
import {
    getEducationPrograms,
    getDomains,
} from "../api/api";

export function useInitialData(onError = () => {}) {
    const [education, setEducation] = useState([]);
    const [domains, setDomains] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        let cancelled = false;

        async function loadInitialData() {
            try {
                setLoading(true);
                onError("");

                const [
                    educationData,
                    domainData,
                ] = await Promise.all([
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
                if (!cancelled) {
                    setLoading(false);
                }
            }
        }

        loadInitialData();

        return () => {
            cancelled = true;
        };
    }, [onError]);

    return {
        education,
        domains,
        loading,
    };
}