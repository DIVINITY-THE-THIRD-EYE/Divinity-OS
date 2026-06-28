"use client";

import { MotionConfig } from "framer-motion";
import type { ReactNode } from "react";

/**
 * Makes every Framer Motion animation honor the OS "reduce motion" setting.
 * Framer's transform/opacity animations are WAAPI/rAF-driven and are NOT
 * governed by the CSS `prefers-reduced-motion` rules in globals.css, so without
 * this they would play regardless of the user's preference (WCAG 2.3.3).
 */
export default function MotionProvider({ children }: { children: ReactNode }) {
  return <MotionConfig reducedMotion="user">{children}</MotionConfig>;
}
