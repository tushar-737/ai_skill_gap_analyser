import { useEffect, useState } from "react";
import { getCareersWithSkillsByDomain } from "../api/api";
import { dedupeSkills } from "../lib/scoring";

export function useDomainCareerSkills(selectedDomain) {
    const [domainCareerSkills, setDomainCareerSkills] =
        useState([]);

    const [loading, setLoading] = useState(false);

    useEffect(() => {
        if (!selectedDomain) {
            setDomainCareerSkills([]);
            setLoading(false);
            return;
        }

        let cancelled = false;

        async function loadCareerSkills() {
            try {
                setLoading(true);

                const data =
                    await getCareersWithSkillsByDomain(
                        Number(selectedDomain)
                    );

                if (cancelled) return;

                if (!Array.isArray(data)) {
                    throw new Error(
                        "Invalid career recommendations response"
                    );
                }

                setDomainCareerSkills(
                    data.map((career) => ({
                        ...career,
                        skills: dedupeSkills(career.skills || []),
                    }))
                );
            } catch (error) {
                console.error(
                    "CAREER RECOMMENDATIONS ERROR:",
                    error
                );

                if (!cancelled) {
                    setDomainCareerSkills([]);
                }
            } finally {
                if (!cancelled) {
                    setLoading(false);
                }
            }
        }

        loadCareerSkills();

        return () => {
            cancelled = true;
        };
    }, [selectedDomain]);

    return {
        domainCareerSkills,
        loading,
    };
}