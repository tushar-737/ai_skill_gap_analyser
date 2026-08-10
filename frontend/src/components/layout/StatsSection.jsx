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
              { value: `${stats.skills}+`, label: "Skills", sub: "in database" },
              { value: `${stats.careers}+`, label: "Career Paths", sub: "v2 profiles" },
              { value: `${stats.domains}+`, label: "Domains", sub: "fields" },
              { value: `${stats.education_programs}+`, label: "Programs", sub: "education" },
          ]
        : [
              { value: "50+", label: "Skills", sub: "curated" },
              { value: "10+", label: "Career Paths", sub: "ready" },
              { value: "5+", label: "Domains", sub: "fields" },
              { value: "20+", label: "Profiles", sub: "analyzed" },
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
