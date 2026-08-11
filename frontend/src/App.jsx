import { useEffect, useMemo, useRef, useState } from "react";

import "./App.css";

import { useInitialData } from "./hooks/useInitialData";
import { useCareers } from "./hooks/useCareers";
import { useDomainCareerSkills } from "./hooks/useDomainCareerSkills";
import { useCareerSkills } from "./hooks/useCareerSkills";
import { useAiRoadmap } from "./hooks/useAiRoadmap";

import { computeCareerRecommendations, computeResults } from "./lib/scoring";
import { decodeShareState, encodeShareState, copyText } from "./lib/share";
import { loadState, saveState } from "./lib/storage";

import Header from "./components/layout/Header";
import Hero from "./components/layout/Hero";
import StatsSection from "./components/layout/StatsSection";
import HowItWorks from "./components/layout/HowItWorks";
import Architecture from "./components/layout/Architecture";
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
    const [selectedEducation, setSelectedEducation] = useState("");
    const [selectedDomain, setSelectedDomain] = useState("");
    const [selectedCareer, setSelectedCareer] = useState("");
    const [skillLevels, setSkillLevels] = useState({});
    const [showResults, setShowResults] = useState(false);
    const [resumeInfo, setResumeInfo] = useState(null);
    const [historyRefresh, setHistoryRefresh] = useState(0);
    const [wizardStep, setWizardStep] = useState(0);
    const [showWelcome, setShowWelcome] = useState(false);
    const [savedForWelcome, setSavedForWelcome] = useState(null);

    const [error, setError] = useState("");
    const [formError, setFormError] = useState("");

    const { education, domains, loading } = useInitialData(setError);
    const { careers, loading: loadingCareers } = useCareers(selectedDomain, setError);
    const { domainCareerSkills, loading: loadingRecommendations } = useDomainCareerSkills(selectedDomain);
    const { requiredSkills, loading: loadingSkills } = useCareerSkills(selectedCareer, setError);

    const pendingLevelsRef = useRef(null);
    const pendingResumeRef = useRef(null);

    // Restore: share link takes precedence, else show Welcome back if saved
    useEffect(() => {
        const shared = decodeShareState(window.location.hash);
        if (shared) {
            pendingLevelsRef.current = { c: String(shared.c || ""), l: shared.l || {}, showResults: true };
            setSelectedEducation(String(shared.e || ""));
            setSelectedDomain(String(shared.d || ""));
            setSelectedCareer(String(shared.c || ""));
            setWizardStep(3);
            return;
        }
        const saved = loadState();
        if (saved && saved.c) {
            setSavedForWelcome(saved);
            setShowWelcome(true);
        }
    }, []);

    useEffect(() => {
        // Don't persist the welcome-stash until user chooses Continue
        if (showWelcome) return;
        saveState({ e: selectedEducation, d: selectedDomain, c: selectedCareer, l: skillLevels, r: showResults });
    }, [selectedEducation, selectedDomain, selectedCareer, skillLevels, showResults, showWelcome]);

    useEffect(() => {
        if (!selectedCareer) {
            setSkillLevels({});
            return;
        }
        if (requiredSkills.length === 0) return;
        const pending = pendingLevelsRef.current;
        const resumePending = pendingResumeRef.current;
        const base = pending && String(pending.c) === String(selectedCareer) ? pending.l : {};
        const hasShareBase = pending && String(pending.c) === String(selectedCareer);
        const resumeBase = !hasShareBase && resumePending ? resumePending : {};
        const initialLevels = {};
        requiredSkills.forEach((skill) => {
            const sid = String(skill.skill_id);
            if (hasShareBase && base[sid] !== undefined) initialLevels[skill.skill_id] = Number(base[sid]) || 0;
            else if (resumeBase[sid] !== undefined) initialLevels[skill.skill_id] = Number(resumeBase[sid]) || 0;
            else if (base[sid] !== undefined) initialLevels[skill.skill_id] = Number(base[sid]) || 0;
            else initialLevels[skill.skill_id] = 0;
        });
        setSkillLevels(initialLevels);
        pendingLevelsRef.current = null;
        if (resumePending && !hasShareBase) pendingResumeRef.current = null;
        if (pending && pending.showResults) setShowResults(true);
        else setShowResults(false);
    }, [selectedCareer, requiredSkills]);

    function handleWelcomeContinue() {
        const saved = savedForWelcome;
        if (!saved) return;
        pendingLevelsRef.current = { c: String(saved.c), l: saved.l || {}, showResults: Boolean(saved.r) };
        setSelectedEducation(String(saved.e || ""));
        setSelectedDomain(String(saved.d || ""));
        setSelectedCareer(String(saved.c || ""));
        setWizardStep(3);
        setShowWelcome(false);
        setSavedForWelcome(null);
    }

    function handleWelcomeNew() {
        try {
            localStorage.removeItem("skillgap:state:v1");
        } catch {}
        setShowWelcome(false);
        setSavedForWelcome(null);
        handleReset(false);
    }

    function handleResumeExtracted(data) {
        setResumeInfo(data);
        setHistoryRefresh((k) => k + 1);
        setError("");
        if (data?.inferred_levels) {
            const inferred = data.inferred_levels;
            const sourceLabel = data.extraction_source === "groq" ? "Groq AI" : data.extraction_source === "gemini" ? "Gemini AI" : "Keyword";
            if (selectedCareer && requiredSkills.length > 0) {
                setSkillLevels((prev) => {
                    const next = { ...prev };
                    requiredSkills.forEach((s) => {
                        const key = String(s.skill_id);
                        if (inferred[key] !== undefined) next[s.skill_id] = Number(inferred[key]);
                    });
                    return next;
                });
                setFormError(`✓ Resume parsed (${sourceLabel}): ${data.extracted_skills?.length || 0} skills auto-filled. Adjust sliders and click Analyze.`);
                setTimeout(() => document.querySelector(".skills-rater")?.scrollIntoView({ behavior: "smooth" }), 200);
            } else {
                pendingResumeRef.current = inferred;
                setFormError(`✓ Resume parsed (${sourceLabel}): ${data.extracted_skills?.length || 0} skills found. Now select a domain & career to see them auto-filled.`);
            }
        } else if (data?.extracted_skills) {
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
        setTimeout(() => document.querySelector(".skills-rater")?.scrollIntoView({ behavior: "smooth" }), 200);
    }

    function clearShareHash() {
        if (window.location.hash.startsWith("#/share/")) {
            window.history.replaceState(null, "", window.location.pathname + window.location.search);
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
        setSkillLevels((prev) => ({ ...prev, [skillId]: Number(value) }));
        setShowResults(false);
    }

    function handleAnalyze() {
        setFormError("");
        if (!selectedEducation) {
            setFormError("Please select your education.");
            setWizardStep(0);
            return;
        }
        if (!selectedDomain) {
            setFormError("Please select a career domain.");
            setWizardStep(1);
            return;
        }
        if (!selectedCareer) {
            setFormError("Please select a target career.");
            setWizardStep(2);
            return;
        }
        if (requiredSkills.length === 0) {
            setFormError("We couldn't load the skills for this career. Please check your connection and try again.");
            return;
        }
        setShowResults(true);
        setWizardStep(4);
        setTimeout(() => document.getElementById("results")?.scrollIntoView({ behavior: "smooth" }), 100);
    }

    async function handleCopyShareLink() {
        const payload = { e: selectedEducation, d: selectedDomain, c: selectedCareer, l: skillLevels };
        const url = window.location.origin + window.location.pathname + "#/share/" + encodeShareState(payload);
        return copyText(url);
    }

    function handleReset(withConfirm = true) {
        if (withConfirm && !window.confirm("Start a new assessment? This will clear your current selections and results. Resume history in Workbench will stay.")) return;
        setSelectedEducation("");
        setSelectedDomain("");
        setSelectedCareer("");
        setSkillLevels({});
        setShowResults(false);
        setFormError("");
        setError("");
        setResumeInfo(null);
        pendingLevelsRef.current = null;
        pendingResumeRef.current = null;
        setWizardStep(0);
        try {
            localStorage.removeItem("skillgap:state:v1");
        } catch {}
        clearShareHash();
        window.history.replaceState(null, "", window.location.pathname + window.location.search);
        window.scrollTo({ top: 0, behavior: "smooth" });
    }

    const results = useMemo(() => computeResults(requiredSkills, skillLevels), [requiredSkills, skillLevels]);
    const careerRecommendations = useMemo(() => computeCareerRecommendations(domainCareerSkills, selectedCareer, skillLevels), [domainCareerSkills, selectedCareer, skillLevels]);
    const selectedCareerName = careers.find((c) => String(c.id) === String(selectedCareer))?.name;

    const { roadmap: aiRoadmap, loading: loadingRoadmap, error: roadmapError } = useAiRoadmap({
        active: showResults && Boolean(results),
        careerName: selectedCareerName,
        matchScore: results?.matchScore ?? 0,
        skillGaps: results?.skillGaps ?? [],
        strongSkills: results?.strongSkills ?? [],
        education: selectedEducation,
    });

    // Step 1 of 5 indicator
    const totalSteps = 5;
    const displayStep = showResults ? 5 : wizardStep + 1;

    if (loading) return <LoadingScreen />;

    return (
        <div className="app">
            <a className="skip-link" href="#main-content">
                Skip to main content
            </a>
            <Header onReset={() => handleReset(true)} />
            <Hero />
            <StatsSection />

            <main id="main-content" className="assessment-container">
                {/* Welcome back */}
                {showWelcome && savedForWelcome && (
                    <div className="welcome-card">
                        <div>
                            <h3>Welcome back 👋</h3>
                            <p>You have an unfinished assessment for {careers.find((c) => String(c.id) === String(savedForWelcome.c))?.name || "your career"}.</p>
                        </div>
                        <div className="welcome-actions">
                            <button type="button" className="analyze-button" onClick={handleWelcomeContinue} style={{ maxWidth: 180, marginTop: 0 }}>
                                Continue Assessment
                            </button>
                            <button type="button" className="secondary-button" onClick={handleWelcomeNew}>
                                Start New
                            </button>
                        </div>
                    </div>
                )}

                <div className="step-indicator">
                    <span>
                        Step {displayStep} of {totalSteps}
                    </span>
                    <div className="step-dots" aria-hidden>
                        {Array.from({ length: totalSteps }).map((_, i) => (
                            <span key={i} className={`dot ${i < displayStep ? "filled" : ""} ${i + 1 === displayStep ? "active" : ""}`} />
                        ))}
                    </div>
                </div>

                <Stepper activeStep={showResults ? 4 : wizardStep} onStepClick={(idx) => (idx < wizardStep || showResults ? setWizardStep(idx) : null)} />

                <div className="reset-bar">
                    <span>Want a fresh start?</span>
                    <button type="button" className="secondary-button" onClick={() => handleReset(true)} style={{ padding: "8px 14px", fontSize: 13 }}>
                        ↺ Reset Assessment
                    </button>
                </div>

                {error && <ErrorBanner message={error} />}
                {formError && <ErrorBanner message={formError} />}

                {/* Wizard: only current step visible, previous as summary */}
                {wizardStep === 0 && (
                    <EducationStep
                        education={education}
                        value={selectedEducation}
                        onChange={handleEducationChange}
                        onContinue={() => {
                            if (!selectedEducation) {
                                setFormError("Please select your education to continue.");
                                return;
                            }
                            setWizardStep(1);
                            setTimeout(() => document.getElementById("domain-step")?.scrollIntoView({ behavior: "smooth", block: "start" }), 50);
                        }}
                        stepLabel="Step 1 of 5"
                    />
                )}
                {wizardStep > 0 && (
                    <div className="wizard-summary" onClick={() => setWizardStep(0)} role="button" tabIndex={0}>
                        <span>✓</span> <strong>Education:</strong> {education.find((e) => String(e.id) === String(selectedEducation))?.name || "—"} <em>(edit)</em>
                    </div>
                )}

                {wizardStep === 1 && (
                    <div id="domain-step">
                        <DomainStep
                            domains={domains}
                            value={selectedDomain}
                            onChange={handleDomainChange}
                            onContinue={() => {
                                if (!selectedDomain) {
                                    setFormError("Please select a career domain.");
                                    return;
                                }
                                setWizardStep(2);
                            }}
                            onBack={() => setWizardStep(0)}
                            stepLabel="Step 2 of 5"
                        />
                    </div>
                )}
                {wizardStep > 1 && selectedDomain && (
                    <div className="wizard-summary" onClick={() => setWizardStep(1)} role="button" tabIndex={0}>
                        <span>✓</span> <strong>Domain:</strong> {domains.find((d) => String(d.id) === String(selectedDomain))?.name || "—"} <em>(edit)</em>
                    </div>
                )}

                {wizardStep === 2 && (
                    <CareerStep
                        careers={careers}
                        loading={loadingCareers}
                        disabled={!selectedDomain}
                        value={selectedCareer}
                        onChange={handleCareerChange}
                        onContinue={() => {
                            if (!selectedCareer) {
                                setFormError("Please select a target career.");
                                return;
                            }
                            setWizardStep(3);
                        }}
                        onBack={() => setWizardStep(1)}
                        stepLabel="Step 3 of 5"
                    />
                )}
                {wizardStep > 2 && selectedCareer && (
                    <div className="wizard-summary" onClick={() => setWizardStep(2)} role="button" tabIndex={0}>
                        <span>✓</span> <strong>Career:</strong> {careers.find((c) => String(c.id) === String(selectedCareer))?.name || "—"} <em>(edit)</em>
                    </div>
                )}

                {wizardStep === 3 && (
                    <>
                        <div className="journey-card" style={{ padding: "18px 20px" }}>
                            <div className="journey-header">
                                <div className="journey-icon" aria-hidden>
                                    📄
                                </div>
                                <div>
                                    <span className="journey-kicker">Step 4 of 5 — Resume (Optional)</span>
                                    <h2>Have a resume?</h2>
                                    <p>Upload it and we&apos;ll use your existing skills to help build your profile. Or skip and rate manually.</p>
                                </div>
                                <span className="journey-step-badge">4</span>
                            </div>
                            <div style={{ display: "flex", gap: 10, marginTop: 10 }}>
                                <button type="button" className="secondary-button" onClick={() => setWizardStep(2)}>
                                    ← Back
                                </button>
                                <button type="button" className="secondary-button" onClick={() => document.querySelector(".skills-rater")?.scrollIntoView({ behavior: "smooth" })}>
                                    Skip for now
                                </button>
                            </div>
                        </div>

                        <ResumeUploader selectedCareer={selectedCareer} selectedEducation={selectedEducation} onExtracted={handleResumeExtracted} />
                        <ResumeHistory onReload={handleHistoryReload} refreshKey={historyRefresh} />
                    </>
                )}

                {wizardStep >= 3 && selectedCareer && (
                    <>
                        <div className="skill-intro">
                            <h3>📊 Rate your current skills</h3>
                            <p>
                                Move each slider to the level you think best represents your current ability. <strong>0% = Beginner · 50% = Intermediate · 100% = Advanced</strong>. Your score will be
                                compared with the level required for your target career.
                            </p>
                            <div className="skill-scale">
                                <span>0 Beginner</span>
                                <span>25</span>
                                <span>50 Intermediate</span>
                                <span>75</span>
                                <span>100 Advanced</span>
                            </div>
                            {requiredSkills.length > 0 && (
                                <div className="skill-progress">
                                    <span>
                                        Skills rated: {Object.keys(skillLevels).filter((k) => skillLevels[k] > 0).length} / {requiredSkills.length}
                                    </span>
                                    <div className="skill-progress-track">
                                        <div className="skill-progress-fill" style={{ width: `${Math.round((Object.keys(skillLevels).filter((k) => skillLevels[k] > 0).length / Math.max(1, requiredSkills.length)) * 100)}%` }} />
                                    </div>
                                </div>
                            )}
                        </div>

                        <SkillsRater skills={requiredSkills} levels={skillLevels} loading={loadingSkills} onSkillChange={handleSkillChange} onAnalyze={handleAnalyze} />

                        <div className="journey-actions" style={{ justifyContent: "space-between", marginTop: 12 }}>
                            <button type="button" className="secondary-button" onClick={() => setWizardStep(2)}>
                                ← Back to Career
                            </button>
                            <button type="button" className="secondary-button" onClick={() => window.scrollTo({ top: 0, behavior: "smooth" })}>
                                ↑ Back to top
                            </button>
                        </div>
                    </>
                )}

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

                {showResults && careerRecommendations.length > 0 && <CareerRecommendations recommendations={careerRecommendations} />}

                {showResults && loadingRecommendations && <p className="skill-loading">Finding alternative career recommendations...</p>}

                {!showResults && wizardStep === 3 && requiredSkills.length > 0 && (
                    <div className="analyze-hint">
                        <button type="button" className="analyze-button" onClick={handleAnalyze} style={{ maxWidth: 280 }}>
                            Analyze My Skill Gap →
                        </button>
                        <small>Compare your skills with the requirements for your target career. Takes about 10 seconds.</small>
                    </div>
                )}
            </main>

            <HowItWorks />
            <Architecture />
            <Footer />
        </div>
    );
}

export default App;
