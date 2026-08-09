// =====================================================
// API BASE URL
// =====================================================
//
// By default the app calls relative /api/... URLs. In development
// Vite proxies /api to the FastAPI backend (see vite.config.js),
// so the app works from any host without hardcoded localhost or CORS.
//
// For a deployment where the API lives elsewhere, set VITE_API_URL,
// e.g. VITE_API_URL=https://api.example.com npm run build

const API_BASE_URL = import.meta.env.VITE_API_URL || "";


// =====================================================
// GENERIC API REQUEST
// =====================================================

async function apiRequest(endpoint) {

    try {

        const response = await fetch(
            `${API_BASE_URL}${endpoint}`
        );

        if (!response.ok) {

            throw new Error(
                `API Error: ${response.status} ${response.statusText}`
            );

        }

        return await response.json();

    } catch (error) {

        console.error(
            `API Request Failed: ${endpoint}`,
            error
        );

        throw error;
    }
}


// =====================================================
// EDUCATION CATEGORIES
// =====================================================

export async function getEducationCategories() {

    return apiRequest(
        "/api/education-categories"
    );

}


// =====================================================
// EDUCATION PROGRAMS
// =====================================================

export async function getEducationPrograms() {

    return apiRequest(
        "/api/education-programs"
    );

}


// =====================================================
// DOMAINS
// =====================================================

export async function getDomains() {

    return apiRequest(
        "/api/domains"
    );

}


// =====================================================
// CAREERS
// =====================================================

export async function getCareers() {

    return apiRequest(
        "/api/careers"
    );

}


// =====================================================
// CAREERS BY DOMAIN
// =====================================================

export async function getCareersByDomain(domainId) {

    return apiRequest(
        `/api/careers/domain/${domainId}`
    );

}


// =====================================================
// ALL SKILLS
// =====================================================

export async function getSkills() {

    return apiRequest(
        "/api/skills"
    );

}


// =====================================================
// SKILLS BY CATEGORY
// =====================================================

export async function getSkillsByCategory(category) {

    return apiRequest(
        `/api/skills/category/${encodeURIComponent(category)}`
    );

}


// =====================================================
// CAREER REQUIRED SKILLS
// =====================================================

export async function getCareerSkills(careerId) {

    return apiRequest(
        `/api/careers/${careerId}/skills`
    );

}


// =====================================================
// CAREERS WITH SKILLS BY DOMAIN
// =====================================================

export async function getCareersWithSkillsByDomain(domainId) {

    return apiRequest(
        `/api/careers/domain/${domainId}/with-skills`
    );

}


// =====================================================
// DATABASE STATISTICS
// =====================================================

export async function getStatistics() {

    return apiRequest(
        "/api/statistics"
    );

}