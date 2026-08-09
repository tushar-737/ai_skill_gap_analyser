import { useEffect, useMemo, useState } from "react";

import {
    getEducationPrograms,
    getDomains,
    getCareersByDomain,
    getCareerSkills,
    getCareersWithSkillsByDomain,
} from "./api/api";

import "./App.css";
import MatchChart from "./components/MatchChart";

function App() {
    // =====================================================
    // DATA
    // =====================================================

    const [education, setEducation] = useState([]);
    const [domains, setDomains] = useState([]);
    const [careers, setCareers] = useState([]);
    const [requiredSkills, setRequiredSkills] = useState([]);
    const [domainCareerSkills, setDomainCareerSkills] = useState([]);

    const [loadingRecommendations, setLoadingRecommendations] =
        useState(false);

    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [formError, setFormError] = useState("");

    const [selectedEducation, setSelectedEducation] = useState("");
    const [selectedDomain, setSelectedDomain] = useState("");
    const [selectedCareer, setSelectedCareer] = useState("");

    const [loadingCareers, setLoadingCareers] = useState(false);
    const [loadingSkills, setLoadingSkills] = useState(false);

    const [skillLevels, setSkillLevels] = useState({});
    const [showResults, setShowResults] = useState(false);

    // =====================================================
    // LOAD INITIAL DATA
    // =====================================================

    useEffect(() => {
        async function loadInitialData() {
            try {
                setLoading(true);
                setError("");

                const [educationData, domainData] = await Promise.all([
                    getEducationPrograms(),
                    getDomains(),
                ]);

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

                setError(
                    "Unable to connect to the backend."
                );
            } finally {
                setLoading(false);
            }
        }

        loadInitialData();
    }, []);

    // =====================================================
    // LOAD CAREERS WHEN DOMAIN CHANGES
    // =====================================================

    useEffect(() => {
        async function loadCareers() {
            if (!selectedDomain) {
                setCareers([]);
                setSelectedCareer("");
                setRequiredSkills([]);
                setSkillLevels({});
                setDomainCareerSkills([]);
                setShowResults(false);

                return;
            }

            try {
                setLoadingCareers(true);
                setError("");

                setSelectedCareer("");
                setRequiredSkills([]);
                setSkillLevels({});
                setShowResults(false);

                console.log(
                    "Loading careers for domain:",
                    selectedDomain
                );

                const data = await getCareersByDomain(
                    Number(selectedDomain)
                );

                console.log(
                    "Careers received:",
                    data
                );

                if (!Array.isArray(data)) {
                    throw new Error(
                        "Invalid careers response"
                    );
                }

                setCareers(data);
            } catch (error) {
                console.error(
                    "CAREERS ERROR:",
                    error
                );

                setCareers([]);

                setError(
                    "Unable to load careers."
                );
            } finally {
                setLoadingCareers(false);
            }
        }

        loadCareers();
    }, [selectedDomain]);

    // =====================================================
    // LOAD DOMAIN CAREER SKILLS
    // =====================================================

    useEffect(() => {
        async function loadDomainCareerSkills() {
            if (!selectedDomain) {
                setDomainCareerSkills([]);
                return;
            }

            try {
                setLoadingRecommendations(true);
                setError("");

                const data =
                    await getCareersWithSkillsByDomain(
                        Number(selectedDomain)
                    );

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

                setDomainCareerSkills([]);
            } finally {
                setLoadingRecommendations(false);
            }
        }

        loadDomainCareerSkills();
    }, [selectedDomain]);

    // =====================================================
    // CAREER RECOMMENDATIONS
    // =====================================================

    const careerRecommendations = useMemo(() => {
        if (
            !selectedCareer ||
            domainCareerSkills.length === 0
        ) {
            return [];
        }

        const currentSkillLevels =
            skillLevels || {};

        return domainCareerSkills
            .filter(
                (career) =>
                    String(career.id) !==
                    String(selectedCareer)
            )
            .map((career) => {
                const overlapping =
                    (career.skills || [])
                        .map((skill) => {
                            const current =
                                Number(
                                    currentSkillLevels[
                                        skill.skill_id
                                    ]
                                ) || 0;

                            return {
                                ...skill,
                                current,
                                gap: Math.max(
                                    skill.required_level -
                                        current,
                                    0
                                ),
                            };
                        })
                        .filter(
                            (skill) =>
                                skill.current > 0 ||
                                skill.required_level > 0
                        );

                const totalRequired =
                    overlapping.reduce(
                        (sum, skill) =>
                            sum +
                            Number(
                                skill.required_level
                            ),
                        0
                    );

                const totalCurrent =
                    overlapping.reduce(
                        (sum, skill) =>
                            sum +
                            Math.min(
                                skill.current,
                                Number(
                                    skill.required_level
                                )
                            ),
                        0
                    );

                return {
                    ...career,
                    overlapping,

                    matchScore:
                        totalRequired > 0
                            ? Math.round(
                                  (totalCurrent /
                                      totalRequired) *
                                      100
                              )
                            : 0,
                };
            })
            .filter(
                (career) =>
                    career.overlapping.length > 0
            )
            .sort(
                (a, b) =>
                    b.matchScore -
                    a.matchScore
            )
            .slice(0, 3);
    }, [
        domainCareerSkills,
        selectedCareer,
        skillLevels,
    ]);

    // =====================================================
    // LOAD REQUIRED SKILLS WHEN CAREER CHANGES
    // =====================================================

    useEffect(() => {
        async function loadSkills() {
            if (!selectedCareer) {
                setRequiredSkills([]);
                setSkillLevels({});
                return;
            }

            try {
                setLoadingSkills(true);
                setError("");

                console.log(
                    "Loading skills for career:",
                    selectedCareer
                );

                const careerId =
                    Number(selectedCareer);

                console.log(
                    "Career ID sent to API:",
                    careerId
                );

                const data =
                    await getCareerSkills(
                        careerId
                    );

                console.log(
                    "Skills received from backend:",
                    data
                );

                if (!Array.isArray(data)) {
                    console.error(
                        "Invalid skills response:",
                        data
                    );

                    setRequiredSkills([]);
                    setSkillLevels({});

                    setError(
                        "Invalid skills data received from backend."
                    );

                    return;
                }

                setRequiredSkills(data);

                const initialLevels = {};

                data.forEach((skill) => {
                    initialLevels[
                        skill.skill_id
                    ] = 0;
                });

                setSkillLevels(
                    initialLevels
                );

                setShowResults(false);
            } catch (error) {
                console.error(
                    "ERROR LOADING CAREER SKILLS:",
                    error
                );

                setRequiredSkills([]);
                setSkillLevels({});

                setError(
                    "Unable to load skills for this career."
                );
            } finally {
                setLoadingSkills(false);
            }
        }

        loadSkills();
    }, [selectedCareer]);

    // =====================================================
    // HANDLE SKILL CHANGE
    // =====================================================

    function handleSkillChange(
        skillId,
        value
    ) {
        setSkillLevels((previous) => ({
            ...previous,
            [skillId]: Number(value),
        }));

        setShowResults(false);
    }

    // =====================================================
    // CALCULATE RESULTS
    // =====================================================

    const results = useMemo(() => {
        if (requiredSkills.length === 0) {
            return null;
        }

        let totalRequired = 0;
        let totalCurrent = 0;

        const gaps = requiredSkills.map(
            (skill) => {
                const required =
                    Number(
                        skill.required_level
                    ) || 0;

                const current =
                    Number(
                        skillLevels[
                            skill.skill_id
                        ]
                    ) || 0;

                const gap = Math.max(
                    required - current,
                    0
                );

                totalRequired += required;

                totalCurrent += Math.min(
                    current,
                    required
                );

                return {
                    ...skill,
                    current,
                    gap,
                };
            }
        );

        // =================================================
        // MATCH SCORE
        // =================================================

        const matchScore =
            totalRequired > 0
                ? Math.round(
                      (totalCurrent /
                          totalRequired) *
                          100
                  )
                : 0;

        // =================================================
        // STRONG SKILLS
        // =================================================

        const strongSkills =
            gaps.filter(
                (skill) =>
                    skill.gap === 0
            );

        // =================================================
        // SKILL GAPS
        // =================================================

        const skillGaps =
            gaps
                .filter(
                    (skill) =>
                        skill.gap > 0
                )
                .sort(
                    (a, b) =>
                        b.gap - a.gap
                );

        // =================================================
        // READINESS
        // =================================================

        let readiness = "";

        if (matchScore >= 80) {
            readiness = "Highly Ready";
        } else if (matchScore >= 60) {
            readiness = "Career Ready";
        } else if (matchScore >= 40) {
            readiness = "Developing";
        } else {
            readiness = "Beginner";
        }

        return {
            matchScore,
            readiness,
            gaps,
            strongSkills,
            skillGaps,
        };
    }, [
        requiredSkills,
        skillLevels,
    ]);

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

        if (
            requiredSkills.length === 0
        ) {
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
    // LOADING SCREEN
    // =====================================================

    if (loading) {
        return (
            <div className="loading-screen">
                <div className="loader"></div>

                <h2>
                    AI Skill Gap Analyzer
                </h2>

                <p>
                    Connecting to database...
                </p>
            </div>
        );
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

            {/* =================================================
                HEADER
            ================================================= */}

            <header className="header">
                <div>
                    <div className="brand">
                        <span className="brand-icon">
                            AI
                        </span>

                        SkillGap

                        <span className="brand-highlight">
                            AI
                        </span>
                    </div>

                    <p className="subtitle">
                        AI-Powered Skill Gap &
                        Career Recommendation
                        System
                    </p>
                </div>
            </header>

            {/* =================================================
                HERO
            ================================================= */}

            <section className="hero">
                <span className="badge">
                    🚀 AI CAREER ANALYZER
                </span>

                <h1>
                    Discover Your
                    <span>
                        Career Potential
                    </span>
                </h1>

                <p>
                    Tell us about your education,
                    choose a career path, rate your
                    skills, and discover exactly what
                    you need to learn.
                </p>
            </section>

            {/* =================================================
                ASSESSMENT
            ================================================= */}

            <main
                id="main-content"
                className="assessment-container"
            >
                {/* =================================================
                    ERROR MESSAGE
                ================================================= */}

                {error && (
                    <div className="error-message">
                        {error}
                    </div>
                )}

                {formError && (
                    <div
                        className="error-message"
                        role="alert"
                    >
                        {formError}
                    </div>
                )}

                {/* =================================================
                    STEP 1 - EDUCATION
                ================================================= */}

                <section className="card">
                    <div className="step-number">
                        01
                    </div>

                    <div className="step-content">
                        <h2>
                            Education Background
                        </h2>

                        <p>
                            Select your current
                            degree or educational
                            program.
                        </p>

                        <select
                            aria-label="Education program"
                            value={
                                selectedEducation
                            }
                            onChange={(event) => {
                                setFormError("");
                                setSelectedEducation(
                                    event.target.value
                                );
                            }}
                        >
                            <option value="">
                                Select your education
                            </option>

                            {education.map(
                                (item) => (
                                    <option
                                        key={
                                            item.id
                                        }
                                        value={
                                            item.id
                                        }
                                    >
                                        {item.name}

                                        {item.level
                                            ? ` — ${item.level}`
                                            : ""}
                                    </option>
                                )
                            )}
                        </select>
                    </div>
                </section>

                {/* =================================================
                    STEP 2 - DOMAIN
                ================================================= */}

                <section className="card">
                    <div className="step-number">
                        02
                    </div>

                    <div className="step-content">
                        <h2>
                            Career Domain
                        </h2>

                        <p>
                            Choose the area you
                            want to build your
                            career in.
                        </p>

                        <select
                            aria-label="Career domain"
                            value={
                                selectedDomain
                            }
                            onChange={(event) => {
                                setFormError("");
                                setSelectedDomain(
                                    event.target.value
                                );
                            }}
                        >
                            <option value="">
                                Select a domain
                            </option>

                            {domains.map(
                                (domain) => (
                                    <option
                                        key={
                                            domain.id
                                        }
                                        value={
                                            domain.id
                                        }
                                    >
                                        {domain.name}
                                    </option>
                                )
                            )}
                        </select>
                    </div>
                </section>

                {/* =================================================
                    STEP 3 - TARGET CAREER
                ================================================= */}

                <section className="card">
                    <div className="step-number">
                        03
                    </div>

                    <div className="step-content">
                        <h2>
                            Target Career
                        </h2>

                        <p>
                            Select the career you
                            want to analyze your
                            skills for.
                        </p>

                        <select
                            aria-label="Target career"
                            value={
                                selectedCareer
                            }
                            onChange={(event) => {
                                setFormError("");
                                setSelectedCareer(
                                    event.target.value
                                );
                            }}
                            disabled={
                                !selectedDomain ||
                                loadingCareers
                            }
                        >
                            <option value="">
                                {loadingCareers
                                    ? "Loading careers..."
                                    : "Select a career"}
                            </option>

                            {careers.map(
                                (career) => (
                                    <option
                                        key={
                                            career.id
                                        }
                                        value={
                                            career.id
                                        }
                                    >
                                        {career.name}
                                    </option>
                                )
                            )}
                        </select>
                    </div>
                </section>

                {/* =================================================
                    STEP 4 - RATE YOUR SKILLS
                ================================================= */}

                {selectedCareer && (
                    <section className="card skills-card">
                        <div className="step-number">
                            04
                        </div>

                        <div className="step-content">
                            <h2>
                                Rate Your Skills
                            </h2>

                            <p>
                                Rate your current
                                proficiency from
                                0 to 100.
                            </p>

                            {/* =================================================
                                SKILL LOADING
                            ================================================= */}

                            {loadingSkills ? (
                                <div className="skill-loading">
                                    Loading required
                                    skills...
                                </div>
                            ) : requiredSkills.length ===
                              0 ? (
                                <div className="skill-loading">
                                    No skills have
                                    been configured
                                    for this career
                                    yet.
                                </div>
                            ) : (
                                <div className="skills-list">
                                    {requiredSkills.map(
                                        (skill) => (
                                            <div
                                                className="skill-row"
                                                key={
                                                    skill.skill_id
                                                }
                                            >
                                                <div className="skill-info">
                                                    <div>
                                                        <strong>
                                                            {
                                                                skill.skill
                                                            }
                                                        </strong>

                                                        <small>
                                                            {
                                                                skill.category
                                                            }
                                                        </small>
                                                    </div>

                                                    <span>
                                                        {
                                                            skillLevels[
                                                                skill
                                                                    .skill_id
                                                            ] || 0
                                                        }
                                                        %
                                                    </span>
                                                </div>

                                                <div className="skill-requirement">
                                                    Required:{" "}
                                                    {
                                                        skill.required_level
                                                    }
                                                    %
                                                </div>

                                                <input
                                                    type="range"
                                                    min="0"
                                                    max="100"
                                                    step="5"
                                                    value={
                                                        skillLevels[
                                                            skill
                                                                .skill_id
                                                        ] || 0
                                                    }
                                                    onChange={(
                                                        event
                                                    ) =>
                                                        handleSkillChange(
                                                            skill.skill_id,
                                                            event
                                                                .target
                                                                .value
                                                        )
                                                    }
                                                />
                                            </div>
                                        )
                                    )}
                                </div>
                            )}

                            {/* =================================================
                                ANALYZE BUTTON
                            ================================================= */}

                            <button
                                className="analyze-button"
                                aria-label="Analyze my skills"
                                onClick={
                                    handleAnalyze
                                }
                                disabled={
                                    loadingSkills ||
                                    requiredSkills.length ===
                                        0
                                }
                            >
                                Analyze My Skills

                                <span>
                                    →
                                </span>
                            </button>
                        </div>
                    </section>
                )}

                {/* =================================================
                    RESULTS
                ================================================= */}

                {showResults && results && (
                    <section
                        id="results"
                        className="results-section"
                    >
                        <div className="results-header">
                            <span className="badge">
                                ✨ ANALYSIS COMPLETE
                            </span>

                            <h2>
                                Your Career Analysis
                            </h2>

                            <p>
                                Here's how prepared
                                you are for your
                                selected career.
                            </p>
                        </div>

                        {/* =================================================
                            CAREER MATCH SCORE
                        ================================================= */}

                        <div className="score-card">
                            <div className="score-circle">
                                <MatchChart
                                    score={
                                        results.matchScore
                                    }
                                    size={120}
                                    stroke={12}
                                />
                            </div>

                            <div className="score-details">
                                <h3>
                                    {
                                        careers.find(
                                            (career) =>
                                                String(
                                                    career.id
                                                ) ===
                                                String(
                                                    selectedCareer
                                                )
                                        )?.name
                                    }
                                </h3>

                                <p>
                                    Your current career
                                    readiness
                                </p>

                                <strong className="readiness">
                                    {
                                        results.readiness
                                    }
                                </strong>
                            </div>
                        </div>

                        {/* =================================================
                            SUMMARY CARDS
                        ================================================= */}

                        <div className="analysis-summary">
                            <div className="summary-box">
                                <span className="summary-icon">
                                    ✓
                                </span>

                                <div>
                                    <strong>
                                        {
                                            results
                                                .strongSkills
                                                .length
                                        }
                                    </strong>

                                    <small>
                                        Strong Skills
                                    </small>
                                </div>
                            </div>

                            <div className="summary-box">
                                <span className="summary-icon">
                                    !
                                </span>

                                <div>
                                    <strong>
                                        {
                                            results
                                                .skillGaps
                                                .length
                                        }
                                    </strong>

                                    <small>
                                        Skill Gaps
                                    </small>
                                </div>
                            </div>

                            <div className="summary-box">
                                <span className="summary-icon">
                                    🎯
                                </span>

                                <div>
                                    <strong>
                                        {
                                            results
                                                .gaps
                                                .length
                                        }
                                    </strong>

                                    <small>
                                        Required Skills
                                    </small>
                                </div>
                            </div>
                        </div>

                        {/* =================================================
                            STRONG SKILLS
                        ================================================= */}

                        <div className="result-card">
                            <div className="result-card-header">
                                <h3>
                                    🟢 Your Strong
                                    Skills
                                </h3>

                                <span>
                                    {
                                        results
                                            .strongSkills
                                            .length
                                    }
                                </span>
                            </div>

                            {results.strongSkills
                                .length === 0 ? (
                                <p className="empty-message">
                                    No skills have
                                    reached the
                                    required level
                                    yet.
                                </p>
                            ) : (
                                <div
                                    className="result-list"
                                    role="list"
                                >
                                    {results.strongSkills.map(
                                        (skill) => (
                                            <div
                                                className="result-skill strong-skill"
                                                role="listitem"
                                                key={
                                                    skill.skill_id
                                                }
                                            >
                                                <div>
                                                    <strong>
                                                        {
                                                            skill.skill
                                                        }
                                                    </strong>

                                                    <span>
                                                        {
                                                            skill.category
                                                        }
                                                    </span>
                                                </div>

                                                <div>
                                                    <span>
                                                        Your
                                                        level:{" "}
                                                        {
                                                            skill.current
                                                        }
                                                        %
                                                    </span>

                                                    <span className="good">
                                                        ✓ Ready
                                                    </span>
                                                </div>
                                            </div>
                                        )
                                    )}
                                </div>
                            )}
                        </div>

                        {/* =================================================
                            SKILL GAPS
                        ================================================= */}

                        <div className="result-card">
                            <div className="result-card-header">
                                <h3>
                                    🔴 Skills You Need
                                    to Improve
                                </h3>

                                <span>
                                    {
                                        results
                                            .skillGaps
                                            .length
                                    }
                                </span>
                            </div>

                            {results.skillGaps
                                .length === 0 ? (
                                <div className="empty-message">
                                    🎉 Excellent! You
                                    don't have any
                                    major skill gaps.
                                </div>
                            ) : (
                                <div
                                    className="result-list"
                                    role="list"
                                >
                                    {results.skillGaps.map(
                                        (skill) => (
                                            <div
                                                className="result-skill gap-skill"
                                                role="listitem"
                                                key={
                                                    skill.skill_id
                                                }
                                            >
                                                <div>
                                                    <strong>
                                                        {
                                                            skill.skill
                                                        }
                                                    </strong>

                                                    <span>
                                                        {
                                                            skill.category
                                                        }
                                                    </span>
                                                </div>

                                                <div>
                                                    <span>
                                                        Your
                                                        level:{" "}
                                                        {
                                                            skill.current
                                                        }
                                                        %
                                                    </span>

                                                    <span>
                                                        Required:{" "}
                                                        {
                                                            skill.required_level
                                                        }
                                                        %
                                                    </span>

                                                    <span className="gap">
                                                        Gap:{" "}
                                                        {
                                                            skill.gap
                                                        }
                                                        %
                                                    </span>
                                                </div>
                                            </div>
                                        )
                                    )}
                                </div>
                            )}
                        </div>

                        {/* =================================================
                            PRIORITY LEARNING
                        ================================================= */}

                        {results.skillGaps
                            .length > 0 && (
                            <div className="result-card priority-card">
                                <div className="result-card-header">
                                    <h3>
                                        🎯 Priority
                                        Learning
                                    </h3>
                                </div>

                                <p className="priority-description">
                                    Focus on these
                                    skills first.
                                    They have the
                                    largest gaps
                                    compared with
                                    your target
                                    career
                                    requirements.
                                </p>

                                <div
                                    className="priority-list"
                                    role="list"
                                >
                                    {results.skillGaps
                                        .slice(0, 5)
                                        .map(
                                            (
                                                skill,
                                                index
                                            ) => (
                                                <div
                                                    className="priority-item"
                                                    role="listitem"
                                                    key={
                                                        skill.skill_id
                                                    }
                                                >
                                                    <span className="priority-number">
                                                        {
                                                            index +
                                                            1
                                                        }
                                                    </span>

                                                    <div>
                                                        <strong>
                                                            {
                                                                skill.skill
                                                            }
                                                        </strong>

                                                        <small>
                                                            Current:{" "}
                                                            {
                                                                skill.current
                                                            }
                                                            %
                                                            {" • "}
                                                            Required:{" "}
                                                            {
                                                                skill.required_level
                                                            }
                                                            %
                                                        </small>
                                                    </div>

                                                    <span className="priority-gap">
                                                        Gap:{" "}
                                                        {
                                                            skill.gap
                                                        }
                                                        %
                                                    </span>
                                                </div>
                                            )
                                        )}
                                </div>
                            </div>
                        )}

                        {/* =================================================
                            AI RECOMMENDATION
                        ================================================= */}

                        <div className="recommendation-card">
                            <h3>
                                🤖 AI Career
                                Recommendation
                            </h3>

                            {results.matchScore >=
                            80 ? (
                                <p>
                                    <strong>
                                        Excellent
                                        progress!
                                    </strong>{" "}
                                    You already
                                    have a strong
                                    foundation for
                                    this career.
                                    Focus on
                                    advanced
                                    projects,
                                    real-world
                                    experience,
                                    internships,
                                    and
                                    specialization.
                                </p>
                            ) : results.matchScore >=
                              60 ? (
                                <p>
                                    <strong>
                                        Good progress!
                                    </strong>{" "}
                                    You have a
                                    solid
                                    foundation for
                                    this career.
                                    Focus on your
                                    highest-priority
                                    skill gaps to
                                    improve your
                                    readiness.
                                </p>
                            ) : results.matchScore >=
                              40 ? (
                                <p>
                                    <strong>
                                        You're
                                        developing!
                                    </strong>{" "}
                                    You have
                                    started
                                    building the
                                    required
                                    foundation.
                                    Concentrate on
                                    the priority
                                    skills above
                                    and practice
                                    them through
                                    projects.
                                </p>
                            ) : (
                                <p>
                                    <strong>
                                        Start with
                                        the
                                        fundamentals.
                                    </strong>{" "}
                                    Build your core
                                    skills step by
                                    step,
                                    complete
                                    practical
                                    projects, and
                                    gradually work
                                    toward the
                                    requirements
                                    of your target
                                    career.
                                </p>
                            )}
                        </div>
                    </section>
                )}

                {/* =================================================
                    RECOMMENDED CAREERS
                ================================================= */}

                {showResults &&
                    careerRecommendations.length >
                        0 && (
                        <section className="recommendation-card">
                            <h3>
                                🚀 Recommended
                                Careers
                            </h3>

                            <p>
                                These careers share
                                skills with your
                                current profile and
                                may be strong
                                alternatives.
                            </p>

                            <div className="recommendation-list">
                                {careerRecommendations.map(
                                    (career) => (
                                        <div
                                            className="recommendation-item"
                                            role="listitem"
                                            key={
                                                career.id
                                            }
                                        >
                                            <div>
                                                <strong>
                                                    {
                                                        career.name
                                                    }
                                                </strong>

                                                <small>
                                                    {
                                                        career
                                                            .overlapping
                                                            .length
                                                    }{" "}
                                                    shared
                                                    skill
                                                    {career
                                                        .overlapping
                                                        .length >
                                                    1
                                                        ? "s"
                                                        : ""}{" "}
                                                    •{" "}
                                                    {
                                                        career.matchScore
                                                    }
                                                    % match
                                                </small>
                                            </div>

                                            <span>
                                                {
                                                    career.matchScore
                                                }
                                                %
                                            </span>
                                        </div>
                                    )
                                )}
                            </div>
                        </section>
                    )}

                {/* =================================================
                    RECOMMENDATION LOADING
                ================================================= */}

                {showResults &&
                    loadingRecommendations && (
                        <p className="skill-loading">
                            Finding alternative career
                            recommendations...
                        </p>
                    )}
            </main>

            {/* =================================================
                FOOTER
            ================================================= */}

            <footer>
                <p>
                    AI Skill Gap Analyzer
                </p>

                <span>
                    Full-Stack Career Intelligence
                    Platform
                </span>
            </footer>
        </div>
    );
}

export default App;