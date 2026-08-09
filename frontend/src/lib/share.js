// =====================================================
// SHAREABLE RESULT LINKS
// =====================================================
//
// The assessment state is encoded into the URL hash, e.g.
//   https://site/#/share/eyJlIjoiMSIsImQiOiIyIi...
// Opening such a link restores the selections, skill
// levels, and (once data loads) shows the results.

// =====================================================
// ENCODE / DECODE (base64url of JSON)
// =====================================================

export function encodeShareState(state) {
    const json = JSON.stringify(state);
    const bytes = new TextEncoder().encode(json);
    let binary = "";

    bytes.forEach((byte) => {
        binary += String.fromCharCode(byte);
    });

    return btoa(binary)
        .replace(/\+/g, "-")
        .replace(/\//g, "_")
        .replace(/=+$/, "");
}

export function decodeShareState(hash) {
    try {
        const raw = hash.replace(/^#\/share\//, "");

        if (!raw) return null;

        let base64 = raw.replace(/-/g, "+").replace(/_/g, "/");

        while (base64.length % 4 !== 0) {
            base64 += "=";
        }

        const binary = atob(base64);
        const bytes = Uint8Array.from(
            binary,
            (char) => char.charCodeAt(0)
        );

        const state = JSON.parse(
            new TextDecoder().decode(bytes)
        );

        if (!state || typeof state !== "object") {
            return null;
        }

        return state;
    } catch (error) {
        console.error("Failed to decode share link:", error);
        return null;
    }
}

// =====================================================
// COPY TEXT TO CLIPBOARD
// =====================================================
//
// Uses the async Clipboard API when available, with a
// textarea fallback for older/insecure contexts.

export async function copyText(text) {
    try {
        await navigator.clipboard.writeText(text);
        return true;
    } catch (error) {
        try {
            const textarea = document.createElement("textarea");
            textarea.value = text;
            textarea.style.position = "fixed";
            textarea.style.opacity = "0";
            document.body.appendChild(textarea);
            textarea.select();
            const ok = document.execCommand("copy");
            textarea.remove();
            return ok;
        } catch {
            console.error("Clipboard copy failed:", error);
            return false;
        }
    }
}
