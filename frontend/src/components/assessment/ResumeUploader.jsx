import { useRef, useState } from "react";
import { uploadResume } from "../../api/api";

export default function ResumeUploader({ selectedCareer = "", selectedEducation = "", onExtracted = () => {} }) {
    const inputRef = useRef(null);
    const [dragOver, setDragOver] = useState(false);
    const [file, setFile] = useState(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");
    const [result, setResult] = useState(null);

    function reset() {
        setFile(null);
        setResult(null);
        setError("");
        if (inputRef.current) inputRef.current.value = "";
    }

    function pickFile(nextFile) {
        setError("");
        setResult(null);
        if (!nextFile) return;
        const ext = nextFile.name.toLowerCase().split(".").pop();
        if (!["pdf", "docx", "doc", "txt"].includes(ext)) {
            setError("Please upload a PDF or DOCX resume.");
            return;
        }
        if (nextFile.size > 5 * 1024 * 1024) {
            setError("File too large — max 5 MB.");
            return;
        }
        setFile(nextFile);
    }

    async function handleUpload() {
        if (!file) {
            setError("Choose a resume first.");
            return;
        }
        setLoading(true);
        setError("");
        setResult(null);
        try {
            const data = await uploadResume(file, {
                targetCareerId: selectedCareer || undefined,
                education: selectedEducation || undefined,
            });
            setResult(data);
            onExtracted(data);
        } catch (err) {
            setError(err.message || "Upload failed. Try again.");
        } finally {
            setLoading(false);
        }
    }

    return (
        <section className="assessment-step resume-uploader">
            <div className="journey-header">
                <div className="journey-icon" aria-hidden>
                    📄
                </div>
                <div>
                    <span className="journey-kicker">Step 4 — Resume (Optional)</span>
                    <h2>Have a resume?</h2>
                    <p>Upload it and we&apos;ll use your existing skills to help build your profile. You can still edit the sliders after.</p>
                </div>
                <span className="journey-step-badge">4a</span>
            </div>

            {!file && !result && (
                <div
                    className={`resume-dropzone-v2 ${dragOver ? "drag-over" : ""}`}
                    onDragOver={(e) => {
                        e.preventDefault();
                        setDragOver(true);
                    }}
                    onDragLeave={() => setDragOver(false)}
                    onDrop={(e) => {
                        e.preventDefault();
                        setDragOver(false);
                        const f = e.dataTransfer.files?.[0];
                        if (f) pickFile(f);
                    }}
                >
                    <div className="resume-dropzone-icon" style={{ width: 56, height: 56, fontSize: 24 }}>
                        📄
                    </div>
                    <strong>Drop your resume here</strong>
                    <small>PDF or DOCX • Optional • Max 5 MB • Saved to Workbench</small>
                    <button type="button" className="secondary-button" onClick={() => inputRef.current?.click()} style={{ marginTop: 8 }}>
                        Choose File
                    </button>
                    <input
                        ref={inputRef}
                        type="file"
                        accept=".pdf,.docx,.doc,.txt"
                        style={{ display: "none" }}
                        onChange={(e) => pickFile(e.target.files?.[0])}
                    />
                </div>
            )}

            {file && !result && (
                <div className="resume-pending">
                    <div className="resume-pending-file">
                        <span className="resume-file-icon">📄</span>
                        <div>
                            <strong>{file.name}</strong>
                            <small>
                                {(file.size / 1024).toFixed(1)} KB • {file.type || "PDF/DOCX"}
                            </small>
                        </div>
                        <span className="resume-pending-badge">Ready to parse</span>
                    </div>
                    <div className="resume-actions" style={{ justifyContent: "center" }}>
                        <button type="button" className="analyze-button" onClick={handleUpload} disabled={loading} style={{ maxWidth: 220 }}>
                            {loading ? "⏳ Analyzing with AI..." : "🤖 Parse Resume with AI"}
                        </button>
                        <button type="button" className="secondary-button" onClick={reset} disabled={loading}>
                            Remove
                        </button>
                    </div>
                    <div className="resume-flow" aria-hidden>
                        <span>Upload</span> <span>→</span> <span>Extract text</span> <span>→</span> <span>Detect skills</span> <span>→</span> <span>Compare</span> <span>→</span> <span>Generate profile</span> <span>→</span> <span>Calculate gaps</span>
                    </div>
                </div>
            )}

            {file && result && (
                <div className="resume-uploaded-bar">
                    <span>✓ Resume uploaded</span>
                    <strong>{file.name}</strong>
                    <div style={{ marginLeft: "auto", display: "flex", gap: 8 }}>
                        <button type="button" className="secondary-button" onClick={() => inputRef.current?.click()} style={{ padding: "6px 12px", fontSize: 12 }}>
                            Change
                        </button>
                        <button type="button" className="secondary-button" onClick={reset} style={{ padding: "6px 12px", fontSize: 12 }}>
                            Remove
                        </button>
                    </div>
                    <input
                        ref={inputRef}
                        type="file"
                        accept=".pdf,.docx,.doc,.txt"
                        style={{ display: "none" }}
                        onChange={(e) => pickFile(e.target.files?.[0])}
                    />
                </div>
            )}

            {loading && <p className="skill-loading">Extracting text → Detecting skills → Comparing with career requirements... (AI Groq/Gemini, else Keyword)</p>}

            {error && <div className="error-message" role="alert">{error}</div>}

            {result && (
                <div className="resume-result">
                    <div className="resume-result-header">
                        <h3>
                            {result.gemini_used || result.ai_used ? "✨ AI Extracted" : "🔍 Keyword Extracted"} — {result.extracted_skills?.length || 0} skills
                        </h3>
                        <span className={`resume-badge ${result.gemini_used || result.ai_used ? "ai" : "kw"}`}>
                            {result.extraction_source === "groq" ? "Groq" : result.extraction_source === "gemini" ? "Gemini" : "Keyword"}
                        </span>
                    </div>

                    {result.extraction_source === "keyword" && result.gemini_attempted && result.fallback_reason === "quota" && (
                        <div className="error-message" style={{ background: "#fffbeb", borderColor: "#fde68a", color: "#92400e" }}>
                            ⚠️ AI quota hit (429) — using Keyword fallback. Wait ~60s, or add <code>GROQ_API_KEY</code> in <code>backend/.env</code> for higher free quota. Your upload was still saved.
                        </div>
                    )}
                    {result.extraction_source === "keyword" && result.gemini_attempted && result.fallback_reason === "invalid_key" && (
                        <div className="error-message">⚠️ AI key invalid — check <code>GROQ_API_KEY</code> or <code>GEMINI_API_KEY</code> in <code>backend/.env</code> and restart.</div>
                    )}
                    {!result.gemini_attempted && result.extraction_source === "keyword" && (
                        <div className="error-message" style={{ background: "#f0fdf4", borderColor: "#bbf7d0", color: "#166534" }}>
                            ℹ️ Keyword mode — add <code>GROQ_API_KEY</code> or <code>GEMINI_API_KEY</code> to <code>backend/.env</code> for AI levels.
                        </div>
                    )}

                    {result.summary && <p className="resume-summary">{result.summary}</p>}

                    {result.gap_preview && (
                        <p className="resume-gap-preview">
                            Target <strong>{result.gap_preview.career_name}</strong>: <strong>{result.gap_preview.match_percentage}%</strong> match (preview)
                        </p>
                    )}

                    {result.extracted_skills?.length > 0 ? (
                        <div className="resume-skills">
                            {result.extracted_skills.slice(0, 12).map((s) => (
                                <span key={s.skill_id || s.name} className="resume-skill-chip" title={s.evidence || ""}>
                                    {s.name} <em>{s.inferred_level}%</em>
                                </span>
                            ))}
                        </div>
                    ) : (
                        <p className="empty-message">No known skills matched. Try a text-based PDF (not scanned).</p>
                    )}

                    <p style={{ fontSize: 12, color: "#64748b", marginTop: 8 }}>
                        The system extracted skills from your resume, compared them with career requirements, generated your profile and calculated gaps — you can now <strong>correct any slider</strong> before analyzing.
                    </p>

                    <details className="resume-details">
                        <summary>Show raw preview ({result.text_length} chars)</summary>
                        <pre className="resume-preview">{result.text_preview}</pre>
                    </details>

                    <p className="resume-workbench-hint">
                        {result.saved_id ? `✓ Saved to Workbench: resume_analyses #${result.saved_id}` : `ℹ️ ${result.workbench_hint}`}
                    </p>
                </div>
            )}
        </section>
    );
}
