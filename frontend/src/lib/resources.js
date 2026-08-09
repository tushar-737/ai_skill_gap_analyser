// =====================================================
// LEARNING RESOURCES — skill → curated links
// =====================================================
//
// Each skill maps to 2-3 high-quality, stable resources:
// official docs, a roadmap, and a free course/guide.
// Unknown skills fall back to a targeted web search.

const RESOURCES = {
    python: [
        { label: "Official Docs", url: "https://docs.python.org/3/" },
        { label: "Python Roadmap", url: "https://roadmap.sh/python" },
        { label: "Free Course", url: "https://www.freecodecamp.org/learn/scientific-computing-with-python/" },
    ],
    javascript: [
        { label: "MDN Docs", url: "https://developer.mozilla.org/en-US/docs/Web/JavaScript" },
        { label: "JS Roadmap", url: "https://roadmap.sh/javascript" },
        { label: "Free Course", url: "https://javascript.info/" },
    ],
    typescript: [
        { label: "TS Handbook", url: "https://www.typescriptlang.org/docs/handbook/intro.html" },
        { label: "TS Roadmap", url: "https://roadmap.sh/typescript" },
        { label: "Free Course", url: "https://www.freecodecamp.org/news/learn-typescript-beginners-guide/" },
    ],
    react: [
        { label: "React Docs", url: "https://react.dev/learn" },
        { label: "React Roadmap", url: "https://roadmap.sh/react" },
        { label: "Free Course", url: "https://www.freecodecamp.org/learn/front-end-development-libraries/" },
    ],
    html: [
        { label: "MDN Docs", url: "https://developer.mozilla.org/en-US/docs/Web/HTML" },
        { label: "Tutorial", url: "https://www.w3schools.com/html/" },
    ],
    css: [
        { label: "MDN Docs", url: "https://developer.mozilla.org/en-US/docs/Web/CSS" },
        { label: "Tutorial", url: "https://web.dev/learn/css" },
    ],
    tailwind: [
        { label: "Tailwind Docs", url: "https://tailwindcss.com/docs" },
        { label: "Tutorial", url: "https://www.freecodecamp.org/news/tailwind-css-tutorial/" },
    ],
    sql: [
        { label: "SQL Tutorial", url: "https://www.w3schools.com/sql/" },
        { label: "Learn SQL", url: "https://www.kaggle.com/learn/intro-to-sql" },
    ],
    mysql: [
        { label: "MySQL Docs", url: "https://dev.mysql.com/doc/" },
        { label: "Tutorial", url: "https://www.w3schools.com/mysql/" },
    ],
    postgresql: [
        { label: "PostgreSQL Docs", url: "https://www.postgresql.org/docs/" },
        { label: "Tutorial", url: "https://www.postgresqltutorial.com/" },
    ],
    pandas: [
        { label: "Pandas Docs", url: "https://pandas.pydata.org/docs/" },
        { label: "Free Course", url: "https://www.kaggle.com/learn/pandas" },
    ],
    numpy: [
        { label: "NumPy Docs", url: "https://numpy.org/doc/stable/" },
        { label: "Tutorial", url: "https://numpy.org/learn/" },
    ],
    "machine learning": [
        { label: "ML Roadmap", url: "https://roadmap.sh/ai-data-scientist" },
        { label: "Free Course", url: "https://www.coursera.org/learn/machine-learning" },
        { label: "Kaggle Learn", url: "https://www.kaggle.com/learn/intro-to-machine-learning" },
    ],
    statistics: [
        { label: "Khan Academy", url: "https://www.khanacademy.org/math/statistics-probability" },
        { label: "Free Course", url: "https://www.kaggle.com/learn/statistics" },
    ],
    "deep learning": [
        { label: "DeepLearning.AI", url: "https://www.coursera.org/specializations/deep-learning" },
        { label: "PyTorch Guide", url: "https://pytorch.org/tutorials/beginner/basics/intro.html" },
    ],
    "power bi": [
        { label: "MS Learn", url: "https://learn.microsoft.com/en-us/training/powerplatform/power-bi" },
        { label: "Tutorial", url: "https://www.datacamp.com/tutorial/power-bi" },
    ],
    excel: [
        { label: "Excel Guide", url: "https://support.microsoft.com/en-us/excel" },
        { label: "Free Course", url: "https://www.kaggle.com/learn/excel" },
    ],
    git: [
        { label: "Git Docs", url: "https://git-scm.com/doc" },
        { label: "Learn Git", url: "https://learngitbranching.js.org/" },
    ],
    api: [
        { label: "MDN Guide", url: "https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Client-side_web_APIs/Introduction" },
        { label: "REST Guide", url: "https://restfulapi.net/" },
    ],
    django: [
        { label: "Django Docs", url: "https://docs.djangoproject.com/" },
        { label: "Django Roadmap", url: "https://roadmap.sh/django" },
    ],
    fastapi: [
        { label: "FastAPI Docs", url: "https://fastapi.tiangolo.com/" },
        { label: "Tutorial", url: "https://fastapi.tiangolo.com/tutorial/" },
    ],
    flask: [
        { label: "Flask Docs", url: "https://flask.palletsprojects.com/" },
        { label: "Tutorial", url: "https://flask.palletsprojects.com/en/stable/tutorial/" },
    ],
    "node.js": [
        { label: "Node Docs", url: "https://nodejs.org/docs/latest/api/" },
        { label: "Node Roadmap", url: "https://roadmap.sh/nodejs" },
    ],
    docker: [
        { label: "Docker Docs", url: "https://docs.docker.com/" },
        { label: "Docker Roadmap", url: "https://roadmap.sh/docker" },
    ],
    aws: [
        { label: "AWS Docs", url: "https://docs.aws.amazon.com/" },
        { label: "AWS Roadmap", url: "https://roadmap.sh/aws" },
    ],
    "data analysis": [
        { label: "Kaggle Learn", url: "https://www.kaggle.com/learn/data-cleaning" },
        { label: "Data Analyst Roadmap", url: "https://roadmap.sh/data-analyst" },
    ],
    "data science": [
        { label: "DS Roadmap", url: "https://roadmap.sh/ai-data-scientist" },
        { label: "Kaggle Learn", url: "https://www.kaggle.com/learn" },
    ],
    tableau: [
        { label: "Tableau Tutorial", url: "https://www.tableau.com/learn/articles/tableau-tutorials" },
    ],
    r: [
        { label: "R Docs", url: "https://www.r-project.org/other-docs.html" },
        { label: "R for Data Science", url: "https://r4ds.hadley.nz/" },
    ],
    tensorflow: [
        { label: "TF Docs", url: "https://www.tensorflow.org/tutorials" },
    ],
    pytorch: [
        { label: "PyTorch Docs", url: "https://pytorch.org/tutorials/" },
    ],
};

// Aliases → canonical keys in RESOURCES
const ALIASES = {
    js: "javascript",
    ts: "typescript",
    "nodejs": "node.js",
    "node": "node.js",
    "tailwind css": "tailwind",
    "ml": "machine learning",
    "dl": "deep learning",
    "powerbi": "power bi",
    "scikit-learn": "machine learning",
    "scikit learn": "machine learning",
};

function normalize(name) {
    return String(name || "")
        .toLowerCase()
        .trim()
        .replace(/\s+/g, " ");
}

// =====================================================
// GET LEARNING LINKS FOR A SKILL
// =====================================================

export function getLearningLinks(skillName) {
    const normalized = normalize(skillName);

    const key = RESOURCES[normalized]
        ? normalized
        : ALIASES[normalized] || null;

    if (key) {
        return RESOURCES[key];
    }

    // Fallback: targeted web search
    const query = encodeURIComponent(
        `${skillName || "skill"} learning resources`
    );

    return [
        {
            label: "Search resources",
            url: `https://www.google.com/search?q=${query}`,
        },
    ];
}
