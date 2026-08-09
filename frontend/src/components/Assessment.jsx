import { useState } from "react";
import axios from "axios";
import {
  Brain,
  ChevronDown,
  Plus,
  Trash2,
  Upload,
  Target,
  TrendingUp,
  AlertTriangle,
  CheckCircle2,
  Loader2,
} from "lucide-react";

const availableSkills = [
  "Python",
  "Java",
  "JavaScript",
  "React",
  "HTML",
  "CSS",
  "Tailwind CSS",
  "SQL",
  "Pandas",
  "NumPy",
  "Machine Learning",
  "Statistics",
  "Deep Learning",
  "Power BI",
  "Excel",
  "Git",
  "APIs",
  "Django",
  "FastAPI",
];

const careers = [
  "Data Scientist",
  "Data Analyst",
  "React Developer",
  "Python Developer",
];

function Assessment() {
  const [name, setName] = useState("");
  const [career, setCareer] = useState("Data Scientist");

  const [skills, setSkills] = useState([]);

  const [selectedSkill, setSelectedSkill] = useState("Python");
  const [level, setLevel] = useState(70);

  const [resume, setResume] = useState(null);

  const [result, setResult] = useState(null);

  const [loading, setLoading] = useState(false);

  const [error, setError] = useState("");

  // ==========================================
  // ADD SKILL
  // ==========================================

  const addSkill = () => {
    setError("");

    const alreadyExists = skills.some(
      (skill) => skill.name === selectedSkill
    );

    if (alreadyExists) {
      setError(`${selectedSkill} has already been added.`);
      return;
    }

    const newSkill = {
      name: selectedSkill,
      level: Number(level),
    };

    setSkills((previousSkills) => [
      ...previousSkills,
      newSkill,
    ]);
  };

  // ==========================================
  // REMOVE SKILL
  // ==========================================

  const removeSkill = (skillName) => {
    setSkills((previousSkills) =>
      previousSkills.filter(
        (skill) => skill.name !== skillName
      )
    );
  };

  // ==========================================
  // ANALYZE SKILLS
  // ==========================================

  const analyzeSkills = async () => {
    setError("");
    setResult(null);

    if (!name.trim()) {
      setError("Please enter your name.");
      return;
    }

    if (skills.length === 0) {
      setError("Please add at least one skill.");
      return;
    }

    setLoading(true);

    try {
      const response = await axios.post(
        "http://127.0.0.1:8000/api/analyze",
        {
          name: name.trim(),
          career: career,
          skills: skills,
        }
      );

      if (response.data.success) {
        setResult({
          matchScore: response.data.matchScore,
          analysis: response.data.analysis,
          gaps: response.data.gaps,
          name: response.data.name,
          career: response.data.career,
        });
      } else {
        setError(
          response.data.message ||
            "Analysis could not be completed."
        );
      }
    } catch (error) {
      console.error("Analysis error:", error);

      if (error.response) {
        setError(
          error.response.data?.detail ||
            "The backend returned an error."
        );
      } else if (error.request) {
        setError(
          "Cannot connect to the backend. Make sure FastAPI is running on http://127.0.0.1:8000."
        );
      } else {
        setError(
          "Something went wrong while analyzing your skills."
        );
      }
    } finally {
      setLoading(false);
    }
  };

  // ==========================================
  // SCORE LABEL
  // ==========================================

  const getScoreLabel = (score) => {
    if (score >= 85) {
      return "Excellent Match";
    }

    if (score >= 70) {
      return "Strong Match";
    }

    if (score >= 50) {
      return "Good Starting Point";
    }

    return "Needs Improvement";
  };

  return (
    <div className="min-h-screen bg-slate-950 px-4 py-28 text-white sm:px-6">

      <div className="mx-auto max-w-6xl">

        {/* ==========================================
            HEADER
        ========================================== */}

        <div className="mb-10 text-center">

          <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-2xl border border-cyan-400/20 bg-cyan-400/10 text-cyan-400 shadow-lg shadow-cyan-950/30">
            <Brain size={32} />
          </div>

          <p className="mt-6 text-sm font-semibold uppercase tracking-[0.25em] text-cyan-400">
            AI Career Intelligence
          </p>

          <h1 className="mt-3 text-4xl font-black tracking-tight sm:text-5xl">
            Skill Assessment
          </h1>

          <p className="mx-auto mt-4 max-w-2xl text-base leading-7 text-slate-400">
            Analyze your current skills, compare them with
            your target career requirements, and discover
            exactly where you need to improve.
          </p>

        </div>


        {/* ==========================================
            ERROR MESSAGE
        ========================================== */}

        {error && (
          <div className="mx-auto mb-6 flex max-w-5xl items-start gap-3 rounded-2xl border border-red-400/20 bg-red-400/10 p-4 text-red-300">

            <AlertTriangle
              size={20}
              className="mt-0.5 shrink-0"
            />

            <p className="text-sm leading-6">
              {error}
            </p>

          </div>
        )}


        {/* ==========================================
            FORM
        ========================================== */}

        <div className="rounded-3xl border border-white/10 bg-white/[0.03] p-5 shadow-2xl shadow-black/20 backdrop-blur-xl sm:p-8 lg:p-10">

          {/* BASIC INFORMATION */}

          <div>

            <div className="mb-6">
              <h2 className="text-2xl font-bold">
                Basic Information
              </h2>

              <p className="mt-1 text-sm text-slate-500">
                Tell us about yourself and your career goal.
              </p>
            </div>


            <div className="grid gap-6 md:grid-cols-2">

              {/* NAME */}

              <div>

                <label className="mb-2 block text-sm font-medium text-slate-300">
                  Your Name
                </label>

                <input
                  type="text"
                  value={name}
                  onChange={(event) =>
                    setName(event.target.value)
                  }
                  placeholder="Enter your name"
                  className="w-full rounded-xl border border-white/10 bg-slate-900 px-4 py-3.5 text-white outline-none transition placeholder:text-slate-600 focus:border-cyan-400/60 focus:ring-2 focus:ring-cyan-400/10"
                />

              </div>


              {/* CAREER */}

              <div>

                <label className="mb-2 block text-sm font-medium text-slate-300">
                  Target Career
                </label>

                <div className="relative">

                  <select
                    value={career}
                    onChange={(event) =>
                      setCareer(event.target.value)
                    }
                    className="w-full appearance-none rounded-xl border border-white/10 bg-slate-900 px-4 py-3.5 text-white outline-none transition focus:border-cyan-400/60"
                  >

                    {careers.map((careerName) => (
                      <option
                        key={careerName}
                        value={careerName}
                      >
                        {careerName}
                      </option>
                    ))}

                  </select>

                  <ChevronDown
                    size={20}
                    className="pointer-events-none absolute right-4 top-3.5 text-slate-500"
                  />

                </div>

              </div>

            </div>

          </div>


          {/* ==========================================
              RESUME
          ========================================== */}

          <div className="mt-10 border-t border-white/5 pt-10">

            <div className="mb-6">

              <h2 className="text-2xl font-bold">
                Resume
              </h2>

              <p className="mt-1 text-sm text-slate-500">
                Upload your resume for future AI-powered
                skill extraction.
              </p>

            </div>


            <label className="flex cursor-pointer flex-col items-center justify-center rounded-2xl border border-dashed border-cyan-400/30 bg-cyan-400/[0.03] px-6 py-10 text-center transition hover:border-cyan-400/60 hover:bg-cyan-400/[0.06]">

              <div className="flex h-14 w-14 items-center justify-center rounded-xl bg-cyan-400/10 text-cyan-400">
                <Upload size={26} />
              </div>

              <p className="mt-4 font-semibold">
                {resume
                  ? resume.name
                  : "Upload your resume"}
              </p>

              <p className="mt-2 text-sm text-slate-500">
                PDF files recommended
              </p>

              <input
                type="file"
                accept=".pdf"
                className="hidden"
                onChange={(event) => {
                  const file =
                    event.target.files?.[0] || null;

                  setResume(file);
                }}
              />

            </label>

          </div>


          {/* ==========================================
              SKILLS
          ========================================== */}

          <div className="mt-10 border-t border-white/5 pt-10">

            <div className="mb-6">

              <h2 className="text-2xl font-bold">
                Your Skills
              </h2>

              <p className="mt-1 text-sm text-slate-500">
                Select your skills and rate your proficiency
                from 0 to 100.
              </p>

            </div>


            <div className="grid gap-4 lg:grid-cols-3">

              {/* SKILL */}

              <div className="relative">

                <label className="mb-2 block text-sm text-slate-400">
                  Skill
                </label>

                <select
                  value={selectedSkill}
                  onChange={(event) =>
                    setSelectedSkill(event.target.value)
                  }
                  className="w-full appearance-none rounded-xl border border-white/10 bg-slate-900 px-4 py-3.5 text-white outline-none focus:border-cyan-400/60"
                >

                  {availableSkills.map((skill) => (
                    <option key={skill} value={skill}>
                      {skill}
                    </option>
                  ))}

                </select>

                <ChevronDown
                  size={20}
                  className="pointer-events-none absolute right-4 top-10 text-slate-500"
                />

              </div>


              {/* PROFICIENCY */}

              <div>

                <label className="mb-2 flex justify-between text-sm text-slate-400">

                  <span>
                    Proficiency
                  </span>

                  <span className="font-bold text-cyan-400">
                    {level}%
                  </span>

                </label>

                <div className="rounded-xl border border-white/10 bg-slate-900 px-4 py-4">

                  <input
                    type="range"
                    min="0"
                    max="100"
                    value={level}
                    onChange={(event) =>
                      setLevel(Number(event.target.value))
                    }
                    className="w-full cursor-pointer accent-cyan-400"
                  />

                  <div className="mt-2 flex justify-between text-xs text-slate-600">
                    <span>Beginner</span>
                    <span>Intermediate</span>
                    <span>Expert</span>
                  </div>

                </div>

              </div>


              {/* ADD BUTTON */}

              <div className="flex items-end">

                <button
                  type="button"
                  onClick={addSkill}
                  className="flex w-full items-center justify-center gap-2 rounded-xl bg-cyan-500 px-5 py-3.5 font-bold text-slate-950 transition hover:bg-cyan-400"
                >
                  <Plus size={20} />
                  Add Skill
                </button>

              </div>

            </div>


            {/* ADDED SKILLS */}

            {skills.length > 0 && (
              <div className="mt-8">

                <div className="mb-4 flex items-center justify-between">

                  <h3 className="font-semibold">
                    Added Skills
                  </h3>

                  <span className="text-sm text-slate-500">
                    {skills.length} skill
                    {skills.length !== 1 ? "s" : ""}
                  </span>

                </div>


                <div className="grid gap-3 sm:grid-cols-2">

                  {skills.map((skill) => (

                    <div
                      key={skill.name}
                      className="flex items-center justify-between rounded-xl border border-white/10 bg-slate-900 p-4"
                    >

                      <div className="min-w-0">

                        <p className="font-semibold">
                          {skill.name}
                        </p>

                        <div className="mt-2 flex items-center gap-3">

                          <div className="h-1.5 w-24 overflow-hidden rounded-full bg-slate-800">

                            <div
                              className="h-full rounded-full bg-cyan-400"
                              style={{
                                width: `${skill.level}%`,
                              }}
                            />

                          </div>

                          <span className="text-xs text-cyan-400">
                            {skill.level}%
                          </span>

                        </div>

                      </div>


                      <button
                        type="button"
                        onClick={() =>
                          removeSkill(skill.name)
                        }
                        className="ml-4 rounded-lg p-2 text-slate-600 transition hover:bg-red-500/10 hover:text-red-400"
                        title="Remove skill"
                      >
                        <Trash2 size={18} />
                      </button>

                    </div>

                  ))}

                </div>

              </div>
            )}

          </div>


          {/* ==========================================
              ANALYZE BUTTON
          ========================================== */}

          <div className="mt-10 border-t border-white/5 pt-10">

            <button
              type="button"
              onClick={analyzeSkills}
              disabled={loading}
              className="flex w-full items-center justify-center gap-3 rounded-xl bg-cyan-500 px-6 py-4 text-lg font-bold text-slate-950 transition hover:bg-cyan-400 disabled:cursor-not-allowed disabled:opacity-60"
            >

              {loading ? (
                <>
                  <Loader2
                    size={22}
                    className="animate-spin"
                  />

                  Analyzing Your Skills...
                </>
              ) : (
                <>
                  <Brain size={22} />

                  Analyze My Skills
                </>
              )}

            </button>

          </div>

        </div>


        {/* ==========================================
            RESULTS
        ========================================== */}

        {result && (
          <div className="mt-10 space-y-6">

            {/* ==========================================
                MATCH SCORE
            ========================================== */}

            <div className="relative overflow-hidden rounded-3xl border border-cyan-400/20 bg-cyan-400/[0.04] p-8 text-center">

              <div className="absolute left-1/2 top-0 h-40 w-40 -translate-x-1/2 rounded-full bg-cyan-400/10 blur-[80px]" />

              <div className="relative">

                <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-2xl bg-cyan-400/10 text-cyan-400">
                  <Target size={30} />
                </div>

                <p className="mt-5 text-sm font-semibold uppercase tracking-[0.2em] text-cyan-400">
                  Career Match
                </p>

                <div className="mt-2 text-7xl font-black tracking-tight">
                  {result.matchScore}%
                </div>

                <p className="mt-2 text-lg font-semibold text-white">
                  {getScoreLabel(result.matchScore)}
                </p>

                <p className="mx-auto mt-3 max-w-xl text-sm leading-6 text-slate-400">

                  {result.name
                    ? `${result.name}, your current skill match for ${result.career} is ${result.matchScore}%.`
                    : `Your current skill match for ${result.career} is ${result.matchScore}%.`}

                </p>

              </div>

            </div>


            {/* ==========================================
                QUICK STATS
            ========================================== */}

            <div className="grid gap-4 sm:grid-cols-3">

              <div className="rounded-2xl border border-white/10 bg-white/[0.03] p-5">

                <div className="flex items-center gap-3 text-cyan-400">
                  <Target size={20} />

                  <span className="text-sm text-slate-400">
                    Career Match
                  </span>
                </div>

                <p className="mt-3 text-3xl font-bold">
                  {result.matchScore}%
                </p>

              </div>


              <div className="rounded-2xl border border-white/10 bg-white/[0.03] p-5">

                <div className="flex items-center gap-3 text-cyan-400">
                  <TrendingUp size={20} />

                  <span className="text-sm text-slate-400">
                    Skills Analyzed
                  </span>
                </div>

                <p className="mt-3 text-3xl font-bold">
                  {result.analysis.length}
                </p>

              </div>


              <div className="rounded-2xl border border-white/10 bg-white/[0.03] p-5">

                <div className="flex items-center gap-3 text-amber-400">
                  <AlertTriangle size={20} />

                  <span className="text-sm text-slate-400">
                    Skill Gaps
                  </span>
                </div>

                <p className="mt-3 text-3xl font-bold">
                  {result.gaps.length}
                </p>

              </div>

            </div>


            {/* ==========================================
                SKILL GAP ANALYSIS
            ========================================== */}

            <div className="rounded-3xl border border-white/10 bg-white/[0.03] p-6 sm:p-8">

              <div>

                <h2 className="text-2xl font-bold">
                  Skill Gap Analysis
                </h2>

                <p className="mt-2 text-sm leading-6 text-slate-500">
                  Your current proficiency compared with
                  the requirements for {result.career}.
                </p>

              </div>


              <div className="mt-8 space-y-7">

                {result.analysis.map((item) => (

                  <div key={item.skill}>

                    <div className="mb-2 flex items-center justify-between gap-4">

                      <span className="font-medium">
                        {item.skill}
                      </span>

                      <span className="whitespace-nowrap text-sm text-slate-400">
                        {item.current}% / {item.required}%
                      </span>

                    </div>


                    <div className="h-3 overflow-hidden rounded-full bg-slate-800">

                      <div
                        className="h-full rounded-full bg-cyan-400 transition-all duration-700"
                        style={{
                          width: `${Math.min(
                            item.current,
                            100
                          )}%`,
                        }}
                      />

                    </div>


                    <div className="mt-2 flex justify-between text-xs">

                      <span className="text-slate-600">
                        Current Level
                      </span>

                      {item.gap > 0 ? (
                        <span className="text-amber-400">
                          {item.gap}% gap
                        </span>
                      ) : (
                        <span className="flex items-center gap-1 text-emerald-400">
                          <CheckCircle2 size={13} />
                          Requirement met
                        </span>
                      )}

                    </div>

                  </div>

                ))}

              </div>

            </div>


            {/* ==========================================
                TOP SKILL GAPS
            ========================================== */}

            {result.gaps.length > 0 && (
              <div className="rounded-3xl border border-white/10 bg-white/[0.03] p-6 sm:p-8">

                <div>

                  <p className="text-sm font-semibold uppercase tracking-widest text-amber-400">
                    Priority Areas
                  </p>

                  <h2 className="mt-2 text-2xl font-bold">
                    Skills You Should Improve
                  </h2>

                  <p className="mt-2 text-sm leading-6 text-slate-500">
                    Focus on these areas first to improve
                    your career match.
                  </p>

                </div>


                <div className="mt-6 space-y-3">

                  {result.gaps.map((item, index) => (

                    <div
                      key={item.skill}
                      className="flex items-center justify-between gap-4 rounded-2xl border border-white/5 bg-slate-900 p-4"
                    >

                      <div className="flex min-w-0 items-center gap-4">

                        <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-cyan-400/10 text-sm font-bold text-cyan-400">
                          {index + 1}
                        </div>

                        <div className="min-w-0">

                          <p className="font-semibold">
                            {item.skill}
                          </p>

                          <p className="mt-1 text-xs text-slate-500">
                            Current: {item.current}% ·
                            Required: {item.required}%
                          </p>

                        </div>

                      </div>


                      <span className="shrink-0 rounded-lg bg-amber-400/10 px-3 py-1.5 text-sm font-semibold text-amber-400">
                        {item.gap}% gap
                      </span>

                    </div>

                  ))}

                </div>

              </div>
            )}


            {/* ==========================================
                NEXT STEP
            ========================================== */}

            <div className="rounded-3xl border border-cyan-400/10 bg-gradient-to-br from-cyan-400/[0.08] to-blue-500/[0.03] p-8 text-center">

              <TrendingUp
                size={30}
                className="mx-auto text-cyan-400"
              />

              <h2 className="mt-4 text-2xl font-bold">
                Your Personalized Roadmap
              </h2>

              <p className="mx-auto mt-2 max-w-xl text-sm leading-6 text-slate-400">
                Based on your skill gaps, the next version
                of SkillGap AI will generate a personalized
                learning roadmap with recommended topics,
                projects, and learning priorities.
              </p>

              <div className="mt-5 inline-flex items-center gap-2 rounded-xl border border-cyan-400/20 bg-cyan-400/10 px-4 py-2 text-sm text-cyan-300">
                <Brain size={16} />
                AI Roadmap Coming Next
              </div>

            </div>

          </div>
        )}

      </div>

    </div>
  );
}

export default Assessment;