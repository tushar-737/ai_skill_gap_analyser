import { useEffect, useMemo, useState } from "react";

import "./App.css";

import { useInitialData } from "./hooks/useInitialData";
import { useCareers } from "./hooks/useCareers";
import { useDomainCareerSkills } from "./hooks/useDomainCareerSkills";
import { useCareerSkills } from "./hooks/useCareerSkills";

import { computeCareerRecommendations, computeResults } from "./lib/scoring";

import Header from "./components/layout/Header";
import Hero from "./components/layout/Hero";
import Footer from "./components/layout/Footer";
import LoadingScreen from "./components/ui/LoadingScreen";
import ErrorBanner from "./components/ui/ErrorBanner";
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
    const { careers, loading: loadingCareers } = useCareers(selectedDomain, setError);
    const { domainCareerSkills, loading: loadingRecommendations } =
        useDomainCareerSkills(selectedDomain);
    const { requiredSkills, loading: loadingSkills } = useCareerSkills(
        selectedCareer,
        setError
    );

    // =====================================================
    // RESET SKILL LEVELS WHEN THE TARGET CAREER CHANGES
    // =====================================================

    useEffect(() => {
        if (!selectedCareer) {
            setSkillLevels({});
            return;
        }

        const initialLevels = {};

        requiredSkills.forEach((skill) => {
            initialLevels[skill.skill_id] = 0;
        });

        setSkillLevels(initialLevels);
        setShowResults(false);
    }, [selectedCareer, requiredSkills]);

    // =====================================================
    // HANDLERS
    // =====================================================

    function handleEducationChange(value) {
        setFormError("");
        setSelectedEducation(value);
    }

    function handleDomainChange(value) {
        setFormError("");
        setSelectedDomain(value);

        // Career-dependent state is no longer valid
        setSelectedCareer("");
        setSkillLevels({});
        setShowResults(false);
    }

    function handleCareerChange(value) {
        setFormError("");
        setSelectedCareer(value);
        setShowResults(false);
    }

    function handleSkillChange(skillId, value) {
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
        (career) => String(career.id) === String(selectedCareer)
    )?.name;

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
