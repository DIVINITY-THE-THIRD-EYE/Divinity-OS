"use client";

import { useRef, useEffect, type ReactNode } from "react";
import { m, useMotionValue, useSpring } from "framer-motion";

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
  const reduceRef = useRef(false);
  const x = useMotionValue(0);
  const y = useMotionValue(0);
  const sx = useSpring(x, { stiffness: 200, damping: 15, mass: 0.4 });
  const sy = useSpring(y, { stiffness: 200, damping: 15, mass: 0.4 });

  useEffect(() => {
    const q = window.matchMedia("(prefers-reduced-motion: reduce)");
    reduceRef.current = q.matches;
    const onChange = (e: MediaQueryListEvent) => {
      reduceRef.current = e.matches;
    };
    q.addEventListener("change", onChange);
    return () => q.removeEventListener("change", onChange);
  }, []);

  function onMove(e: React.MouseEvent) {
    const el = ref.current;
    if (!el) return;
    if (reduceRef.current) return;
    const r = el.getBoundingClientRect();
    x.set((e.clientX - (r.left + r.width / 2)) * strength);
    y.set((e.clientY - (r.top + r.height / 2)) * strength);
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
