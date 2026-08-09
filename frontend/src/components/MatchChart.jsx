import React from "react";

export default function MatchChart({ score = 0, size = 96, stroke = 10 }) {

    const radius = (size - stroke) / 2;
    const circumference = 2 * Math.PI * radius;
    const offset = circumference * (1 - Math.min(Math.max(score, 0), 100) / 100);

    return (
        <svg
            width={size}
            height={size}
            viewBox={`0 0 ${size} ${size}`}
            role="img"
            aria-label={`Match score ${score} percent`}
        >
            <defs>
                <linearGradient id="grad" x1="0%" x2="100%">
                    <stop offset="0%" stopColor="#4f46e5" />
                    <stop offset="100%" stopColor="#06b6d4" />
                </linearGradient>
            </defs>

            <g transform={`translate(${size / 2}, ${size / 2})`}>
                <circle
                    r={radius}
                    fill="none"
                    stroke="#eee"
                    strokeWidth={stroke}
                />

                <circle
                    r={radius}
                    fill="none"
                    stroke="url(#grad)"
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
                    fill="#111827"
                >
                    {Math.round(score)}%
                </text>
            </g>
        </svg>
    );

}
