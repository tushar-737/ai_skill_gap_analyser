import { useEffect, useState } from "react";
import { getStatistics } from "../../api/api";

export default function StatsSection() {
    const [stats, setStats] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        let cancelled = false;
        async function load() {
            try {
                const data = await getStatistics();
                if (!cancelled) setStats(data);
            } catch {
                if (!cancelled) setStats(null);
            } finally {
                if (!cancelled) setLoading(false);
            }
        }
        load();
        return () => {
            cancelled = true;
        };
    }, []);

    const items = stats
        ? [
              // Exact live counts from /api/statistics — never hardcoded
              { value: `${stats.skills}`, label: "Skills", sub: "in the database" },
              { value: `${stats.careers}`, label: "Career Paths", sub: "to explore" },
              { value: `${stats.domains}`, label: "Domains", sub: "career fields" },
              { value: `${stats.education_programs}`, label: "Programs", sub: "learning paths" },
          ]
        : [
              { value: "—", label: "Skills", sub: "loading options" },
              { value: "—", label: "Career Paths", sub: "loading options" },
              { value: "—", label: "Domains", sub: "loading options" },
              { value: "—", label: "Programs", sub: "loading options" },
          ];

    return (
        <section className="stats-section" aria-label="Platform statistics">
            <div className="stats-inner">
                {items.map((it) => (
                    <div key={it.label} className="stat-item">
                        <strong>{loading ? "—" : it.value}</strong>
                        <span>{it.label}</span>
                        <small>{it.sub}</small>
                    </div>
                ))}
            </div>
        </section>
    );
}
