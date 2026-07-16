"use client";

import { useState } from "react";
import { AnimatePresence, m } from "framer-motion";
import type { ClassSlot } from "@/lib/content";
import { waHref } from "@/lib/links";
import { introOffer } from "@/content/offers";

const DAYS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

export default function Schedule({
  data,
  showHeading = true,
}: {
  data: Record<string, ClassSlot[]>;
  showHeading?: boolean;
}) {
  const [day, setDay] = useState("Mon");
  const slots = data[day] ?? [];

  return (
    <section
      id="schedule"
      className="border-t border-[var(--line)] bg-surface px-6 py-28 md:px-10 md:py-40"
    >
      <div className="mx-auto max-w-5xl">
        <div className="mb-14 flex flex-wrap items-end justify-between gap-8">
          {showHeading && (
            <div>
              <p className="eyebrow mb-6 text-accent">Weekly rhythm</p>
              <h2 className="font-display text-[clamp(38px,5.5vw,72px)] font-light leading-none tracking-tight">
                Find your <em className="text-accent">hour.</em>
              </h2>
            </div>
          )}

          <div className="flex flex-wrap gap-1.5" role="group" aria-label="Choose a day">
            {DAYS.map((d) => (
              <button
                key={d}
                onClick={() => setDay(d)}
                aria-pressed={day === d}
                className={`border px-4 py-2.5 font-mono text-[11px] uppercase tracking-wide transition-colors ${
                  day === d
                    ? "border-accent bg-accent text-surface"
                    : "border-[var(--line)] text-fg-muted hover:text-accent"
                }`}
              >
                {d}
              </button>
            ))}
          </div>
        </div>

        <div className="min-h-[260px]" aria-live="polite" aria-atomic="true">
          <AnimatePresence mode="wait">
            <m.div
              key={day}
              initial={{ opacity: 0, y: 12 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -8 }}
              transition={{ duration: 0.4 }}
            >
              {slots.map((s, i) => {
                const joinHref = waHref(
                  `Namaste — I'd like to join ${s.name} (${day} ${s.time}, ${s.batch} batch) under the ${introOffer.price} ${introOffer.duration} offer.`
                );
                return (
                  <div
                    key={i}
                    className="grid grid-cols-1 items-center gap-3 border-b border-[var(--line)] py-6 md:grid-cols-[180px_1fr_auto_auto] md:gap-6"
                  >
                    <div className="font-display text-2xl text-fg">
                      {s.time}
                      <span className="ml-3 font-mono text-[10px] uppercase tracking-wide text-fg-muted">
                        {s.batch}
                      </span>
                    </div>
                    <div>
                      <div className="font-body text-lg text-fg">{s.name}</div>
                      <div className="font-body text-[13px] text-fg-muted">{s.detail}</div>
                    </div>
                    <span className="justify-self-start border border-[var(--line)] px-3 py-1.5 font-mono text-[9px] uppercase tracking-wide text-accent md:justify-self-end">
                      {s.level}
                    </span>
                    <a
                      href={joinHref}
                      target="_blank"
                      rel="noopener noreferrer"
                      data-hover
                      className="justify-self-start font-mono text-[11px] uppercase tracking-wide text-accent transition-colors hover:text-ember-pale md:justify-self-end"
                    >
                      Join →
                    </a>
                  </div>
                );
              })}
            </m.div>
          </AnimatePresence>
        </div>
      </div>
    </section>
  );
}
