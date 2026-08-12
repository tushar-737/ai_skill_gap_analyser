// =====================================================
// LOCAL STORAGE — persist the assessment between visits
// =====================================================
//
// Saves { e, d, c, l, r }:
//   e = selected education id
//   d = selected domain id
//   c = selected career id
//   l = skill levels { [skill_id]: number }
//   r = whether results were shown

const STORAGE_KEY = "skillgap:state:v1";
const RESUME_SESSION_KEY = "skillgap:resume-session:v1";

// Generate a unique browser session ID.
// Uses crypto.randomUUID when available, otherwise a fallback.
function generateUUID() {
    if (
        typeof crypto !== "undefined" &&
        typeof crypto.randomUUID === "function"
    ) {
        return crypto.randomUUID();
    }

    return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(
        /[xy]/g,
        function (c) {
            const r = (Math.random() * 16) | 0;
            const v = c === "x" ? r : (r & 0x3) | 0x8;
            return v.toString(16);
        }
    );
}

// An opaque identifier isolates one browser's upload history.
// It is not authentication; a production multi-user app still needs real accounts.
export function getResumeSession() {
    try {
        let token = localStorage.getItem(RESUME_SESSION_KEY);

        if (!token) {
            token = generateUUID();
            localStorage.setItem(RESUME_SESSION_KEY, token);
        }

        return token;
    } catch (error) {
        console.error("Failed to initialise resume session:", error);
        throw new Error(
            "Browser storage is required to manage resume history."
        );
    }
}

export function loadState() {
    try {
        const raw = localStorage.getItem(STORAGE_KEY);
        return raw ? JSON.parse(raw) : null;
    } catch (error) {
        console.error("Failed to load saved state:", error);
        return null;
    }
}

export function saveState(state) {
    try {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
    } catch (error) {
        // Private mode / storage full — silently ignore
        console.error("Failed to save state:", error);
    }
}