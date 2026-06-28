"use client";

import { useState } from "react";
import { AnimatePresence, m } from "framer-motion";
import Reveal from "./Reveal";
import { faqs } from "@/lib/content";

export default function Faq() {
  const [open, setOpen] = useState<number | null>(0);

  return (
    <section id="faq" className="bg-bone px-6 py-28 text-ink md:px-10 md:py-40">
      <div className="mx-auto max-w-4xl">
        <Reveal className="mb-14">
          <p className="eyebrow mb-6 text-ember-deep">Before you begin</p>
          <h2 className="font-display text-[clamp(38px,5.5vw,72px)] font-light leading-none tracking-tight">
            Questions, <em className="text-ember-deep">answered.</em>
          </h2>
        </Reveal>

        <div>
          {faqs.map((f, i) => {
            const isOpen = open === i;
            return (
              <Reveal key={i} delay={i * 0.04}>
                <div className="border-t border-[var(--line-light)] last:border-b">
                  <button
                    onClick={() => setOpen(isOpen ? null : i)}
                    className="flex w-full items-center justify-between gap-6 py-7 text-left"
                    aria-expanded={isOpen}
                    aria-controls={`faq-panel-${i}`}
                    id={`faq-button-${i}`}
                  >
                    <span className="font-display text-xl leading-snug md:text-2xl">
                      {f.q}
                    </span>
                    <span
                      className={`shrink-0 font-mono text-ember-deep transition-transform duration-300 ${
                        isOpen ? "rotate-45" : ""
                      }`}
                      aria-hidden
                    >
                      +
                    </span>
                  </button>
                  <AnimatePresence initial={false}>
                    {isOpen && (
                      <m.div
                        id={`faq-panel-${i}`}
                        role="region"
                        aria-labelledby={`faq-button-${i}`}
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: "auto", opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        transition={{ duration: 0.35, ease: [0.22, 1, 0.36, 1] }}
                        className="overflow-hidden"
                      >
                        <p className="max-w-2xl pb-7 font-body text-[15px] leading-[1.85] text-ink-mute">
                          {f.a}
                        </p>
                      </m.div>
                    )}
                  </AnimatePresence>
                </div>
              </Reveal>
            );
          })}
        </div>
      </div>
    </section>
  );
}
