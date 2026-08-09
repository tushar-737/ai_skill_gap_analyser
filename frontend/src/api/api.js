// =====================================================
// API BASE URL
// =====================================================

const API_BASE_URL = "http://127.0.0.1:8000";


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