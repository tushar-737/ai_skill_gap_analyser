const ALIASES = {
    bca: "BCA",
    "bachelor of computer applications": "BCA",
    mca: "MCA",
    "master of computer applications": "MCA",
    pgdca: "PGDCA",
    bcom: "B.Com",
    "bachelor of commerce": "B.Com",
    "bcom hons": "B.Com Hons",
    mcom: "M.Com",
    "master of commerce": "M.Com",
    bba: "BBA",
    mba: "MBA",
    bms: "BMS",
    pgdm: "PGDM",
    ca: "CA",
    cma: "CMA",
    bed: "B.Ed",
    med: "M.Ed",
    bdes: "B.Des",
    mdes: "M.Des",
    bpharm: "B.Pharm",
    "bsc computer science": "BSc Computer Science",
    "bsc cs": "BSc Computer Science",
    "bsc it": "BSc IT",
};

export function normalizeEducationName(name = "") {
    return String(name)
        .trim()
        .toLowerCase()
        .replace(/[.()]/g, "")
        .replace(/\s+/g, " ")
        .replace(/honou?rs/g, "hons")
        .trim();
}

export function displayEducationName(name = "") {
    const key = normalizeEducationName(name);
    return ALIASES[key] || String(name).trim();
}

export function dedupeEducationPrograms(programs = []) {
    const best = new Map();
    programs.forEach((program) => {
        const raw = (program.name || "").trim();
        if (!raw) return;
        const key = normalizeEducationName(raw);
        const next = { ...program, name: displayEducationName(raw) };
        const previous = best.get(key);
        if (!previous || Number(next.id) < Number(previous.id)) {
            best.set(key, next);
        }
    });
    return Array.from(best.values()).sort((a, b) =>
        String(a.name).localeCompare(String(b.name), undefined, { sensitivity: "base" })
    );
}
