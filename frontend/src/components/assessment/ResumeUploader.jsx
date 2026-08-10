import { useRef, useState } from "react";
import { uploadResume } from "../../api/api";

export default function ResumeUploader({
    selectedCareer = "",
    selectedEducation = "",
    onExtracted = () => {},
}) {
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
            setError("Please upload a PDF, DOCX or TXT resume.");
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
            <div className="step-header">
                <span className="step-number">★</span>
                <div>
                    <h2>Upload Resume (Optional)</h2>
                    <p>
                        Upload a PDF/DOCX resume — we’ll extract your skills with AI (Gemini
                        passkey on backend) and auto-fill the sliders. You can still edit
                        them before analyzing.
                    </p>
                </div>
            </div>

            {/* Dropzone */}
            <div
                className={`resume-dropzone ${dragOver ? "drag-over" : ""} ${file ? "has-file" : ""}`}
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
                onClick={() => inputRef.current?.click()}
                role="button"
                tabIndex={0}
                onKeyDown={(e) => {
                    if (e.key === "Enter" || e.key === " ") inputRef.current?.click();
                }}
                aria-label="Upload resume - drag and drop or click to browse"
            >
                <div className="resume-dropzone-icon">📄</div>
                <div>
                    <strong>
                        {file ? file.name : "Drag & drop resume here or click to browse"}
                    </strong>
                    <small>
                        {file
                            ? `${(file.size / 1024).toFixed(1)} KB • ${file.type || "PDF/DOCX/TXT"}`
                            : "PDF, DOCX, TXT • Max 5 MB • Works with MySQL Workbench storage"}
                    </small>
                </div>
                <input
                    ref={inputRef}
                    type="file"
                    accept=".pdf,.docx,.doc,.txt"
                    style={{ display: "none" }}
                    onChange={(e) => pickFile(e.target.files?.[0])}
                />
            </div>

            {file && (
                <div className="resume-actions">
                    <button
                        type="button"
                        className="analyze-button"
                        onClick={handleUpload}
                        disabled={loading}
                    >
                        {loading ? "⏳ Analyzing with AI..." : "🤖 Parse Resume with AI"}
                    </button>
                    <button type="button" className="secondary-button" onClick={reset} disabled={loading}>
                        Clear
                    </button>
                </div>
            )}

            {loading && (
                <p className="skill-loading">
                    Extracting skills — using Gemini passkey if configured, otherwise keyword fallback...
                </p>
            )}

            {error && <div className="error-message" role="alert">{error}</div>}

            {result && (
                <div className="resume-result">
                    <div className="resume-result-header">
                        <h3>
                            {result.gemini_used ? "✨ AI Extracted" : "🔍 Keyword Extracted"} —{" "}
                            {result.extracted_skills?.length || 0} skills
                        </h3>
                        <span className={`resume-badge ${result.gemini_used ? "ai" : "kw"}`}>
                            {result.extraction_source === "gemini" ? "Gemini" : "Keyword"}
                        </span>
                    </div>

                    {/* Quota / fallback banner */}
                    {result.extraction_source === "keyword" && result.gemini_attempted && result.fallback_reason === "quota" && (
                        <div className="error-message" style={{ background: "#fffbeb", borderColor: "#fde68a", color: "#92400e" }}>
                            ⚠️ Gemini quota hit (429) — using Keyword fallback. Wait ~60s or switch <code>GET /api/resume/analyze</code> model in <code>backend/.env</code> to <code>gemini-1.5-flash</code>. Your upload was still saved to Workbench.
                        </div>
                    )}
                    {result.extraction_source === "keyword" && result.gemini_attempted && result.fallback_reason === "invalid_key" && (
                        <div className="error-message">
                            ⚠️ Gemini key invalid — check <code>GEMINI_API_KEY</code> in <code>backend/.env</code> (should be <code>AQ...</code> from AI Studio) and restart backend.
                        </div>
                    )}
                    {result.extraction_source === "keyword" && result.gemini_attempted && result.fallback_reason === "error" && result.gemini_error && (
                        <div className="error-message">
                            ℹ️ Gemini fallback: {String(result.gemini_error).slice(0, 120)}
                        </div>
                    )}
                    {!result.gemini_attempted && result.extraction_source === "keyword" && (
                        <div className="error-message" style={{ background: "#f0fdf4", borderColor: "#bbf7d0", color: "#166534" }}>
                            ℹ️ Running in offline Keyword mode (no GEMINI_API_KEY). Add it to <code>backend/.env</code> for AI levels.
                        </div>
                    )}

                    {result.summary && <p className="resume-summary">{result.summary}</p>}

                    {result.gap_preview && (
                        <p className="resume-gap-preview">
                            Target <strong>{result.gap_preview.career_name}</strong>:{" "}
                            <strong>{result.gap_preview.match_percentage}%</strong> match (preview)
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
                        <p className="empty-message">
                            No known skills matched. Try a text-based PDF (not scanned) — or add skills to your Workbench `skills_v2` table.
                        </p>
                    )}

                    <details className="resume-details">
                        <summary>Show raw preview ({result.text_length} chars)</summary>
                        <pre className="resume-preview">{result.text_preview}</pre>
                    </details>

                    <p className="resume-workbench-hint">
                        {result.saved_id
                            ? `✓ Saved to Workbench: resume_analyses #${result.saved_id}`
                            : `ℹ️ ${result.workbench_hint}`}
                    </p>
                </div>
            )}
        </section>
    );
}
