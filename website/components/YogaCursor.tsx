"use client";

import { useEffect, useRef, useState } from "react";
import { useScrollProgress } from "./home/ScrollScore";
import { CURSOR_POSES } from "./cursor-poses";

/**
 * Replaces the dot+ring Cursor with a single SVG silhouette that steps
 * through the 12 Surya Namaskar poses as the user scrolls the homepage (via
 * useScrollProgress() from 05). On any other route — or before ScrollScore
 * has mounted — progress is 0, so it holds pose 1 (Pranamasana).
 *
 * FALLBACK (see cursor-poses.ts + DECISIONS.md): poses crossfade instead of
 * numerically morphing — hand-authoring 12 paths with an identical point
 * count wasn't reliable to do by hand, and the task file's own escape hatch
 * anticipates exactly this.
 */
export default function YogaCursor() {
  const wrapRef = useRef<HTMLDivElement>(null);
  const [enabled, setEnabled] = useState(false);
  const [grown, setGrown] = useState(false);
  const progress = useScrollProgress();

  useEffect(() => {
    const fine = window.matchMedia("(hover: hover) and (pointer: fine)");
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)");
    const update = () => setEnabled(fine.matches && !reduce.matches);
    update();
    fine.addEventListener("change", update);
    reduce.addEventListener("change", update);
    return () => {
      fine.removeEventListener("change", update);
      reduce.removeEventListener("change", update);
    };
  }, []);

  // Position + hover-grow: same lerp-follow mechanics as the old Cursor.tsx,
  // one rAF loop total (morph itself is just picking an index — cheap, done
  // via React state below, not per-frame work).
  useEffect(() => {
    if (!enabled) return;
    document.body.classList.add("has-custom-cursor");

    let mx = 0, my = 0, rx = 0, ry = 0, raf = 0;
    const move = (e: MouseEvent) => {
      mx = e.clientX;
      my = e.clientY;
    };
    const grow = (e: Event) => {
      if (!(e.target as HTMLElement).closest("a, button, [data-hover]")) return;
      setGrown(true);
    };
    const shrink = (e: Event) => {
      if (!(e.target as HTMLElement).closest("a, button, [data-hover]")) return;
      setGrown(false);
    };
    const loop = () => {
      rx += (mx - rx) * 0.16;
      ry += (my - ry) * 0.16;
      if (wrapRef.current) wrapRef.current.style.transform = `translate(${rx}px, ${ry}px)`;
      raf = requestAnimationFrame(loop);
    };
    loop();

    window.addEventListener("mousemove", move);
    document.addEventListener("mouseover", grow);
    document.addEventListener("mouseout", shrink);
    return () => {
      cancelAnimationFrame(raf);
      window.removeEventListener("mousemove", move);
      document.removeEventListener("mouseover", grow);
      document.removeEventListener("mouseout", shrink);
      document.body.classList.remove("has-custom-cursor");
    };
  }, [enabled]);

  if (!enabled) return null;

  const poseIndex = Math.min(
    CURSOR_POSES.length - 1,
    Math.max(0, Math.floor(progress * (CURSOR_POSES.length - 1)))
  );
  const size = grown ? 40 : 28;

  return (
    <div
      ref={wrapRef}
      aria-hidden
      className="pointer-events-none fixed left-0 top-0 z-[9999] -translate-x-1/2 -translate-y-1/2 mix-blend-difference"
    >
      <svg
        viewBox="0 0 100 100"
        width={size}
        height={size}
        className="transition-[width,height] duration-300 ease-out"
      >
        {CURSOR_POSES.map((pose, i) => (
          <g
            key={pose.name}
            style={{ opacity: i === poseIndex ? 1 : 0, transition: "opacity 120ms linear" }}
          >
            <circle
              cx={pose.head.cx}
              cy={pose.head.cy}
              r={pose.head.r}
              fill="none"
              stroke={grown ? "var(--ember-pale)" : "var(--ember)"}
              strokeWidth={3}
            />
            <path
              d={pose.body}
              fill="none"
              stroke={grown ? "var(--ember-pale)" : "var(--ember)"}
              strokeWidth={3}
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </g>
        ))}
      </svg>
    </div>
  );
}
