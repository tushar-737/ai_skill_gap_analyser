// Data Science field: only these unique main skills.
// Do not also show Supervised/Unsupervised/Feature Engineering,
// Statistics & Probability, Pandas & NumPy, or Data Visualization —
// those repeat Statistics, Pandas, NumPy, and Matplotlib.

export const MAX_MAIN_SKILLS = 10;

const ALIASES = {
    np: "numpy",
    numpy: "numpy",
    pd: "pandas",
    pandas: "pandas",
    "python pandas": "pandas",
    "pandas numpy": "pandas",
    "pandas & numpy": "pandas",
    sklearn: "scikit-learn",
    "scikit learn": "scikit-learn",
    "scikit-learn": "scikit-learn",
    ml: "machine learning",
    "machine-learning": "machine learning",
    dl: "deep learning",
    stats: "statistics",
    "statistics probability": "statistics",
    "statistics & probability": "statistics",
    "descriptive statistics": "statistics",
    "inferential statistics": "statistics",
    probability: "statistics",
    nlp: "natural language processing",
    eda: "data analysis",
    "exploratory data analysis": "data analysis",
    "data wrangling": "data analysis",
    "data cleaning": "data analysis",
    "data visualization": "matplotlib",
};

const DATA_SCIENCE_MAIN = [
    "Python",
    "R",
    "SQL",
    "Statistics",
    "Pandas",
    "NumPy",
    "Data Analysis",
    "Matplotlib",
];

const DATA_SCIENTIST_MAIN = [
    ...DATA_SCIENCE_MAIN,
    "Machine Learning",
    "Scikit-learn",
];

const AI_ML_MAIN = [
    "Python",
    "SQL",
    "Statistics",
    "Pandas",
    "NumPy",
    "Machine Learning",
    "Deep Learning",
    "Natural Language Processing",
];

export const CORE_SKILLS_BY_CAREER = {
    "data analyst": DATA_SCIENCE_MAIN,
    "data scientist": DATA_SCIENTIST_MAIN,
    "business intelligence analyst": DATA_SCIENCE_MAIN,
    "data visualization specialist": DATA_SCIENCE_MAIN,
    "quantitative analyst": DATA_SCIENCE_MAIN,
    "machine learning engineer": AI_ML_MAIN,
    "ai engineer": AI_ML_MAIN,
    "nlp engineer": AI_ML_MAIN,
    "computer vision engineer": AI_ML_MAIN,
    "deep learning engineer": AI_ML_MAIN,
};

function isDataScienceField(careerName = "", domainName = "") {
    const text = `${careerName} ${domainName}`.toLowerCase();
    return (
        text.includes("data science") ||
        text.includes("analytics") ||
        text.includes("data analyst") ||
        text.includes("data scientist") ||
        text.includes("quantitative") ||
        text.includes("business intelligence") ||
        text.includes("visualization specialist")
    );
}

function isAiMlField(careerName = "", domainName = "") {
    const text = `${careerName} ${domainName}`.toLowerCase();
    return (
        text.includes("machine learning") ||
        text.includes("artificial intelligence") ||
        text.includes("deep learning") ||
        text.includes("nlp") ||
        /\bai\b/.test(text)
    );
}

export function normalizeName(value = "") {
    const cleaned = String(value)
        .trim()
        .toLowerCase()
        .replace(/&amp;/g, "&")
        .replace(/[()]/g, "")
        .replace(/[&+/]/g, " ")
        .replace(/[\s_\-.]+/g, " ")
        .trim();
    return ALIASES[cleaned] || cleaned;
}

function skillLabel(skill) {
    return skill?.name || skill?.skill || skill?.skill_name || "";
}

function requiredLevel(skill) {
    return Number(skill?.required_level) || 0;
}

function isCanonicalName(skill, key) {
    return String(skillLabel(skill)).trim().toLowerCase() === key;
}

export function dedupeSkills(skills = []) {
    const best = new Map();
    skills.forEach((skill) => {
        const key = normalizeName(skillLabel(skill));
        if (!key) return;
        const previous = best.get(key);
        if (!previous) {
            best.set(key, skill);
            return;
        }
        const skillIsCanonical = isCanonicalName(skill, key);
        const previousIsCanonical = isCanonicalName(previous, key);
        if (skillIsCanonical && !previousIsCanonical) {
            best.set(key, skill);
            return;
        }
        if (!skillIsCanonical && previousIsCanonical) return;
        if (requiredLevel(skill) > requiredLevel(previous)) {
            best.set(key, skill);
        }
    });
    return Array.from(best.values());
}

function namesMatch(skillName, coreName) {
    return normalizeName(skillName) === normalizeName(coreName);
}

export function coreSkillsFor(careerName = "", domainName = "") {
    const career = normalizeName(careerName);

    if (CORE_SKILLS_BY_CAREER[career]) return CORE_SKILLS_BY_CAREER[career];

    const hit = Object.keys(CORE_SKILLS_BY_CAREER).find((key) => career.includes(key));
    if (hit) return CORE_SKILLS_BY_CAREER[hit];

    if (isAiMlField(careerName, domainName)) return AI_ML_MAIN;
    if (isDataScienceField(careerName, domainName)) return DATA_SCIENCE_MAIN;
    return null;
}

function pickFromCore(skills, coreNames) {
    const picked = [];
    const used = new Set();

    coreNames.forEach((coreName) => {
        const matches = skills.filter((skill) => {
            const id = skill.skill_id ?? skillLabel(skill);
            if (used.has(id)) return false;
            return namesMatch(skillLabel(skill), coreName);
        });
        if (matches.length === 0) return;
        const exact = matches.find(
            (skill) => normalizeName(skillLabel(skill)) === normalizeName(coreName)
                && skillLabel(skill).toLowerCase() === coreName.toLowerCase()
        );
        const match = exact || matches[0];
        used.add(match.skill_id ?? skillLabel(match));
        picked.push(match);
    });

    return picked;
}

export function selectMainSkills(careerName, skills = [], domainName = "") {
    const unique = dedupeSkills(skills);
    const core = coreSkillsFor(careerName, domainName);

    if (core) {
        return pickFromCore(unique, core).slice(0, MAX_MAIN_SKILLS);
    }

    return unique
        .sort((a, b) => requiredLevel(b) - requiredLevel(a))
        .slice(0, MAX_MAIN_SKILLS);
}
