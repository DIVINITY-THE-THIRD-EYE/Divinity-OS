"use client";

import { useEffect, useSyncExternalStore } from "react";

// Module-level external store (not React context): ScrollScore mounts once
// inside Hero.tsx (04_HOMEPAGE.md's own homepage-restructure task already
// owns app/(marketing)/page.tsx; 05's FILES ALLOWED doesn't include app/**,
// so useScrollProgress() can't rely on a Context Provider wrapping the other
// 8 sections as siblings under page.tsx). Any component anywhere — cursor
// (06), 3D scene camera (07) — can import this hook regardless of its
// position in the tree.
let progress = 0;
const listeners = new Set<() => void>();

function setProgress(p: number) {
  if (p === progress) return;
  progress = p;
  listeners.forEach((l) => l());
}
function subscribe(listener: () => void) {
  listeners.add(listener);
  return () => listeners.delete(listener);
}
function getSnapshot() {
  return progress;
}
function getServerSnapshot() {
  return 0;
}

/** Scroll progress (0..1) through the homepage's scroll story. */
export function useScrollProgress() {
  return useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot);
}

// Act boundaries (exact, per 05_MOTION_SCROLLSTORY): hero/about/programs sit
// in Act I, benefits/trainer in Act II, voices+gallery/cta in Act III.
const ACT_II_START = 0.45;
const ACT_III_START = 0.72;

function actFor(p: number): 1 | 2 | 3 {
  if (p >= ACT_III_START) return 3;
  if (p >= ACT_II_START) return 2;
  return 1;
}

/**
 * Headless — no visual output. Creates ONE ScrollTrigger for the whole
 * document (scrubbed, not pinned) that publishes scroll progress and toggles
 * `data-act` on <html> for the ambient act-break light shift (globals.css).
 * Coexists with Programs.tsx's own independent pin+scrub ScrollTrigger —
 * that one is scoped to its own section and untouched (05's own instruction:
 * reuse it, don't build a second horizontal-scroll engine).
 */
export default function ScrollScore() {
  useEffect(() => {
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    const noMotion = new URLSearchParams(window.location.search).get("no-motion") === "1";
    if (reduce || noMotion) return; // nothing mounts — sections stay statically readable

    let cancelled = false;
    let cleanup = () => {};

    const start = () => {
      import("gsap").then(({ gsap }) =>
        import("gsap/ScrollTrigger").then(({ ScrollTrigger }) => {
          if (cancelled) return;
          gsap.registerPlugin(ScrollTrigger);

          const st = ScrollTrigger.create({
            trigger: document.body,
            start: "top top",
            end: "bottom bottom",
            scrub: 0.3,
            onUpdate: (self) => {
              setProgress(self.progress);
              document.documentElement.setAttribute("data-act", String(actFor(self.progress)));
            },
          });

          cleanup = () => {
            st.kill();
            document.documentElement.removeAttribute("data-act");
          };
        })
      ).catch((err) => console.warn("[ScrollScore] skipped:", err));
    };

    const w = window as Window & {
      requestIdleCallback?: (cb: () => void, opts?: { timeout: number }) => number;
      cancelIdleCallback?: (id: number) => void;
    };
    const ric = w.requestIdleCallback ? w.requestIdleCallback(start, { timeout: 2000 }) : window.setTimeout(start, 1000);

    return () => {
      cancelled = true;
      if (w.cancelIdleCallback) w.cancelIdleCallback(ric);
      else clearTimeout(ric);
      cleanup();
      // Reset on unmount (navigating off the homepage) — progress is a plain
      // module-level value, not tied to the client-side route, so without
      // this it would keep reporting whatever the last homepage scroll
      // position was. 06_YOGA_CURSOR.md's cursor holds pose 1 on non-home
      // routes specifically because this resets to 0.
      setProgress(0);
    };
  }, []);

  return null;
}
