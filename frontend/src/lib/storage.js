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
