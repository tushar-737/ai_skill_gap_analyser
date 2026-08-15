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

// =====================================================
// RESUME SESSION ID
// =====================================================
//
// Generates a unique browser session ID.
//
// Uses crypto.randomUUID() when available.
// Falls back to a UUID v4-style generator when it is not.
//
// This identifier is only used to isolate resume history
// for this browser. It is NOT authentication.
// A production multi-user application should use real
// authentication/accounts.
//

function generateUUID() {
    if (
        typeof crypto !== "undefined" &&
        typeof crypto.randomUUID === "function"
    ) {
        return crypto.randomUUID();
    }

    // UUID v4 fallback
    const bytes = new Uint8Array(16);

    if (
        typeof crypto !== "undefined" &&
        typeof crypto.getRandomValues === "function"
    ) {
        crypto.getRandomValues(bytes);
    } else {
        for (let i = 0; i < 16; i++) {
            bytes[i] = Math.floor(Math.random() * 256);
        }
    }

    // UUID v4
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    return [
        [...bytes.slice(0, 4)],
        [...bytes.slice(4, 6)],
        [...bytes.slice(6, 8)],
        [...bytes.slice(8, 10)],
        [...bytes.slice(10, 16)],
    ]
        .map((group) =>
            group
                .map((byte) => byte.toString(16).padStart(2, "0"))
                .join("")
        )
        .join("-");
}


// =====================================================
// GET RESUME SESSION
// =====================================================
//
// Returns the browser's persistent resume-session ID.
//
// The same ID is reused between visits because it is stored
// in localStorage.
//

export function getResumeSession() {
    try {
        let token = localStorage.getItem(RESUME_SESSION_KEY);

        if (!token) {
            token = generateUUID();

            localStorage.setItem(
                RESUME_SESSION_KEY,
                token
            );
        }

        return token;
    } catch (error) {
        console.error(
            "Failed to initialise resume session:",
            error
        );

        throw new Error(
            "Browser storage is required to manage resume history."
        );
    }
}


// =====================================================
// LOAD SAVED ASSESSMENT STATE
// =====================================================

export function loadState() {
    try {
        const raw = localStorage.getItem(STORAGE_KEY);

        return raw ? JSON.parse(raw) : null;
    } catch (error) {
        console.error(
            "Failed to load saved state:",
            error
        );

        return null;
    }
}


// =====================================================
// SAVE ASSESSMENT STATE
// =====================================================

export function saveState(state) {
    try {
        localStorage.setItem(
            STORAGE_KEY,
            JSON.stringify(state)
        );
    } catch (error) {
        // Private mode / storage full — silently ignore
        console.error(
            "Failed to save state:",
            error
        );
    }
}