"use client";

import { useState } from "react";
import { AnimatePresence, motion } from "framer-motion";
import type { ClassSlot } from "@/lib/content";

const DAYS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

export default function Schedule({ data }: { data: Record<string, ClassSlot[]> }) {
  const [day, setDay] = useState("Mon");
  const slots = data[day] ?? [];

  return (
    <section
      id="schedule"
      className="border-t border-[var(--line-dark)] bg-void px-6 py-28 md:px-10 md:py-40"
    >
      <div className="mx-auto max-w-5xl">
        <div className="mb-14 flex flex-wrap items-end justify-between gap-8">
          <div>
            <p className="eyebrow mb-6 text-ember">Weekly rhythm</p>
            <h2 className="font-display text-[clamp(38px,5.5vw,72px)] font-light leading-none tracking-tight">
              Find your <em className="text-ember">hour.</em>
            </h2>
          </div>

          <div className="flex flex-wrap gap-1.5">
            {DAYS.map((d) => (
              <button
                key={d}
                onClick={() => setDay(d)}
                className={`border px-4 py-2.5 font-mono text-[11px] uppercase tracking-wide transition-colors ${
                  day === d
                    ? "border-ember bg-ember text-void"
                    : "border-[var(--line-dark)] text-mist hover:text-ember"
                }`}
              >
                {d}
              </button>
            ))}
          </div>
        </div>

        <div className="min-h-[260px]">
          <AnimatePresence mode="wait">
            <motion.div
              key={day}
              initial={{ opacity: 0, y: 12 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -8 }}
              transition={{ duration: 0.4 }}
            >
              {slots.map((s, i) => (
                <div
                  key={i}
                  className="grid grid-cols-1 items-center gap-3 border-b border-[var(--line-dark)] py-6 md:grid-cols-[180px_1fr_auto] md:gap-10"
                >
                  <div className="font-display text-2xl text-bone">
                    {s.time}
                    <span className="ml-3 font-mono text-[10px] uppercase tracking-wide text-mist">
                      {s.batch}
                    </span>
                  </div>
                  <div>
                    <div className="font-body text-lg text-bone">{s.name}</div>
                    <div className="font-body text-[13px] text-mist">{s.detail}</div>
                  </div>
                  <span className="justify-self-start border border-[var(--line-dark)] px-3 py-1.5 font-mono text-[9px] uppercase tracking-wide text-ember md:justify-self-end">
                    {s.level}
                  </span>
                </div>
              ))}
            </motion.div>
          </AnimatePresence>
        </div>
      </div>
    </section>
  );
}
