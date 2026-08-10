
const API_BASE_URL = "http://127.0.0.1:8000";

export async function getEducationCategories() {
    const response = await fetch(
        `${API_BASE_URL}/api/education-categories`
    );

    if (!response.ok) {
        throw new Error("Failed to fetch education categories");
    }

    return response.json();
}

export async function getEducationPrograms() {
    const response = await fetch(
        `${API_BASE_URL}/api/education-programs`
    );

    if (!response.ok) {
        throw new Error("Failed to fetch education programs");
    }

    return response.json();
}

export async function getDomains() {
    const response = await fetch(
        `${API_BASE_URL}/api/domains`
    );

    if (!response.ok) {
        throw new Error("Failed to fetch domains");
    }

    return response.json();
}

export async function getCareers() {
    const response = await fetch(
        `${API_BASE_URL}/api/careers`
    );

    if (!response.ok) {
        throw new Error("Failed to fetch careers");
    }

    return response.json();
}

export async function getCareersByDomain(domainId) {
    const response = await fetch(
        `${API_BASE_URL}/api/careers/domain/${domainId}`
    );

    if (!response.ok) {
        throw new Error("Failed to fetch careers");
    }

    return response.json();
}

export async function getSkills() {
    const response = await fetch(
        `${API_BASE_URL}/api/skills`
    );

    if (!response.ok) {
        throw new Error("Failed to fetch skills");
    }

    return response.json();
}

export async function getSkillsByCategory(category) {
    const response = await fetch(
        `${API_BASE_URL}/api/skills/category/${encodeURIComponent(category)}`
    );

    if (!response.ok) {
        throw new Error("Failed to fetch skills by category");
    }

    return response.json();
}

export async function getCareerSkills(careerId) {
    const response = await fetch(
        `${API_BASE_URL}/api/careers/${careerId}/skills`
    );

    if (!response.ok) {
        throw new Error("Failed to fetch career skills");
    }

    return response.json();
}

export async function getCareersWithSkillsByDomain(domainId) {
    const response = await fetch(
        `${API_BASE_URL}/api/careers/domain/${domainId}/with-skills`
    );

    if (!response.ok) {
        throw new Error("Failed to fetch careers with skills");
    }

    return response.json();
}

export async function getStatistics() {
    const response = await fetch(
        `${API_BASE_URL}/api/statistics`
    );

    if (!response.ok) {
        throw new Error("Failed to fetch statistics");
    }

    return response.json();
}

export async function testDatabase() {
    const response = await fetch(
        `${API_BASE_URL}/api/database-test`
    );

    if (!response.ok) {
        throw new Error("Database test failed");
    }

    return response.json();
}

export async function debugDatabase() {
    const response = await fetch(
        `${API_BASE_URL}/api/debug-db`
    );

    if (!response.ok) {
        throw new Error("Database debug request failed");
    }

    return response.json();
}