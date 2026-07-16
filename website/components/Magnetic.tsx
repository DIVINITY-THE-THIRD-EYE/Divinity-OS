"use client";

import { useRef, useEffect, type ReactNode } from "react";
import { m, useMotionValue, useSpring } from "framer-motion";

const MAX_OFFSET = 8; // px — 05_MOTION_SCROLLSTORY's magnetic-CTA spec

export default function Magnetic({
  children,
  strength = 0.35,
  className = "",
}: {
  children: ReactNode;
  strength?: number;
  className?: string;
}) {
  const ref = useRef<HTMLDivElement>(null);
  const disabledRef = useRef(false);
  const x = useMotionValue(0);
  const y = useMotionValue(0);
  const sx = useSpring(x, { stiffness: 200, damping: 15, mass: 0.4 });
  const sy = useSpring(y, { stiffness: 200, damping: 15, mass: 0.4 });

  useEffect(() => {
    // Coarse pointers (touch) have no hover to drive this, and reduced-motion
    // users don't want the follow effect either.
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)");
    const fine = window.matchMedia("(hover: hover) and (pointer: fine)");
    const update = () => {
      disabledRef.current = reduce.matches || !fine.matches;
    };
    update();
    reduce.addEventListener("change", update);
    fine.addEventListener("change", update);
    return () => {
      reduce.removeEventListener("change", update);
      fine.removeEventListener("change", update);
    };
  }, []);

  function onMove(e: React.MouseEvent) {
    const el = ref.current;
    if (!el) return;
    if (disabledRef.current) return;
    const r = el.getBoundingClientRect();
    const clamp = (v: number) => Math.max(-MAX_OFFSET, Math.min(MAX_OFFSET, v));
    x.set(clamp((e.clientX - (r.left + r.width / 2)) * strength));
    y.set(clamp((e.clientY - (r.top + r.height / 2)) * strength));
  }
  function reset() {
    x.set(0);
    y.set(0);
  }

  return (
    <m.div
      ref={ref}
      onMouseMove={onMove}
      onMouseLeave={reset}
      style={{ x: sx, y: sy }}
      className={`inline-block ${className}`}
      data-hover
    >
      {children}
    </m.div>
  );
}
