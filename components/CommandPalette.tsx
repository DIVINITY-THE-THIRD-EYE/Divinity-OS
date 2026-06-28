"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import { AnimatePresence, m } from "framer-motion";
import { site } from "@/lib/content";
import { waHref } from "@/lib/links";

type Item = {
  label: string;
  hint: string;
  kind: "section" | "link";
  target: string;
};

const ITEMS: Item[] = [
  { label: "Academy", hint: "About Divinity", kind: "section", target: "#about" },
  { label: "Disciplines", hint: "What we practice", kind: "section", target: "#disciplines" },
  { label: "The space", hint: "Inside the studio", kind: "section", target: "#space" },
  { label: "The path", hint: "Align · Awaken · Ascend", kind: "section", target: "#method" },
  { label: "Schedule", hint: "Weekly rhythm", kind: "section", target: "#schedule" },
  { label: "Membership", hint: "Plans & pricing", kind: "section", target: "#membership" },
  { label: "Questions", hint: "FAQ", kind: "section", target: "#faq" },
  { label: "Begin", hint: "Send an enquiry", kind: "section", target: "#contact" },
  { label: "WhatsApp", hint: "Chat with us now", kind: "link", target: waHref() },
  { label: "Instagram", hint: "Follow the practice", kind: "link", target: site.instagram },
];

function navigate(item: Item) {
  if (item.kind === "link") {
    window.open(item.target, "_blank", "noopener,noreferrer");
    return;
  }
  // Re-use the Lenis anchor handler by clicking a real link
  const a = document.createElement("a");
  a.href = item.target;
  document.body.appendChild(a);
  a.click();
  a.remove();
}

export default function CommandPalette() {
  const [open, setOpen] = useState(false);
  const [q, setQ] = useState("");
  const [active, setActive] = useState(0);
  const inputRef = useRef<HTMLInputElement>(null);

  const results = useMemo(() => {
    const s = q.trim().toLowerCase();
    if (!s) return ITEMS;
    return ITEMS.filter(
      (i) =>
        i.label.toLowerCase().includes(s) || i.hint.toLowerCase().includes(s)
    );
  }, [q]);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === "k") {
        e.preventDefault();
        setOpen((o) => !o);
      }
      if (e.key === "Escape") setOpen(false);
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, []);

  useEffect(() => {
    let tid: any;
    if (open) {
      setQ("");
      setActive(0);
      tid = setTimeout(() => inputRef.current?.focus(), 40);
    }
    return () => clearTimeout(tid);
  }, [open]);

  useEffect(() => setActive(0), [q]);

  const onListKey = (e: React.KeyboardEvent) => {
    if (e.key === "ArrowDown") {
      e.preventDefault();
      setActive((a) => Math.min(a + 1, results.length - 1));
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      setActive((a) => Math.max(a - 1, 0));
    } else if (e.key === "Enter" && results[active]) {
      e.preventDefault();
      navigate(results[active]);
      setOpen(false);
    }
  };

  return (
    <AnimatePresence>
      {open && (
        <m.div
          className="fixed inset-0 z-[450] flex items-start justify-center px-4 pt-[18vh]"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          onClick={() => setOpen(false)}
        >
          <div className="absolute inset-0 bg-void/70 backdrop-blur-sm" />
          <m.div
            role="dialog"
            aria-modal="true"
            aria-label="Command menu"
            initial={{ opacity: 0, y: -12, scale: 0.98 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -12, scale: 0.98 }}
            transition={{ duration: 0.2 }}
            onClick={(e) => e.stopPropagation()}
            onKeyDown={onListKey}
            className="relative w-full max-w-lg overflow-hidden rounded-xl border border-[var(--line-dark)] bg-deep/95 shadow-2xl backdrop-blur-xl"
          >
            <div className="flex items-center gap-3 border-b border-[var(--line-dark)] px-4">
              <span className="font-mono text-xs text-ember">⌘</span>
              <input
                ref={inputRef}
                value={q}
                onChange={(e) => setQ(e.target.value)}
                placeholder="Where would you like to go?"
                className="w-full bg-transparent py-4 font-body text-bone placeholder:text-mist focus:outline-none"
              />
              <span className="kbd">esc</span>
            </div>
            <ul className="max-h-[44vh] overflow-y-auto py-2">
              {results.length === 0 && (
                <li className="px-4 py-6 text-center font-body text-sm text-mist">
                  Nothing matches “{q}”.
                </li>
              )}
              {results.map((item, i) => (
                <li key={item.label}>
                  <button
                    onMouseEnter={() => setActive(i)}
                    onClick={() => {
                      navigate(item);
                      setOpen(false);
                    }}
                    className={`flex w-full items-center justify-between px-4 py-3 text-left transition-colors ${
                      i === active ? "bg-ember/10" : ""
                    }`}
                  >
                    <span className="flex items-center gap-3">
                      <span
                        className={`h-1.5 w-1.5 rounded-full ${
                          i === active ? "bg-ember" : "bg-mist/40"
                        }`}
                      />
                      <span className="font-body text-bone">{item.label}</span>
                    </span>
                    <span className="font-mono text-[10px] uppercase tracking-wide text-mist">
                      {item.hint}
                    </span>
                  </button>
                </li>
              ))}
            </ul>
          </m.div>
        </m.div>
      )}
    </AnimatePresence>
  );
}
