
import { useEffect, useMemo, useRef, useState } from "react";
import "./App.css";

import { useInitialData } from "./hooks/useInitialData";
import { useCareers } from "./hooks/useCareers";
import { useDomainCareerSkills } from "./hooks/useDomainCareerSkills";
import { useCareerSkills } from "./hooks/useCareerSkills";

import {
    computeCareerRecommendations,
    computeResults,
} from "./lib/scoring";

import {
    decodeShareState,
    encodeShareState,
    copyText,
} from "./lib/share";

import {
    loadState,
    saveState,
} from "./lib/storage";

import Header from "./components/layout/Header";
import Hero from "./components/layout/Hero";
import Footer from "./components/layout/Footer";

import LoadingScreen from "./components/ui/LoadingScreen";
import ErrorBanner from "./components/ui/ErrorBanner";

import Stepper from "./components/assessment/Stepper";
import EducationStep from "./components/assessment/EducationStep";
import DomainStep from "./components/assessment/DomainStep";
import CareerStep from "./components/assessment/CareerStep";
import SkillsRater from "./components/assessment/SkillsRater";

import ResultsSection from "./components/results/ResultsSection";
import CareerRecommendations from "./components/recommendations/CareerRecommendations";


function App() {
    // =====================================================
    // SELECTION STATE
    // =====================================================

    const [selectedEducation, setSelectedEducation] =
        useState("");

    const [selectedDomain, setSelectedDomain] =
        useState("");

    const [selectedCareer, setSelectedCareer] =
        useState("");

    const [skillLevels, setSkillLevels] =
        useState({});

    const [showResults, setShowResults] =
        useState(false);


    // =====================================================
    // ERROR STATE
    // =====================================================

    const [error, setError] = useState("");
    const [formError, setFormError] = useState("");


    // =====================================================
    // INITIAL DATA
    // =====================================================

    const {
        education,
        domains,
        loading,
    } = useInitialData(setError);


    // =====================================================
    // CAREERS
    // =====================================================

    const {
        careers,
        loading: loadingCareers,
    } = useCareers(
        selectedDomain,
        setError
    );


    // =====================================================
    // CAREER RECOMMENDATIONS DATA
    // =====================================================

    const {
        domainCareerSkills,
        loading: loadingRecommendations,
    } = useDomainCareerSkills(
        selectedDomain
    );


    // =====================================================
    // REQUIRED SKILLS
    // =====================================================

    const {
        requiredSkills,
        loading: loadingSkills,
    } = useCareerSkills(
        selectedCareer,
        setError
    );


    // =====================================================
    // RESTORE SAVED / SHARED STATE
    // =====================================================

    const pendingLevelsRef = useRef(null);

    useEffect(() => {
        const shared = decodeShareState(
            window.location.hash
        );

        if (shared) {
            pendingLevelsRef.current = {
                c: String(shared.c || ""),
                l: shared.l || {},
                showResults: true,
            };

            setSelectedEducation(
                String(shared.e || "")
            );

            setSelectedDomain(
                String(shared.d || "")
            );

            setSelectedCareer(
                String(shared.c || "")
            );

            return;
        }

        const saved = loadState();

        if (saved && saved.c) {
            pendingLevelsRef.current = {
                c: String(saved.c),
                l: saved.l || {},
                showResults: Boolean(saved.r),
            };

            setSelectedEducation(
                String(saved.e || "")
            );

            setSelectedDomain(
                String(saved.d || "")
            );

            setSelectedCareer(
                String(saved.c || "")
            );
        }
    }, []);


    // =====================================================
    // SAVE STATE
    // =====================================================

    useEffect(() => {
        saveState({
            e: selectedEducation,
            d: selectedDomain,
            c: selectedCareer,
            l: skillLevels,
            r: showResults,
        });
    }, [
        selectedEducation,
        selectedDomain,
        selectedCareer,
        skillLevels,
        showResults,
    ]);


    // =====================================================
    // APPLY SKILL LEVELS
    // =====================================================

    useEffect(() => {
        if (!selectedCareer) {
            setSkillLevels({});
            return;
        }

        if (requiredSkills.length === 0) {
            return;
        }

        const pending = pendingLevelsRef.current;

        const base =
            pending &&
            String(pending.c) ===
                String(selectedCareer)
                ? pending.l
                : {};

        const initialLevels = {};

        requiredSkills.forEach((skill) => {
            initialLevels[skill.skill_id] =
                Number(
                    base?.[skill.skill_id]
                ) || 0;
        });

        setSkillLevels(initialLevels);

        pendingLevelsRef.current = null;

        if (
            pending &&
            pending.showResults
        ) {
            setShowResults(true);
        } else {
            setShowResults(false);
        }
    }, [
        selectedCareer,
        requiredSkills,
    ]);


    // =====================================================
    // CLEAR SHARE HASH
    // =====================================================

    function clearShareHash() {
        if (
            window.location.hash.startsWith(
                "#/share/"
            )
        ) {
            window.history.replaceState(
                null,
                "",
                window.location.pathname +
                    window.location.search
            );
        }
    }


    // =====================================================
    // EDUCATION CHANGE
    // =====================================================

    function handleEducationChange(value) {
        setFormError("");
        clearShareHash();

        setSelectedEducation(value);
    }


    // =====================================================
    // DOMAIN CHANGE
    // =====================================================

    function handleDomainChange(value) {
        setFormError("");
        clearShareHash();

        setSelectedDomain(value);

        setSelectedCareer("");
        setSkillLevels({});
        setShowResults(false);
    }


    // =====================================================
    // CAREER CHANGE
    // =====================================================

    function handleCareerChange(value) {
        setFormError("");
        clearShareHash();

        setSelectedCareer(value);
        setShowResults(false);
    }


    // =====================================================
    // SKILL CHANGE
    // =====================================================

    function handleSkillChange(
        skillId,
        value
    ) {
        setFormError("");
        clearShareHash();

        setSkillLevels((previous) => ({
            ...previous,
            [skillId]: Number(value),
        }));

        setShowResults(false);
    }


    // =====================================================
    // ANALYZE
    // =====================================================

    function handleAnalyze() {
        setFormError("");

        if (!selectedEducation) {
            setFormError(
                "Please select your education."
            );
            return;
        }

        if (!selectedDomain) {
            setFormError(
                "Please select a career domain."
            );
            return;
        }

        if (!selectedCareer) {
            setFormError(
                "Please select a target career."
            );
            return;
        }

        if (requiredSkills.length === 0) {
            setFormError(
                "No skills found for this career."
            );
            return;
        }

        setShowResults(true);

        setTimeout(() => {
            document
                .getElementById("results")
                ?.scrollIntoView({
                    behavior: "smooth",
                });
        }, 100);
    }


    // =====================================================
    // SHARE LINK
    // =====================================================

    async function handleCopyShareLink() {
        const payload = {
            e: selectedEducation,
            d: selectedDomain,
            c: selectedCareer,
            l: skillLevels,
        };

        const url =
            window.location.origin +
            window.location.pathname +
            "#/share/" +
            encodeShareState(payload);

        return copyText(url);
    }


    // =====================================================
    // RESULTS
    // =====================================================

    const results = useMemo(() => {
        return computeResults(
            requiredSkills,
            skillLevels
        );
    }, [
        requiredSkills,
        skillLevels,
    ]);


    // =====================================================
    // CAREER RECOMMENDATIONS
    // =====================================================

    const careerRecommendations = useMemo(() => {
        return computeCareerRecommendations(
            domainCareerSkills,
            selectedCareer,
            skillLevels
        );
    }, [
        domainCareerSkills,
        selectedCareer,
        skillLevels,
    ]);


    // =====================================================
    // SELECTED CAREER NAME
    // =====================================================

    const selectedCareerName =
        careers.find(
            (career) =>
                String(career.id) ===
                String(selectedCareer)
        )?.name;


    // =====================================================
    // STEPPER
    // =====================================================

    const activeStep =
        !selectedEducation
            ? 0
            : !selectedDomain
                ? 1
                : !selectedCareer
                    ? 2
                    : showResults
                        ? 4
                        : 3;


    // =====================================================
    // LOADING SCREEN
    // =====================================================

    if (loading) {
        return <LoadingScreen />;
    }


    // =====================================================
    // MAIN PAGE
    // =====================================================

    return (
        <div>
            <a
                className="skip-link"
                href="#main-content"
            >
                Skip to main content
            </a>

            <Header />

            <Hero />

            <main
                id="main-content"
                className="assessment-container"
            >

                {/* STEPPER */}

                <Stepper
                    activeStep={activeStep}
                />


                {/* ERRORS */}

                {error && (
                    <ErrorBanner
                        message={error}
                    />
                )}

                {formError && (
                    <ErrorBanner
                        message={formError}
                    />
                )}


                {/* EDUCATION */}

                <EducationStep
                    education={education}
                    value={selectedEducation}
                    onChange={
                        handleEducationChange
                    }
                />


                {/* DOMAIN */}

                <DomainStep
                    domains={domains}
                    value={selectedDomain}
                    onChange={
                        handleDomainChange
                    }
                />


                {/* CAREER */}

                <CareerStep
                    careers={careers}
                    loading={loadingCareers}
                    disabled={!selectedDomain}
                    value={selectedCareer}
                    onChange={
                        handleCareerChange
                    }
                />


                {/* SKILLS */}

                {selectedCareer && (
                    <SkillsRater
                        skills={requiredSkills}
                        levels={skillLevels}
                        loading={loadingSkills}
                        onSkillChange={
                            handleSkillChange
                        }
                        onAnalyze={
                            handleAnalyze
                        }
                    />
                )}


                {/* RESULTS */}

                {showResults &&
                    results && (
                        <ResultsSection
                            results={results}
                            careerName={
                                selectedCareerName
                            }
                            onCopyShareLink={
                                handleCopyShareLink
                            }
                        />
                    )}


                {/* CAREER RECOMMENDATIONS */}

                {showResults &&
                    careerRecommendations.length >
                        0 && (
                        <CareerRecommendations
                            recommendations={
                                careerRecommendations
                            }
                        />
                    )}


                {/* RECOMMENDATION LOADING */}

                {showResults &&
                    loadingRecommendations && (
                        <p className="skill-loading">
                            Finding alternative career
                            recommendations...
                        </p>
                    )}

            </main>

            <Footer />
        </div>
    );
}

export default App;

