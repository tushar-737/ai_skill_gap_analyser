import { useEffect, useMemo, useRef, useState } from "react";

export default function SearchableSelect({
    id,
    label,
    options = [],
    value = "",
    onChange = () => {},
    placeholder = "Search...",
    disabled = false,
    loading = false,
    popular = [],
}) {
    const [query, setQuery] = useState("");
    const [open, setOpen] = useState(false);
    const [highlight, setHighlight] = useState(0);
    const inputRef = useRef(null);
    const listRef = useRef(null);

    const selected = useMemo(() => options.find((o) => String(o.id) === String(value)), [options, value]);

    const filtered = useMemo(() => {
        const q = query.trim().toLowerCase();
        if (!q) return options;
        return options.filter((o) => o.name.toLowerCase().includes(q));
    }, [options, query]);

    // Popular chips — only show when no query and not loading
    const popularItems = useMemo(() => {
        if (query || loading || options.length === 0) return [];
        return popular
            .map((name) => options.find((o) => o.name.toLowerCase().includes(name.toLowerCase())))
            .filter(Boolean)
            .slice(0, 3);
    }, [popular, options, query, loading]);

    useEffect(() => {
        setHighlight(0);
    }, [filtered.length, query]);

    useEffect(() => {
        if (!open) return;
        const el = listRef.current?.querySelector(`[data-index="${highlight}"]`);
        el?.scrollIntoView({ block: "nearest" });
    }, [highlight, open]);

    function select(option) {
        onChange(String(option.id));
        setQuery("");
        setOpen(false);
        setHighlight(0);
    }

    function clear() {
        onChange("");
        setQuery("");
        setOpen(false);
    }

    function onKeyDown(e) {
        if (!open && (e.key === "ArrowDown" || e.key === "Enter")) {
            setOpen(true);
            e.preventDefault();
            return;
        }
        if (!open) return;
        switch (e.key) {
            case "ArrowDown":
                e.preventDefault();
                setHighlight((h) => Math.min(h + 1, filtered.length - 1));
                break;
            case "ArrowUp":
                e.preventDefault();
                setHighlight((h) => Math.max(h - 1, 0));
                break;
            case "Home":
                e.preventDefault();
                setHighlight(0);
                break;
            case "End":
                e.preventDefault();
                setHighlight(filtered.length - 1);
                break;
            case "Enter":
                e.preventDefault();
                if (filtered[highlight]) select(filtered[highlight]);
                break;
            case "Escape":
                e.preventDefault();
                setOpen(false);
                break;
            default:
                break;
        }
    }

    const displayValue = open ? query : selected ? selected.name : query;

    return (
        <div className="searchable-wrap">
            {label && (
                <label htmlFor={id} style={{ display: "block", marginBottom: 6, fontWeight: 600, fontSize: 13, color: "#0f172a" }}>
                    {label}
                </label>
            )}
            <div className={`searchable-input ${open ? "open" : ""} ${disabled ? "disabled" : ""}`}>
                <span aria-hidden>🔍</span>
                <input
                    ref={inputRef}
                    id={id}
                    type="text"
                    role="combobox"
                    aria-expanded={open}
                    aria-controls={`${id}-listbox`}
                    aria-activedescendant={open && filtered[highlight] ? `${id}-option-${filtered[highlight].id}` : undefined}
                    aria-autocomplete="list"
                    placeholder={loading ? "Loading..." : placeholder}
                    value={displayValue}
                    disabled={disabled || loading}
                    onFocus={() => setOpen(true)}
                    onChange={(e) => {
                        setQuery(e.target.value);
                        setOpen(true);
                    }}
                    onKeyDown={onKeyDown}
                    onBlur={() => setTimeout(() => setOpen(false), 150)}
                    autoComplete="off"
                />
                {selected && !disabled && (
                    <button type="button" className="search-clear" onMouseDown={clear} aria-label={`Clear ${label}`}>
                        ×
                    </button>
                )}
                <span className="searchable-chevron" aria-hidden>
                    ▾
                </span>
            </div>

            {open && !disabled && (
                <div className="searchable-dropdown" role="listbox" id={`${id}-listbox`} ref={listRef}>
                    {popularItems.length > 0 && (
                        <>
                            <div className="searchable-section">Popular</div>
                            <div className="searchable-pills">
                                {popularItems.map((p) => (
                                    <button key={p.id} type="button" className="searchable-pill" onMouseDown={() => select(p)}>
                                        {p.name}
                                    </button>
                                ))}
                            </div>
                            <div className="searchable-section">All options</div>
                        </>
                    )}
                    {filtered.length === 0 ? (
                        <div className="searchable-empty">No results for “{query}”</div>
                    ) : (
                        filtered.map((opt, idx) => (
                            <button
                                key={opt.id}
                                id={`${id}-option-${opt.id}`}
                                data-index={idx}
                                type="button"
                                role="option"
                                aria-selected={String(opt.id) === String(value)}
                                className={`searchable-option ${idx === highlight ? "highlight" : ""} ${String(opt.id) === String(value) ? "selected" : ""}`}
                                onMouseDown={() => select(opt)}
                            >
                                {opt.name}
                                {String(opt.id) === String(value) && <span aria-hidden> ✓</span>}
                            </button>
                        ))
                    )}
                </div>
            )}
        </div>
    );
}
