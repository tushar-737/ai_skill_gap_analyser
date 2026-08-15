import { useEffect, useState } from "react";
import { getResumeHistory, deleteResumeHistoryItem } from "../../api/api";

export default function ResumeHistory({ onReload = () => {}, refreshKey = 0 }) {
    const [rows, setRows] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [expanded, setExpanded] = useState(false);
    const [collapsed, setCollapsed] = useState(false);
    const [clearing, setClearing] = useState(false);

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
            <div className="assessment-step" style={{ padding: "18px 20px" }}>
                <h3 style={{ marginBottom: 4, fontSize: 15 }}>📂 My Uploads</h3>
                <p className="empty-message" style={{ color: "#64748b", fontSize: 13 }}>
                    No resumes yet. Upload one above — it will be saved to Workbench <code>resume_analyses</code> and appear here.
                </p>
            </div>
        );

    const visible = expanded ? rows : rows.slice(0, 3);

    return (
        <section className="assessment-step" style={{ padding: "18px 20px" }}>
            <div className="step-header" style={{ justifyContent: "space-between", marginBottom: 8 }}>
                <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
                    <span className="step-number" style={{ width: 32, height: 32, fontSize: 13 }}>
                        🗂️
                    </span>
                    <div>
                        <h2 style={{ fontSize: 16, marginBottom: 2 }}>My Uploads — Workbench</h2>
                        <p style={{ fontSize: 12, margin: 0 }}>
                            {rows.length} saved {rows.length === 1 ? "resume" : "resumes"} •{" "}
                            <button
                                type="button"
                                onClick={() => setCollapsed((v) => !v)}
                                style={{ background: "none", border: "none", color: "#ea580c", fontWeight: 700, cursor: "pointer", padding: 0, fontSize: 12 }}
                            >
                                {collapsed ? "Expand" : "Collapse"}
                            </button>
                        </p>
                    </div>
                </div>
                <div style={{ display: "flex", gap: 6 }}>
                    <button type="button" className="secondary-button" onClick={load} style={{ padding: "6px 12px", fontSize: 13 }} title="Refresh" aria-label="Refresh resume history">
                        ↻
                    </button>
                </div>
            </div>

            {!collapsed && (
                <>
                    <div className="resume-history-list compact">
                        {visible.map((r) => {
                            const skills = r.extracted_skills?.skills || [];
                            const isAi = r.extraction_source === "groq" || r.extraction_source === "gemini";
                            return (
                                <div key={r.id} className="resume-history-item compact">
                                    <div className="resume-history-main">
                                        <strong title={r.file_name} style={{ fontSize: 13 }}>
                                            #{r.id} — {r.file_name.length > 28 ? r.file_name.slice(0, 28) + "…" : r.file_name}
                                        </strong>
                                        <small style={{ fontSize: 11 }}>
                                            {new Date(r.created_at).toLocaleDateString()} • {isAi ? "AI" : "KW"} • {skills.length} skills
                                            <span className={`resume-badge ${isAi ? "ai" : "kw"}`} style={{ fontSize: 9, marginLeft: 6, padding: "2px 6px" }}>
                                                {r.extraction_source === "groq" ? "Groq" : r.extraction_source === "gemini" ? "Gemini" : "Keyword"}
                                            </span>
                                        </small>
                                        <div className="resume-skills" style={{ marginTop: 4, gap: 4 }}>
                                            {skills.slice(0, 3).map((s) => (
                                                <span key={s.skill_id || s.name} className="resume-skill-chip" style={{ fontSize: 11, padding: "3px 8px" }} title={s.evidence || ""}>
                                                    {s.name} <em>{s.inferred_level}%</em>
                                                </span>
                                            ))}
                                            {skills.length > 3 && <small style={{ color: "#64748b", fontSize: 11 }}>+{skills.length - 3}</small>}
                                        </div>
                                    </div>
                                    <div style={{ display: "flex", gap: 6 }}>
                                        <button type="button" className="secondary-button" onClick={() => onReload(r)} style={{ padding: "6px 10px", fontSize: 12, whiteSpace: "nowrap" }}>
                                            ↩
                                        </button>
                                        <button
                                            type="button"
                                            className="secondary-button"
                                            disabled={clearing}
                                            onClick={async () => {
                                                if (!window.confirm(`Delete ${r.file_name} from your upload history?`)) return;
                                                setClearing(true);
                                                try {
                                                    await deleteResumeHistoryItem(r.id);
                                                    await load();
                                                } catch (e) {
                                                    setError(e.message || "Could not delete this upload.");
                                                } finally {
                                                    setClearing(false);
                                                }
                                            }}
                                            style={{ padding: "6px 10px", fontSize: 12, color: "#b91c1c", borderColor: "#fecaca" }}
                                            title="Delete this upload"
                                        >
                                            🗑
                                        </button>
                                    </div>
                                </div>
                            );
                        })}
                    </div>

                    {rows.length > 3 && (
                        <button
                            type="button"
                            onClick={() => setExpanded((v) => !v)}
                            className="secondary-button"
                            style={{ marginTop: 10, width: "100%", padding: "8px", fontSize: 13 }}
                        >
                            {expanded ? `Show less` : `Show all ${rows.length} →`}
                        </button>
                    )}

                    <p className="resume-workbench-hint" style={{ marginTop: 8, fontSize: 11 }}>
                        Workbench: <code>SELECT * FROM resume_analyses LIMIT 5;</code>
                    </p>
                </>
            )}
        </section>
    );
}
