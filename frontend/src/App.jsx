import { useEffect, useMemo, useRef, useState } from "react";

import "./App.css";

import { useInitialData } from "./hooks/useInitialData";
import { useCareers } from "./hooks/useCareers";
import { useDomainCareerSkills } from "./hooks/useDomainCareerSkills";
import { useCareerSkills } from "./hooks/useCareerSkills";
import { useAiRoadmap } from "./hooks/useAiRoadmap";

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
import ResumeUploader from "./components/assessment/ResumeUploader";
import ResumeHistory from "./components/resume/ResumeHistory";
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
    // Resume-inferred levels: { [skill_id]: level } — applied when career loads
    const [resumeInfo, setResumeInfo] = useState(null);
    const [historyRefresh, setHistoryRefresh] = useState(0);

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
    const pendingResumeRef = useRef(null);

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
        // Resume-inferred levels take precedence over 0, but share-link levels win over resume
        const resumePending = pendingResumeRef.current;

        const base =
            pending && String(pending.c) === String(selectedCareer)
                ? pending.l
                : {};

        const hasShareBase = pending && String(pending.c) === String(selectedCareer);
        const resumeBase = !hasShareBase && resumePending ? resumePending : {};

        const initialLevels = {};

        requiredSkills.forEach((skill) => {
            const sid = String(skill.skill_id);
            if (hasShareBase && base[sid] !== undefined) {
                initialLevels[skill.skill_id] = Number(base[sid]) || 0;
            } else if (resumeBase[sid] !== undefined) {
                initialLevels[skill.skill_id] = Number(resumeBase[sid]) || 0;
            } else if (base[sid] !== undefined) {
                initialLevels[skill.skill_id] = Number(base[sid]) || 0;
            } else {
                initialLevels[skill.skill_id] = 0;
            }
        });

        setSkillLevels(initialLevels);
        pendingLevelsRef.current = null;
        // keep resume pending for next career change? clear only after consumed once
        if (resumePending && !hasShareBase) pendingResumeRef.current = null;

        if (pending && pending.showResults) {
            setShowResults(true);
        } else {
            setShowResults(false);
        }
    }, [selectedCareer, requiredSkills]);

    // =====================================================
    // RESUME HANDLER — auto-fill sliders from extracted skills
    // =====================================================

    function handleResumeExtracted(data) {
        setResumeInfo(data);
        setHistoryRefresh((k) => k + 1);
        setError("");
        // Store inferred levels for next career load or apply immediately
        if (data?.inferred_levels) {
            const inferred = data.inferred_levels; // { "1": 70, ... }
            const sourceLabel =
                data.extraction_source === "groq"
                    ? "Groq AI"
                    : data.extraction_source === "gemini"
                      ? "Gemini AI"
                      : "Keyword";
            if (selectedCareer && requiredSkills.length > 0) {
                // Apply now to current career's skills
                setSkillLevels((prev) => {
                    const next = { ...prev };
                    requiredSkills.forEach((s) => {
                        const key = String(s.skill_id);
                        if (inferred[key] !== undefined) {
                            next[s.skill_id] = Number(inferred[key]);
                        }
                    });
                    return next;
                });
                setFormError(
                    `✓ Resume parsed (${sourceLabel}): ${data.extracted_skills?.length || 0} skills auto-filled. Adjust sliders and click Analyze.`
                );
                // Scroll to SkillsRater
                setTimeout(() => {
                    document.querySelector(".skills-rater")?.scrollIntoView({ behavior: "smooth" });
                }, 200);
            } else {
                // No career yet — stash for when career loads
                pendingResumeRef.current = inferred;
                setFormError(
                    `✓ Resume parsed (${sourceLabel}): ${data.extracted_skills?.length || 0} skills found. Now select a domain & career to see them auto-filled.`
                );
            }
        } else if (data?.extracted_skills) {
            // History reload sends extracted_skills directly
            const inferred = {};
            data.extracted_skills.forEach((s) => {
                if (s.skill_id) inferred[String(s.skill_id)] = s.inferred_level;
            });
            if (Object.keys(inferred).length > 0) {
                if (selectedCareer && requiredSkills.length > 0) {
                    setSkillLevels((prev) => {
                        const next = { ...prev };
                        requiredSkills.forEach((s) => {
                            const k = String(s.skill_id);
                            if (inferred[k] !== undefined) next[s.skill_id] = Number(inferred[k]);
                        });
                        return next;
                    });
                    setFormError(`✓ Reloaded ${data.file_name || "resume"} — ${Object.keys(inferred).length} skills restored.`);
                } else {
                    pendingResumeRef.current = inferred;
                    setFormError(`✓ Reloaded ${data.file_name || "resume"} — select a career to see skills.`);
                }
            }
        }
    }

    function handleHistoryReload(row) {
        const payload = {
            file_name: row.file_name,
            extracted_skills: row.extracted_skills?.skills || [],
            inferred_levels: (() => {
                const m = {};
                (row.extracted_skills?.skills || []).forEach((s) => {
                    if (s.skill_id) m[String(s.skill_id)] = s.inferred_level;
                });
                return m;
            })(),
            extraction_source: row.extraction_source,
            summary: row.extracted_skills?.summary || "",
        };
        handleResumeExtracted(payload);
        setTimeout(() => {
            document.querySelector(".skills-rater")?.scrollIntoView({ behavior: "smooth" });
        }, 200);
    }

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
    // AI-GENERATED LEARNING ROADMAP
    // =====================================================

    const {
        roadmap: aiRoadmap,
        loading: loadingRoadmap,
        error: roadmapError,
    } = useAiRoadmap({
        active: showResults && Boolean(results),
        careerName: selectedCareerName,
        matchScore: results?.matchScore ?? 0,
        skillGaps: results?.skillGaps ?? [],
        strongSkills: results?.strongSkills ?? [],
        education: selectedEducation,
    });

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
                    RESUME UPLOAD — AI extracts skills to auto-fill
                    Works with Gemini passkey on backend + Workbench
                ========================================= */}

                <ResumeUploader
                    selectedCareer={selectedCareer}
                    selectedEducation={selectedEducation}
                    onExtracted={handleResumeExtracted}
                />

                <ResumeHistory onReload={handleHistoryReload} refreshKey={historyRefresh} />

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
                        aiRoadmap={aiRoadmap}
                        loadingRoadmap={loadingRoadmap}
                        roadmapError={roadmapError}
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
