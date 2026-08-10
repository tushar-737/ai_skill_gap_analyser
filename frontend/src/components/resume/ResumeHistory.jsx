import { useEffect, useState } from "react";
import { getResumeHistory } from "../../api/api";

export default function ResumeHistory({ onReload = () => {}, refreshKey = 0 }) {
    const [rows, setRows] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");

    async function load() {
        setLoading(true);
        setError("");
        try {
            const data = await getResumeHistory(10);
            setRows(Array.isArray(data) ? data : []);
        } catch (e) {
            setError(e.message || "Could not load history. Run backend/workbench/init.sql in Workbench.");
        } finally {
            setLoading(false);
        }
    }

    useEffect(() => {
        load();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [refreshKey]);

    if (loading) return <p className="skill-loading">Loading resume history...</p>;
    if (error) return <div className="error-message">{error}</div>;
    if (rows.length === 0)
        return (
            <div className="assessment-step">
                <h3 style={{ marginBottom: 6 }}>📂 My Uploads</h3>
                <p className="empty-message" style={{ color: "#64748b" }}>
                    No resumes yet. Upload one above — it will be saved to Workbench <code>resume_analyses</code> and appear here.
                </p>
            </div>
        );

    return (
        <section className="assessment-step">
            <div className="step-header" style={{ justifyContent: "space-between" }}>
                <div style={{ display: "flex", gap: 12, alignItems: "center" }}>
                    <span className="step-number">🗂️</span>
                    <div>
                        <h2>My Uploads — Workbench History</h2>
                        <p>Last {rows.length} resumes from MySQL Workbench (`resume_analyses`). Click to reload.</p>
                    </div>
                </div>
                <button type="button" className="secondary-button" onClick={load} style={{ padding: "8px 14px" }}>
                    ↻ Refresh
                </button>
            </div>

            <div className="resume-history-list">
                {rows.map((r) => {
                    const skills = r.extracted_skills?.skills || [];
                    const isAi = r.extraction_source === "groq" || r.extraction_source === "gemini";
                    return (
                        <div key={r.id} className="resume-history-item">
                            <div className="resume-history-main">
                                <strong title={r.file_name}>
                                    #{r.id} — {r.file_name}
                                </strong>
                                <small>
                                    {new Date(r.created_at).toLocaleString()} • {r.file_size ? `${(r.file_size / 1024).toFixed(1)} KB` : ""} •{" "}
                                    <span className={`resume-badge ${isAi ? "ai" : "kw"}`} style={{ fontSize: 10 }}>
                                        {r.extraction_source === "groq" ? "Groq" : r.extraction_source === "gemini" ? "Gemini" : "Keyword"}
                                    </span>
                                </small>
                                <div className="resume-skills" style={{ marginTop: 6 }}>
                                    {skills.slice(0, 6).map((s) => (
                                        <span key={s.skill_id || s.name} className="resume-skill-chip" title={s.evidence || ""}>
                                            {s.name} <em>{s.inferred_level}%</em>
                                        </span>
                                    ))}
                                    {skills.length > 6 && <small style={{ color: "#64748b" }}>+{skills.length - 6} more</small>}
                                </div>
                            </div>
                            <button
                                type="button"
                                className="secondary-button"
                                onClick={() => onReload(r)}
                                style={{ padding: "8px 14px", whiteSpace: "nowrap" }}
                            >
                                ↩ Reload
                            </button>
                        </div>
                    );
                })}
            </div>

            <p className="resume-workbench-hint" style={{ marginTop: 12 }}>
                Workbench: <code>SELECT * FROM resume_analyses ORDER BY created_at DESC LIMIT 5;</code>
            </p>
        </section>
    );
}
