"use client";

import { useEffect, useRef, useState } from "react";
import { useInView } from "framer-motion";
import { disciplines, schedule } from "@/lib/content";

type Stat = { value: number; suffix: string; label: string };

// Derived from real content — no fabricated figures.
const weeklyClasses = Object.values(schedule).flat().length;
const daysAWeek = Object.keys(schedule).length;

const stats: Stat[] = [
  { value: disciplines.length, suffix: "", label: "Disciplines taught" },
  { value: weeklyClasses, suffix: "", label: "Classes a week" },
  { value: 3, suffix: "", label: "Daily batches" },
  { value: daysAWeek, suffix: "", label: "Days a week" },
];

function Counter({ value, suffix }: { value: number; suffix: string }) {
  const [count, setCount] = useState(0);
  const ref = useRef<HTMLSpanElement>(null);
  const inView = useInView(ref, { once: true, margin: "-20% 0px" });

  useEffect(() => {
    if (!inView) return;

    // Respect reduced motion: jump straight to the final value.
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      setCount(value);
      return;
    }

    let raf = 0;
    const duration = 1400;
    const step = performance.now();
    const tick = (now: number) => {
      const progress = Math.min((now - step) / duration, 1);
      const eased = 1 - Math.pow(1 - progress, 3);
      setCount(Math.round(eased * value));
      if (progress < 1) raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf); // stop on unmount (no setState leak)
  }, [inView, value]);

  return (
    <span ref={ref}>
      {/* Screen readers get the final value as real text; the animated count is
          hidden from them so they don't read a mid-animation number. */}
      <span className="sr-only">
        {value}
        {suffix}
      </span>
      <span aria-hidden="true">
        {count}
        {suffix}
      </span>
    </span>
  );
}

export default function StatsBand() {
  return (
    <section aria-label="Academy at a glance" className="border-y border-[var(--line-dark)] bg-deep">
      <div className="mx-auto grid max-w-6xl grid-cols-2 divide-x divide-y divide-[var(--line-dark)] md:grid-cols-4 md:divide-y-0">
        {stats.map((s) => (
          <div key={s.label} className="px-8 py-10 text-center">
            <p className="font-display text-[clamp(40px,6vw,72px)] font-light leading-none text-ember">
              <Counter value={s.value} suffix={s.suffix} />
            </p>
            <p className="mt-2 font-mono text-[11px] uppercase tracking-wide text-mist">
              {s.label}
            </p>
          </div>
        ))}
      </div>
    </section>
  );
}
