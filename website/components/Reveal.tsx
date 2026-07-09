"use client";

import { m } from "framer-motion";
import type { ReactNode } from "react";

// `immediate`: content that's always above-the-fold (e.g. the H1 in
// PageHeader, repeated on nearly every route) must not sit at opacity:0
// waiting for JS hydration + an IntersectionObserver callback before it can
// become the LCP paint — that gates LCP behind JS delivery time, badly so
// under network throttling (15_PERFORMANCE.md). `immediate` renders already
// in the final state (no invisible flash, no entrance transition) instead.
// D009: budgets are non-negotiable, so this specific instance yields the
// fade-in, not the whole component — every other Reveal usage is unaffected.
export default function Reveal({
  children,
  delay = 0,
  y = 26,
  className = "",
  immediate = false,
}: {
  children: ReactNode;
  delay?: number;
  y?: number;
  className?: string;
  immediate?: boolean;
}) {
  return (
    <m.div
      className={className}
      initial={immediate ? false : { opacity: 0, y }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-80px" }}
      transition={{ duration: 0.9, delay, ease: [0.22, 1, 0.36, 1] }}
    >
      {children}
    </m.div>
  );
}
