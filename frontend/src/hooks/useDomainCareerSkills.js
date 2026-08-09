import { useEffect, useState } from "react";

import { getCareersWithSkillsByDomain } from "../api/api";

// =====================================================
// ALL CAREERS WITH SKILLS FOR THE SELECTED DOMAIN
// =====================================================
//
// Used to compute alternative career recommendations.
// Refetches whenever the domain changes.

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

        async function load() {
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

                setDomainCareerSkills(data);
            } catch (error) {
                console.error(
                    "CAREER RECOMMENDATIONS ERROR:",
                    error
                );

                if (!cancelled) {
                    setDomainCareerSkills([]);
                }
            } finally {
                if (!cancelled) setLoading(false);
            }
        }

        load();

        return () => {
            cancelled = true;
        };
    }, [selectedDomain]);

    return { domainCareerSkills, loading };
}
