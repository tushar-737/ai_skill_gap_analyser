import React, { useId } from "react";

export default function MatchChart({
    score = 0,
    size = 96,
    stroke = 10,
    ariaScore,
}) {
    // useId is unique per component instance, preventing gradient
    // collisions when multiple charts render on the same page.
    // Colons are stripped because some browsers mishandle them in
    // SVG url(#...) fragment references.
    const gradientId = useId().replace(/:/g, "");

    const radius = (size - stroke) / 2;
    const circumference = 2 * Math.PI * radius;
    const offset = circumference * (1 - Math.min(Math.max(score, 0), 100) / 100);

    // ariaScore lets callers animate the visible number while
    // keeping the screen-reader label at the final value.
    const label = Math.round(ariaScore ?? score);

    return (
        <svg
            width={size}
            height={size}
            viewBox={`0 0 ${size} ${size}`}
            role="img"
            aria-label={`Match score ${label} percent`}
        >
            <defs>
                <linearGradient id={gradientId} x1="0%" x2="100%">
                    <stop offset="0%" stopColor="#4f46e5" />
                    <stop offset="100%" stopColor="#f59e0b" />
                </linearGradient>
            </defs>

            <g transform={`translate(${size / 2}, ${size / 2})`}>
                <circle
                    r={radius}
                    fill="none"
                    stroke="rgba(148, 163, 184, 0.15)"
                    strokeWidth={stroke}
                />

                <circle
                    r={radius}
                    fill="none"
                    stroke={`url(#${gradientId})`}
                    strokeWidth={stroke}
                    strokeLinecap="round"
                    strokeDasharray={`${circumference} ${circumference}`}
                    strokeDashoffset={offset}
                    transform="rotate(-90)"
                />

                <text
                    x="0"
                    y="0"
                    textAnchor="middle"
                    dominantBaseline="central"
                    fontSize={size * 0.24}
                    fontWeight="600"
                    fill="#0f172a"
                >
                    {Math.round(score)}%
                </text>
            </g>
        </svg>
    );

}
