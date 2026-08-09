import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
    plugins: [react(), tailwindcss()],

    // Bind to 0.0.0.0 so the app is reachable from any host
    // (LAN, preview URLs, containers).
    server: {
        host: true,
        port: 5173,
        // Allow access from any host (preview tunnels, LAN IPs).
        // In production this does not matter — Vite is a dev server.
        allowedHosts: true,
        proxy: {
            // In development, the browser calls the app origin (/api/...)
            // and Vite forwards the request to the FastAPI backend.
            // This removes the hardcoded http://127.0.0.1:8000 from
            // client code and works from any host (no CORS issues).
            "/api": {
                target: "http://127.0.0.1:8000",
                changeOrigin: true,
            },
        },
    },

    preview: {
        host: true,
        port: 4173,
    },
});
