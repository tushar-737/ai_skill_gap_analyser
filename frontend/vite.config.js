import { defineConfig, loadEnv } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig(({ mode }) => {
    // This is deliberately separate from VITE_API_URL: the former is used by
    // Vite's server-to-server proxy, while the latter is browser-visible.
    const env = loadEnv(mode, process.cwd(), "");
    const proxyTarget = env.VITE_PROXY_TARGET || "http://127.0.0.1:8000";

    return {
        plugins: [react(), tailwindcss()],

        server: {
            host: true,
            port: 5173,
            allowedHosts: true,
            proxy: {
                "/api": {
                    target: proxyTarget,
                    changeOrigin: true,
                },
            },
        },

        preview: {
            host: true,
            port: 4173,
        },
    };
});
