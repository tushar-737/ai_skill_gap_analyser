"""Collapse repeated education programs such as BCA / B.C.A. / BCom / B.Com."""

from __future__ import annotations

import re
from typing import Dict, Iterable, List


ALIASES = {
    "bca": "BCA",
    "bachelor of computer applications": "BCA",
    "mca": "MCA",
    "master of computer applications": "MCA",
    "pgdca": "PGDCA",
    "bcom": "B.Com",
    "bachelor of commerce": "B.Com",
    "bcom hons": "B.Com Hons",
    "mcom": "M.Com",
    "master of commerce": "M.Com",
    "bba": "BBA",
    "mba": "MBA",
    "bms": "BMS",
    "pgdm": "PGDM",
    "ca": "CA",
    "cma": "CMA",
    "bed": "B.Ed",
    "med": "M.Ed",
    "bdes": "B.Des",
    "mdes": "M.Des",
    "bpharm": "B.Pharm",
    "bsc computer science": "BSc Computer Science",
    "bsc cs": "BSc Computer Science",
    "bsc it": "BSc IT",
}


def normalize_education_name(name: str) -> str:
    cleaned = re.sub(r"[.()]", "", (name or "").strip().lower())
    cleaned = re.sub(r"\s+", " ", cleaned).strip()
    cleaned = cleaned.replace("honours", "hons").replace("honors", "hons")
    return cleaned


def display_education_name(name: str) -> str:
    return ALIASES.get(normalize_education_name(name), (name or "").strip())


def dedupe_education_programs(programs: Iterable[dict]) -> List[dict]:
    """Keep one program per normalized name. Lowest id wins."""
    best: Dict[str, dict] = {}
    for program in programs:
        raw = (program.get("name") or "").strip()
        if not raw:
            continue
        key = normalize_education_name(raw)
        current = {**program, "name": display_education_name(raw)}
        previous = best.get(key)
        previous_id = previous.get("id", 10**9) if previous else 10**9
        current_id = current.get("id", 10**9)
        if previous is None or current_id < previous_id:
            best[key] = current
    return sorted(best.values(), key=lambda item: (item.get("name") or "").lower())
