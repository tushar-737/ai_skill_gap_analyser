
import { useMemo, useState } from "react";
import { selectMainSkills } from "../../lib/mainSkills";

const CATEGORY_ICON = {
    Programming: "🐍",
    "Data Analysis": "📊",
    "Data Analytics": "📊",
    Data: "📊",
    "AI & ML": "🤖",
    "Machine Learning": "🤖",
    Tools: "🛠️",
    Design: "🎨",
    Database: "🗄️",
    Databases: "🗄️",
    Cloud: "☁️",
    "Web Development": "🌐",
    default: "📦",
};

function getIcon(cat) {
    return CATEGORY_ICON[cat] || CATEGORY_ICON.default;
}

function getPriority(gap) {
    if (gap > 50) return { label: "Critical", cls: "critical" };
    if (gap > 30) return { label: "High", cls: "high" };
    if (gap > 10) return { label: "Medium", cls: "medium" };
    return { label: "Low", cls: "low" };
}

export default function SkillsRater({
    skills = [],
    levels = {},
    loading = false,
    onSkillChange = () => {},
    onAnalyze = () => {},
    careerName = "",
    domainName = "",
}) {
    skills = useMemo(
        () => selectMainSkills(careerName, skills, domainName),
        [skills, careerName, domainName]
    );
    const [search, setSearch] = useState("");
    const [categoryFilter, setCategoryFilter] = useState("All");
    const [statusFilter, setStatusFilter] = useState("All");
    const [collapsed, setCollapsed] = useState({});

    const total = skills.length;

    const rated = skills.filter(
        (skill) => Number(levels[skill.skill_id]) > 0
    ).length;

    const pct = total ? Math.round((rated / total) * 100) : 0;

    // All categories
    const categories = useMemo(() => {
        return [...new Set(skills.map((s) => s.category || "Other"))];
    }, [skills]);

    // Filter skills
    const filteredSkills = useMemo(() => {
        const query = search.trim().toLowerCase();

        return skills.filter((skill) => {
            const name = (
                skill.name ||
                skill.skill_name ||
                `Skill ${skill.skill_id}`
            ).toLowerCase();

            const category = skill.category || "Other";
            const level = Number(levels[skill.skill_id]) || 0;

            const matchesSearch =
                !query ||
                name.includes(query) ||
                category.toLowerCase().includes(query);

            const matchesCategory =
                categoryFilter === "All" || category === categoryFilter;

            const matchesStatus =
                statusFilter === "All" ||
                (statusFilter === "Rated" && level > 0) ||
                (statusFilter === "Not rated" && level === 0);

            return (
                matchesSearch &&
                matchesCategory &&
                matchesStatus
            );
        });
    }, [skills, levels, search, categoryFilter, statusFilter]);

    // Group filtered skills
    const grouped = useMemo(() => {
        return filteredSkills.reduce((acc, skill) => {
            const cat = skill.category || "Other";

            if (!acc[cat]) {
                acc[cat] = [];
            }

            acc[cat].push(skill);
            return acc;
        }, {});
    }, [filteredSkills]);

    // Top 3 largest gaps
    const topGaps = [...skills]
        .map((s) => ({
            ...s,
            gap: Math.max(
                0,
                Number(s.required_level) -
                    (Number(levels[s.skill_id]) || 0)
            ),
        }))
        .sort((a, b) => b.gap - a.gap)
        .slice(0, 3)
        .filter((s) => s.gap > 0);

    function toggleCategory(category) {
        setCollapsed((prev) => ({
            ...prev,
            [category]: !prev[category],
        }));
    }

    function clearFilters() {
        setSearch("");
        setCategoryFilter("All");
        setStatusFilter("All");
    }

    return (
        <section className="assessment-step journey-card skills-rater">
            <div className="journey-header">
                <div className="journey-icon" aria-hidden>
                    📊
                </div>

                <div>
                    <span className="journey-kicker">
                        Step 4 — Your Skills
                    </span>

                    <h2>Rate the main skills only</h2>

                    <p>
                        Only the core skills for this role are listed.
                        Repeated libraries and extra languages are hidden.
                    </p>
                </div>

                <span className="journey-step-badge">4</span>
            </div>

            {loading ? (
                <p className="skill-loading">
                    Loading required skills...
                </p>
            ) : skills.length === 0 ? (
                <p className="skill-loading">
                    No skills found for this career.
                </p>
            ) : (
                <>
                    {/* Intro + progress */}
                    <div className="skill-intro-inline">
                        <p>
                            Move each slider to your level.
                            <strong>
                                {" "}
                                0% = Beginner · 50% = Intermediate ·
                                100% = Advanced
                            </strong>
                            . Your score is compared with the required
                            level for your target career.
                        </p>

                        <div
                            className="skill-progress"
                            style={{ marginTop: 10 }}
                        >
                            <span>
                                Skills rated: {rated} / {total}
                            </span>

                            <div
                                className="skill-progress-track"
                                style={{
                                    flex: 1,
                                    maxWidth: 220,
                                    marginLeft: 10,
                                }}
                            >
                                <div
                                    className="skill-progress-fill"
                                    style={{
                                        width: `${pct}%`,
                                    }}
                                />
                            </div>

                            <span>{pct}%</span>
                        </div>
                    </div>

                    {/* Search + filters */}
                    <div className="skills-toolbar">
                        <div className="skills-search-wrapper">
                            <span className="skills-search-icon">
                                🔍
                            </span>

                            <input
                                type="search"
                                className="skills-search"
                                placeholder="Search skills... e.g. Python, SQL, Java"
                                value={search}
                                onChange={(e) =>
                                    setSearch(e.target.value)
                                }
                                aria-label="Search skills"
                            />

                            {search && (
                                <button
                                    type="button"
                                    className="skills-search-clear"
                                    onClick={() => setSearch("")}
                                    aria-label="Clear skill search"
                                >
                                    ×
                                </button>
                            )}
                        </div>

                        <div className="skills-filters">
                            <select
                                value={categoryFilter}
                                onChange={(e) =>
                                    setCategoryFilter(e.target.value)
                                }
                                className="skills-filter-select"
                                aria-label="Filter by category"
                            >
                                <option value="All">
                                    All Categories
                                </option>

                                {categories.map((category) => (
                                    <option
                                        key={category}
                                        value={category}
                                    >
                                        {category}
                                    </option>
                                ))}
                            </select>

                            <select
                                value={statusFilter}
                                onChange={(e) =>
                                    setStatusFilter(e.target.value)
                                }
                                className="skills-filter-select"
                                aria-label="Filter by rating status"
                            >
                                <option value="All">
                                    All Skills
                                </option>
                                <option value="Rated">
                                    Rated
                                </option>
                                <option value="Not rated">
                                    Not Rated
                                </option>
                            </select>
                        </div>

                        {(search ||
                            categoryFilter !== "All" ||
                            statusFilter !== "All") && (
                            <button
                                type="button"
                                className="secondary-button skills-clear-filters"
                                onClick={clearFilters}
                            >
                                Clear filters
                            </button>
                        )}
                    </div>

                    {/* Search result count */}
                    <div className="skills-result-info">
                        Showing{" "}
                        <strong>{filteredSkills.length}</strong> of{" "}
                        <strong>{total}</strong> skills
                        {search && (
                            <>
                                {" "}
                                for <strong>“{search}”</strong>
                            </>
                        )}
                    </div>

                    {/* Skills */}
                    {Object.keys(grouped).length === 0 ? (
                        <div className="skills-empty-state">
                            <div className="skills-empty-icon">
                                🔎
                            </div>

                            <h3>No skills found</h3>

                            <p>
                                Try a different search term or remove
                                one of the filters.
                            </p>

                            <button
                                type="button"
                                className="secondary-button"
                                onClick={clearFilters}
                            >
                                Show all skills
                            </button>
                        </div>
                    ) : (
                        <div className="skills-grouped">
                            {Object.entries(grouped).map(
                                ([cat, list]) => {
                                    const isCollapsed =
                                        collapsed[cat];

                                    const categoryRated =
                                        list.filter(
                                            (skill) =>
                                                Number(
                                                    levels[
                                                        skill.skill_id
                                                    ]
                                                ) > 0
                                        ).length;

                                    return (
                                        <div
                                            key={cat}
                                            className="skill-group"
                                        >
                                            <button
                                                type="button"
                                                className="skill-group-header"
                                                onClick={() =>
                                                    toggleCategory(
                                                        cat
                                                    )
                                                }
                                                aria-expanded={
                                                    !isCollapsed
                                                }
                                            >
                                                <span
                                                    className="skill-group-icon"
                                                    aria-hidden
                                                >
                                                    {getIcon(cat)}
                                                </span>

                                                <h3>{cat}</h3>

                                                <span className="skill-group-progress">
                                                    {categoryRated}/
                                                    {list.length}
                                                </span>

                                                <span className="skill-group-count">
                                                    {list.length}
                                                </span>

                                                <span className="skill-group-chevron">
                                                    {isCollapsed
                                                        ? "⌄"
                                                        : "⌃"}
                                                </span>
                                            </button>

                                            {!isCollapsed && (
                                                <div className="skills-list skills-list-v2">
                                                    {list.map(
                                                        (skill) => {
                                                            const skillId =
                                                                skill.skill_id;

                                                            const currentLevel =
                                                                Number(
                                                                    levels[
                                                                        skillId
                                                                    ]
                                                                ) || 0;

                                                            const required =
                                                                Number(
                                                                    skill.required_level
                                                                ) || 0;

                                                            const gap =
                                                                Math.max(
                                                                    0,
                                                                    required -
                                                                        currentLevel
                                                                );

                                                            const pctCurrent =
                                                                Math.min(
                                                                    100,
                                                                    Math.max(
                                                                        0,
                                                                        currentLevel
                                                                    )
                                                                );

                                                            const pctRequired =
                                                                Math.min(
                                                                    100,
                                                                    Math.max(
                                                                        0,
                                                                        required
                                                                    )
                                                                );

                                                            const isNotFamiliar =
                                                                currentLevel ===
                                                                0;

                                                            const pri =
                                                                getPriority(
                                                                    gap
                                                                );

                                                            const skillName =
                                                                skill.name ||
                                                                skill.skill_name ||
                                                                `Skill ${skillId}`;

                                                            return (
                                                                <div
                                                                    className={`skill-item-v2 ${
                                                                        gap ===
                                                                        0
                                                                            ? "is-strong"
                                                                            : "has-gap"
                                                                    }`}
                                                                    key={
                                                                        skillId
                                                                    }
                                                                >
                                                                    <div className="skill-v2-header">
                                                                        <label
                                                                            htmlFor={`skill-${skillId}`}
                                                                            className="skill-v2-name"
                                                                        >
                                                                            {
                                                                                skillName
                                                                            }
                                                                        </label>

                                                                        <div className="skill-v2-meta">
                                                                            <span className="skill-v2-current">
                                                                                {
                                                                                    currentLevel
                                                                                }
                                                                                %
                                                                            </span>

                                                                            <span className="skill-v2-divider">
                                                                                /
                                                                            </span>

                                                                            <span className="skill-v2-required">
                                                                                {
                                                                                    required
                                                                                }
                                                                                %
                                                                            </span>

                                                                            <span
                                                                                className={`skill-v2-pri pri-${pri.cls}`}
                                                                            >
                                                                                {
                                                                                    pri.label
                                                                                }
                                                                            </span>
                                                                        </div>
                                                                    </div>

                                                                    <div className="skill-bar-row">
                                                                        <span className="skill-bar-label">
                                                                            Your
                                                                            level
                                                                            ●
                                                                        </span>

                                                                        <div className="skill-track">
                                                                            <div
                                                                                className="skill-fill skill-fill-your"
                                                                                style={{
                                                                                    width: `${pctCurrent}%`,
                                                                                }}
                                                                            />
                                                                        </div>

                                                                        <span className="skill-bar-value">
                                                                            {
                                                                                pctCurrent
                                                                            }
                                                                            %
                                                                        </span>
                                                                    </div>

                                                                    <div className="skill-bar-row required">
                                                                        <span className="skill-bar-label">
                                                                            Required
                                                                            ●
                                                                        </span>

                                                                        <div className="skill-track">
                                                                            <div
                                                                                className="skill-fill skill-fill-required"
                                                                                style={{
                                                                                    width: `${pctRequired}%`,
                                                                                }}
                                                                            />
                                                                        </div>

                                                                        <span className="skill-bar-value required">
                                                                            {
                                                                                pctRequired
                                                                            }
                                                                            %
                                                                        </span>
                                                                    </div>

                                                                    <div className="skill-item-footer">
                                                                        <span
                                                                            className={`skill-gap-badge ${
                                                                                gap ===
                                                                                0
                                                                                    ? "good"
                                                                                    : pri.cls
                                                                            }`}
                                                                        >
                                                                            {gap ===
                                                                            0
                                                                                ? "✓ Ready"
                                                                                : `Gap: ${gap}% · Needs development`}
                                                                        </span>

                                                                        <button
                                                                            type="button"
                                                                            className={`not-familiar-btn ${
                                                                                isNotFamiliar
                                                                                    ? "active"
                                                                                    : ""
                                                                            }`}
                                                                            onClick={() =>
                                                                                onSkillChange(
                                                                                    skillId,
                                                                                    0
                                                                                )
                                                                            }
                                                                            aria-pressed={
                                                                                isNotFamiliar
                                                                            }
                                                                            title="Mark this skill as not familiar (0%)"
                                                                        >
                                                                            {isNotFamiliar
                                                                                ? "☑ Not familiar"
                                                                                : "☐ Not familiar"}
                                                                        </button>
                                                                    </div>

                                                                    <div
                                                                        className="skill-scale-ticks"
                                                                        aria-hidden
                                                                    >
                                                                        <span>
                                                                            0
                                                                        </span>
                                                                        <span>
                                                                            25
                                                                        </span>
                                                                        <span>
                                                                            50
                                                                        </span>
                                                                        <span>
                                                                            75
                                                                        </span>
                                                                        <span>
                                                                            100
                                                                        </span>
                                                                    </div>

                                                                    <div
                                                                        className="skill-scale-labels"
                                                                        aria-hidden
                                                                    >
                                                                        <span>
                                                                            Beginner
                                                                        </span>
                                                                        <span>
                                                                            Intermediate
                                                                        </span>
                                                                        <span>
                                                                            Advanced
                                                                        </span>
                                                                    </div>

                                                                    <input
                                                                        id={`skill-${skillId}`}
                                                                        type="range"
                                                                        min="0"
                                                                        max="100"
                                                                        step="5"
                                                                        value={
                                                                            currentLevel
                                                                        }
                                                                        onChange={(
                                                                            e
                                                                        ) =>
                                                                            onSkillChange(
                                                                                skillId,
                                                                                e
                                                                                    .target
                                                                                    .value
                                                                            )
                                                                        }
                                                                        aria-label={`${skillName} current ${currentLevel}%, required ${required}%, gap ${gap}%`}
                                                                    />
                                                                </div>
                                                            );
                                                        }
                                                    )}
                                                </div>
                                            )}
                                        </div>
                                    );
                                }
                            )}
                        </div>
                    )}

                    {/* Top priorities */}
                    {topGaps.length > 0 && (
                        <div className="top-priority-preview">
                            <h4>Top 3 priorities</h4>

                            <div className="top-priority-list">
                                {topGaps.map((s, i) => (
                                    <span
                                        key={s.skill_id}
                                        className="top-priority-chip"
                                    >
                                        0{i + 1}{" "}
                                        {s.name ||
                                            s.skill_name ||
                                            `Skill ${s.skill_id}`}{" "}
                                        <em>
                                            Gap {s.gap}%
                                        </em>
                                    </span>
                                ))}
                            </div>
                        </div>
                    )}

                    {/* Analyze */}
                    <button
                        type="button"
                        className="analyze-button"
                        onClick={onAnalyze}
                    >
                        Analyze My Skill Gap →
                    </button>

                    <small
                        style={{
                            display: "block",
                            textAlign: "center",
                            color: "#64748b",
                            marginTop: 8,
                            fontSize: 12,
                        }}
                    >
                        Takes about 10 seconds • Compares your
                        skills with requirements for your target
                        career
                    </small>
                </>
            )}
        </section>
    );
}
