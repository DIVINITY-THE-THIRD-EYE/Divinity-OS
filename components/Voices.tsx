"use client";

import { useEffect, useState } from "react";
import { AnimatePresence, m } from "framer-motion";
import type { Testimonial } from "@/lib/content";

export default function Voices({ items }: { items: Testimonial[] }) {
  const [i, setI] = useState(0);

  useEffect(() => {
    if (items.length < 2) return; // nothing to rotate through
    const id = setInterval(() => setI((p) => (p + 1) % items.length), 6500);
    return () => clearInterval(id);
  }, [items.length]);

  // Guard against an empty CMS result so the section never crashes.
  if (items.length === 0) return null;
  const t = items[Math.min(i, items.length - 1)];

  return (
    <section className="relative overflow-hidden border-t border-[var(--line-dark)] bg-void px-6 py-32 text-center md:px-10 md:py-44">
      <span
        aria-hidden
        className="pointer-events-none absolute left-1/2 top-12 -translate-x-1/2 font-display text-[200px] leading-none text-ember/[0.08]"
      >
        &ldquo;
      </span>

      <div className="relative mx-auto max-w-3xl">
        <p className="eyebrow mb-12 text-ember">Voices</p>

        <div className="min-h-[220px]">
          <AnimatePresence mode="wait">
            <m.div
              key={i}
              initial={{ opacity: 0, y: 16 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -12 }}
              transition={{ duration: 0.6 }}
            >
              <p className="font-display text-[clamp(24px,3.4vw,42px)] font-light italic leading-[1.35] text-bone">
                {t.quote}
              </p>
              <div className="mt-10 flex items-center justify-center gap-3">
                <span className="flex h-10 w-10 items-center justify-center rounded-full border border-[var(--line-dark)] font-display text-ember">
                  {t.name.charAt(0)}
                </span>
                <span className="text-left">
                  <span className="block font-mono text-[11px] uppercase tracking-wide text-bone">
                    {t.name}
                  </span>
                  <span className="font-body text-[12px] text-mist">{t.meta}</span>
                </span>
              </div>
            </m.div>
          </AnimatePresence>
        </div>

        <div className="mt-12 flex justify-center gap-1">
          {items.map((_, idx) => (
            <button
              key={idx}
              onClick={() => setI(idx)}
              aria-label={`Show testimonial ${idx + 1}`}
              aria-pressed={idx === i}
              className="flex h-6 w-6 items-center justify-center"
            >
              <span
                className={`h-2 w-2 rounded-full border border-[var(--line-dark)] transition-all ${
                  idx === i ? "scale-125 bg-ember" : "bg-transparent"
                }`}
              />
            </button>
          ))}
        </div>
      </div>
    </section>
  );
}
