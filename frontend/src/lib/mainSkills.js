// Keep the rater to the skills that actually define a role.
// Seed data repeats Pandas/NumPy and dumps extra languages onto
// Data Science careers. This runs in the browser so a stale API
// cannot keep showing the long list.

export const MAX_MAIN_SKILLS = 6;

const ALIASES = {
    np: "numpy",
    numpy: "numpy",
    pd: "pandas",
    pandas: "pandas",
    "python pandas": "pandas",
    sklearn: "scikit-learn",
    "scikit learn": "scikit-learn",
    "scikit-learn": "scikit-learn",
    ml: "machine learning",
    "machine-learning": "machine learning",
    dl: "deep learning",
    powerbi: "power bi",
    "ms excel": "excel",
    "microsoft excel": "excel",
    eda: "exploratory data analysis",
    "data wrangling": "data cleaning",
    "descriptive statistics": "statistics",
    "inferential statistics": "statistics",
    stats: "statistics",
    nlp: "natural language processing",
    mysql: "sql",
    postgresql: "sql",
    postgres: "sql",
};

export const CORE_SKILLS_BY_CAREER = {
    "data analyst": ["Python", "SQL", "Excel", "Power BI", "Statistics", "Data Cleaning"],
    "data scientist": ["Python", "SQL", "Pandas", "Machine Learning", "Statistics", "Scikit-learn"],
    "business intelligence analyst": ["SQL", "Excel", "Power BI", "Tableau", "Data Analysis", "Dashboard Design"],
    "data visualization specialist": ["Tableau", "Power BI", "Python", "Dashboard Design", "Data Storytelling"],
    "quantitative analyst": ["Python", "SQL", "Statistics", "Probability", "Regression Analysis"],
    "machine learning engineer": ["Python", "Machine Learning", "Scikit-learn", "SQL", "Feature Engineering"],
    "ai engineer": ["Python", "Machine Learning", "Deep Learning", "PyTorch", "Generative AI"],
    "nlp engineer": ["Python", "Natural Language Processing", "Machine Learning", "Deep Learning"],
    "computer vision engineer": ["Python", "Computer Vision", "Deep Learning", "PyTorch"],
    "deep learning engineer": ["Python", "Deep Learning", "PyTorch", "Neural Networks"],
    "data engineer": ["Python", "SQL", "ETL", "AWS", "Docker"],
};

const DATA_DOMAIN_DEFAULT = ["Python", "SQL", "Pandas", "Statistics", "Machine Learning", "Excel"];

const EXTRA = new Set([
    "java",
    "c",
    "c++",
    "c#",
    "javascript",
    "typescript",
    "php",
    "html",
    "css",
    "react",
    "angular",
    "vue.js",
    "engineering drawing",
    "cad",
    "autocad",
    "solidworks",
    "quality control",
    "vs code",
    "gitlab",
    "github",
    "jupyter notebook",
    "git",
    "numpy",
    "matplotlib",
    "seaborn",
    "plotly",
    "mongodb",
    "oracle database",
    "oracle",
    "communication",
    "problem solving",
    "teamwork",
    "leadership",
]);

export function normalizeName(value = "") {
    const cleaned = String(value)
        .trim()
        .toLowerCase()
        .replace(/[()]/g, "")
        .replace(/[\s_\-./]+/g, " ");
    return ALIASES[cleaned] || cleaned;
}

function skillLabel(skill) {
    return skill?.name || skill?.skill || skill?.skill_name || "";
}

function requiredLevel(skill) {
    return Number(skill?.required_level) || 0;
}

export function dedupeSkills(skills = []) {
    const best = new Map();
    skills.forEach((skill) => {
        const key = normalizeName(skillLabel(skill));
        if (!key) return;
        const previous = best.get(key);
        if (!previous || requiredLevel(skill) > requiredLevel(previous)) {
            best.set(key, skill);
        }
    });
    return Array.from(best.values());
}

function namesMatch(skillName, coreName) {
    const skill = normalizeName(skillName);
    const core = normalizeName(coreName);
    if (!skill || !core) return false;
    if (skill === core) return true;
    if (core.length <= 3) return skill === core;
    return skill.includes(core) || core.includes(skill);
}

export function coreSkillsFor(careerName = "", domainName = "") {
    const career = normalizeName(careerName);
    const domain = normalizeName(domainName);

    if (CORE_SKILLS_BY_CAREER[career]) return CORE_SKILLS_BY_CAREER[career];

    const hit = Object.keys(CORE_SKILLS_BY_CAREER).find(
        (key) => career.includes(key) || key.includes(career)
    );
    if (hit) return CORE_SKILLS_BY_CAREER[hit];

    if (
        domain.includes("data science") ||
        domain.includes("analytics") ||
        career.includes("data")
    ) {
        return DATA_DOMAIN_DEFAULT;
    }

    if (
        domain.includes("machine learning") ||
        domain.includes("artificial intelligence") ||
        career.includes("machine learning") ||
        career.includes("ai ")
    ) {
        return CORE_SKILLS_BY_CAREER["machine learning engineer"];
    }

    return null;
}

function pickFromCore(skills, coreNames) {
    const picked = [];
    const used = new Set();

    coreNames.forEach((coreName) => {
        const match = skills.find((skill) => {
            const id = skill.skill_id ?? skillLabel(skill);
            if (used.has(id)) return false;
            return namesMatch(skillLabel(skill), coreName);
        });
        if (match) {
            used.add(match.skill_id ?? skillLabel(match));
            picked.push(match);
        }
    });

    return picked;
}

function dropExtras(skills) {
    return skills.filter((skill) => {
        const key = normalizeName(skillLabel(skill));
        return key && !EXTRA.has(key);
    });
}

export function selectMainSkills(careerName, skills = [], domainName = "") {
    const unique = dedupeSkills(skills);
    const core = coreSkillsFor(careerName, domainName);

    if (core) {
        const fromCore = pickFromCore(unique, core);
        if (fromCore.length > 0) return fromCore.slice(0, MAX_MAIN_SKILLS);
    }

    return dropExtras(unique)
        .sort((a, b) => requiredLevel(b) - requiredLevel(a))
        .slice(0, MAX_MAIN_SKILLS);
}
