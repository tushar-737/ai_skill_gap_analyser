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
import { decodeShareState, encodeShareState, copyText } from "./lib/share";
import { loadState, saveState } from "./lib/storage";

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

    const [selectedEducation, setSelectedEducation] = useState("");
    const [selectedDomain, setSelectedDomain] = useState("");
    const [selectedCareer, setSelectedCareer] = useState("");
    const [skillLevels, setSkillLevels] = useState({});
    const [showResults, setShowResults] = useState(false);

    // =====================================================
    // ERROR STATE
    // =====================================================

    const [error, setError] = useState("");
    const [formError, setFormError] = useState("");

    // =====================================================
    // DATA (custom hooks — each fetches its own resource)
    // =====================================================

    const { education, domains, loading } = useInitialData(setError);
    const { careers, loading: loadingCareers } = useCareers(
        selectedDomain,
        setError
    );
    const { domainCareerSkills, loading: loadingRecommendations } =
        useDomainCareerSkills(selectedDomain);
    const { requiredSkills, loading: loadingSkills } = useCareerSkills(
        selectedCareer,
        setError
    );

    // =====================================================
    // RESTORE (share link first, then saved state)
    // =====================================================
    //
    // Skill levels for the restored career are held in a ref
    // and applied once the career's skills finish loading
    // (the effect below consumes it), so they aren't reset.

    const pendingLevelsRef = useRef(null);

    useEffect(() => {
        const shared = decodeShareState(window.location.hash);

        if (shared) {
            pendingLevelsRef.current = {
                c: String(shared.c || ""),
                l: shared.l || {},
                showResults: true,
            };

            setSelectedEducation(String(shared.e || ""));
            setSelectedDomain(String(shared.d || ""));
            setSelectedCareer(String(shared.c || ""));
            return;
        }

        const saved = loadState();

        if (saved && saved.c) {
            pendingLevelsRef.current = {
                c: String(saved.c),
                l: saved.l || {},
                showResults: Boolean(saved.r),
            };

            setSelectedEducation(String(saved.e || ""));
            setSelectedDomain(String(saved.d || ""));
            setSelectedCareer(String(saved.c || ""));
        }
    }, []);

    // =====================================================
    // PERSIST SELECTIONS BETWEEN VISITS
    // =====================================================

    useEffect(() => {
        saveState({
            e: selectedEducation,
            d: selectedDomain,
            c: selectedCareer,
            l: skillLevels,
            r: showResults,
        });
    }, [selectedEducation, selectedDomain, selectedCareer, skillLevels, showResults]);

    // =====================================================
    // APPLY SKILL LEVELS WHEN THE TARGET CAREER CHANGES
    // =====================================================
    //
    // Normal career change → all levels start at 0.
    // Restored state (share link / saved visit) → levels
    // from the payload are applied once skills load.

    useEffect(() => {
        if (!selectedCareer) {
            setSkillLevels({});
            return;
        }

        if (requiredSkills.length === 0) return;

        const pending = pendingLevelsRef.current;
        const base =
            pending && String(pending.c) === String(selectedCareer)
                ? pending.l
                : {};

        const initialLevels = {};

        requiredSkills.forEach((skill) => {
            initialLevels[skill.skill_id] =
                Number(base[skill.skill_id]) || 0;
        });

        setSkillLevels(initialLevels);
        pendingLevelsRef.current = null;

        if (pending && pending.showResults) {
            setShowResults(true);
        } else {
            setShowResults(false);
        }
    }, [selectedCareer, requiredSkills]);

    // =====================================================
    // HANDLERS
    // =====================================================

    function clearShareHash() {
        if (window.location.hash.startsWith("#/share/")) {
            window.history.replaceState(
                null,
                "",
                window.location.pathname + window.location.search
            );
        }
    }

    function handleEducationChange(value) {
        setFormError("");
        clearShareHash();
        setSelectedEducation(value);
    }

    function handleDomainChange(value) {
        setFormError("");
        clearShareHash();
        setSelectedDomain(value);

        // Career-dependent state is no longer valid
        setSelectedCareer("");
        setSkillLevels({});
        setShowResults(false);
    }

    function handleCareerChange(value) {
        setFormError("");
        clearShareHash();
        setSelectedCareer(value);
        setShowResults(false);
    }

    function handleSkillChange(skillId, value) {
        setFormError("");
        clearShareHash();
        setSkillLevels((previous) => ({
            ...previous,
            [skillId]: Number(value),
        }));

        setShowResults(false);
    }

    function handleAnalyze() {
        setFormError("");

        if (!selectedEducation) {
            setFormError("Please select your education.");
            return;
        }

        if (!selectedDomain) {
            setFormError("Please select a career domain.");
            return;
        }

        if (!selectedCareer) {
            setFormError("Please select a target career.");
            return;
        }

        if (requiredSkills.length === 0) {
            setFormError("No skills found for this career.");
            return;
        }

        setShowResults(true);

        setTimeout(() => {
            document.getElementById("results")?.scrollIntoView({
                behavior: "smooth",
            });
        }, 100);
    }

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
    // COMPUTED RESULTS (pure functions from lib/scoring.js)
    // =====================================================

    const results = useMemo(
        () => computeResults(requiredSkills, skillLevels),
        [requiredSkills, skillLevels]
    );

    const careerRecommendations = useMemo(
        () =>
            computeCareerRecommendations(
                domainCareerSkills,
                selectedCareer,
                skillLevels
            ),
        [domainCareerSkills, selectedCareer, skillLevels]
    );

    const selectedCareerName = careers.find(
        (career) =>
            String(career.id) === String(selectedCareer)
    )?.name;

    // =====================================================
    // STEPPER STATE
    // =====================================================

    const activeStep = !selectedEducation
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
        <div className="app">
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
                <Stepper activeStep={activeStep} />

                {/* =========================================
                    ERROR MESSAGES
                ========================================= */}

                {error && <ErrorBanner message={error} />}
                {formError && <ErrorBanner message={formError} />}

                {/* =========================================
                    STEPS 1-3
                ========================================= */}

                <EducationStep
                    education={education}
                    value={selectedEducation}
                    onChange={handleEducationChange}
                />

                <DomainStep
                    domains={domains}
                    value={selectedDomain}
                    onChange={handleDomainChange}
                />

                <CareerStep
                    careers={careers}
                    loading={loadingCareers}
                    disabled={!selectedDomain}
                    value={selectedCareer}
                    onChange={handleCareerChange}
                />

                {/* =========================================
                    STEP 4 — RATE YOUR SKILLS
                ========================================= */}

                {selectedCareer && (
                    <SkillsRater
                        skills={requiredSkills}
                        levels={skillLevels}
                        loading={loadingSkills}
                        onSkillChange={handleSkillChange}
                        onAnalyze={handleAnalyze}
                    />
                )}

                {/* =========================================
                    RESULTS
                ========================================= */}

                {showResults && results && (
                    <ResultsSection
                        results={results}
                        careerName={selectedCareerName}
                        onCopyShareLink={handleCopyShareLink}
                    />
                )}

                {/* =========================================
                    RECOMMENDED CAREERS
                ========================================= */}

                {showResults &&
                    careerRecommendations.length > 0 && (
                        <CareerRecommendations
                            recommendations={
                                careerRecommendations
                            }
                        />
                    )}

                {/* =========================================
                    RECOMMENDATION LOADING
                ========================================= */}

                {showResults && loadingRecommendations && (
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
