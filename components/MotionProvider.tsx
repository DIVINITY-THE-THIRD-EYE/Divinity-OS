"use client";

import { LazyMotion, domMax, MotionConfig } from "framer-motion";
import type { ReactNode } from "react";

/**
 * - LazyMotion + the `m` component (used across the app instead of `motion`)
 *   loads the feature bundle lazily instead of pulling the full Framer Motion
 *   runtime into the entry chunk (domMax is needed for the FAQ's height:auto
 *   animation). `strict` makes any
 *   stray full `motion` component throw so regressions are caught immediately.
 * - MotionConfig makes every animation honor the OS "reduce motion" setting
 *   (Framer's WAAPI/rAF animations aren't covered by the CSS rules).
 */
export default function MotionProvider({ children }: { children: ReactNode }) {
  return (
    <LazyMotion features={domMax} strict>
      <MotionConfig reducedMotion="user">{children}</MotionConfig>
    </LazyMotion>
  );
}
