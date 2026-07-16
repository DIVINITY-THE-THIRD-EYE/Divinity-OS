"use client";

import { useEffect, useRef, useState } from "react";
import { useInView } from "framer-motion";
import { statistics } from "@/content/statistics";

// Qualitative fallback — shown whenever there's no verified numeric stat yet.
// Real, non-numeric claims only (PROJECT_RULES: never fabricate figures).
const benefits = [
  { title: "Small, focused batches", body: "Dawn, midday and dusk sessions kept small enough for real, hands-on attention." },
  { title: "Guided by the founder", body: "Personal guidance from Sachin Rajvanshi and our instructors, not a faceless app." },
  { title: "A practice that adapts", body: "Yoga, fitness and therapeutic work — programmed around your body and your goals." },
  { title: "Steady, lasting change", body: "Align, awaken, ascend — a three-stage path built for the long run, not a quick fix." },
];

function Counter({ value }: { value: number }) {
  const [count, setCount] = useState(0);
  const ref = useRef<HTMLSpanElement>(null);
  const inView = useInView(ref, { once: true, margin: "-20% 0px" });

  useEffect(() => {
    if (!inView) return;
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      setCount(value);
      return;
    }
    let raf = 0;
    const duration = 1200;
    const start = performance.now();
    const tick = (now: number) => {
      const progress = Math.min((now - start) / duration, 1);
      setCount(Math.round((1 - Math.pow(1 - progress, 3)) * value));
      if (progress < 1) raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  }, [inView, value]);

  return <span ref={ref}>{count}</span>;
}

/** Act II, section 4 — verified numbers only; unverified stats fall back to benefit copy. */
export default function Benefits() {
  const verified = statistics.filter((s) => s.verified);

  return (
    <section
      aria-labelledby="benefits-heading"
      className="border-y border-[var(--line-dark)] bg-deep px-6 py-24 md:px-10 md:py-28"
    >
      <div className="mx-auto max-w-6xl">
        <h2 id="benefits-heading" className="eyebrow mb-12 text-center text-ember">
          Why members stay
        </h2>

        {verified.length > 0 ? (
          <div className="grid grid-cols-2 gap-x-6 gap-y-10 md:grid-cols-4">
            {verified.map((s) => (
              <div key={s.label} className="text-center">
                <p className="font-display text-[clamp(40px,6vw,64px)] font-light leading-none text-ember">
                  <Counter value={s.value} />
                </p>
                <p className="mt-2 font-mono text-[11px] uppercase tracking-wide text-mist">
                  {s.label}
                </p>
              </div>
            ))}
          </div>
        ) : (
          <div className="grid gap-x-6 gap-y-10 sm:grid-cols-2 lg:grid-cols-4">
            {benefits.map((b) => (
              <div key={b.title} className="text-center">
                <p className="font-display text-xl italic text-bone">{b.title}</p>
                <p className="mt-2 font-body text-[13px] leading-relaxed text-mist">{b.body}</p>
              </div>
            ))}
          </div>
        )}
      </div>
    </section>
  );
}
