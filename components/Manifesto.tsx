"use client";

import { useEffect, useRef } from "react";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { manifestoLines } from "@/lib/content";

export default function Manifesto() {
  const root = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    const el = root.current;
    if (!el) return;
    const lines = el.querySelectorAll(".m-line");

    if (reduce) {
      gsap.set(lines, { opacity: 1, y: 0 });
      return;
    }

    gsap.registerPlugin(ScrollTrigger);
    const ctx = gsap.context(() => {
      gsap.set(lines, { opacity: 0.12, y: 18 });
      gsap.to(lines, {
        opacity: 1,
        y: 0,
        stagger: 0.5, // breath-paced
        ease: "power2.out",
        scrollTrigger: { trigger: el, start: "top 70%", end: "bottom 80%", scrub: 1 },
      });
    }, el);
    return () => ctx.revert();
  }, []);

  return (
    <section className="border-t border-[var(--line-dark)] bg-void px-6 py-32 md:px-10 md:py-44">
      <div ref={root} className="mx-auto max-w-4xl">
        <p className="eyebrow mb-12 flex items-center gap-3 text-ember">
          <span className="h-px w-9 bg-ember/50" /> The belief
        </p>
        <div className="font-display text-[clamp(26px,4vw,52px)] font-light leading-[1.25]">
          {manifestoLines.map((line, i) => (
            <span key={i} className="m-line block">
              {line.includes("inward") || line.includes("presence") ? (
                <em className="not-italic text-ember">{line}</em>
              ) : (
                line
              )}
            </span>
          ))}
        </div>
      </div>
    </section>
  );
}
