import { useEffect, useState } from "react";
import { getCareerSkills } from "../api/api";

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

        async function loadSkills() {
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
                if (!cancelled) {
                    setLoading(false);
                }
            }
        }

        loadSkills();

        return () => {
            cancelled = true;
        };
    }, [selectedCareer, onError]);

    return {
        requiredSkills,
        loading,
    };
}