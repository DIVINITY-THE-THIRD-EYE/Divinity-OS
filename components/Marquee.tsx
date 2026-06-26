"use client";

import { useRef } from "react";
import {
  motion,
  useAnimationFrame,
  useMotionValue,
  useScroll,
  useSpring,
  useTransform,
  useVelocity,
} from "framer-motion";
import { mantra } from "@/lib/content";

const wrap = (min: number, max: number, v: number) => {
  const range = max - min;
  return ((((v - min) % range) + range) % range) + min;
};

export default function Marquee() {
  const baseX = useMotionValue(0);
  const { scrollY } = useScroll();
  const scrollVelocity = useVelocity(scrollY);
  const smooth = useSpring(scrollVelocity, { damping: 50, stiffness: 400 });
  const factor = useTransform(smooth, [0, 1000], [0, 4], { clamp: false });
  const skew = useTransform(smooth, [-1500, 0, 1500], [-6, 0, 6], { clamp: true });
  const dir = useRef(1);

  const x = useTransform(baseX, (v) => `${wrap(-50, 0, v)}%`);

  useAnimationFrame((_, delta) => {
    if (
      typeof window !== "undefined" &&
      window.matchMedia("(prefers-reduced-motion: reduce)").matches
    )
      return;
    let move = dir.current * 1.6 * (delta / 1000);
    const f = factor.get();
    if (f < 0) dir.current = -1;
    else if (f > 0) dir.current = 1;
    move += move * Math.abs(f);
    baseX.set(baseX.get() + move);
  });

  const Row = () => (
    <div className="flex shrink-0 items-center">
      {mantra.map((w, i) => (
        <span key={i} className="flex items-center">
          <span className="px-7 font-display text-[clamp(34px,6vw,84px)] font-light italic text-bone/90">
            {w}
          </span>
          <span className="h-1.5 w-1.5 rounded-full bg-ember" />
        </span>
      ))}
    </div>
  );

  return (
    <section className="overflow-hidden border-y border-[var(--line-dark)] bg-deep py-10">
      <motion.div style={{ x, skewX: skew }} className="flex whitespace-nowrap will-change-transform">
        <Row />
        <Row />
      </motion.div>
    </section>
  );
}
