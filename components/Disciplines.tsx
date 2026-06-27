"use client";

import { useEffect, useRef } from "react";
import type { Discipline } from "@/lib/content";

export default function Disciplines({ items }: { items: Discipline[] }) {
  const section = useRef<HTMLDivElement>(null);
  const track = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    if (reduce) return;

    // Dynamic import keeps GSAP off the critical render path (mobile LCP fix)
    import("gsap").then(({ gsap }) =>
      import("gsap/ScrollTrigger").then(({ ScrollTrigger }) => {
        gsap.registerPlugin(ScrollTrigger);
        const mm = gsap.matchMedia();

        mm.add("(min-width: 900px)", () => {
          const t = track.current!;
          const s = section.current!;
          const distance = () => t.scrollWidth - window.innerWidth;

          const tween = gsap.to(t, {
            x: () => -distance(),
            ease: "none",
            scrollTrigger: {
              trigger: s,
              start: "top top",
              end: () => "+=" + distance(),
              scrub: 1,
              pin: true,
              anticipatePin: 1,
              invalidateOnRefresh: true,
            },
          });
          return () => tween.kill();
        });

        return () => mm.revert();
      })
    );
  }, []);

  return (
    <section
      id="disciplines"
      ref={section}
      className="bg-void md:h-screen md:overflow-hidden"
    >
      <div className="flex items-center justify-between px-6 pb-2 pt-28 md:px-10 md:pt-10">
        <p className="eyebrow text-ember">What we practice</p>
        <p className="hidden font-mono text-[11px] tracking-wide text-mist md:block">
          Six paths · scroll
        </p>
      </div>

      <div
        ref={track}
        className="flex flex-col gap-6 px-6 pb-24 md:h-[calc(100vh-120px)] md:flex-row md:items-center md:gap-0 md:px-10 md:pb-0"
      >
        {items.map((d, i) => (
          <article
            key={i}
            className="group flex w-full shrink-0 flex-col justify-between border-t border-[var(--line-dark)] py-8 md:mr-8 md:h-[64%] md:w-[440px] md:border-l md:border-t-0 md:py-0 md:pl-10"
          >
            <div>
              <p className="eyebrow mb-8 text-ember/80">{d.intention}</p>
              <h3 className="font-display text-[clamp(32px,4.4vw,56px)] font-light leading-[1.02] tracking-tight text-bone">
                {d.title}
              </h3>
            </div>
            <div>
              <p className="mt-6 max-w-sm font-body text-[15px] leading-[1.8] text-mist">
                {d.description}
              </p>
              <div className="mt-7 flex flex-wrap gap-2">
                {d.tags.map((t) => (
                  <span
                    key={t}
                    className="border border-[var(--line-dark)] px-3 py-1.5 font-mono text-[9px] uppercase tracking-wide text-ember"
                  >
                    {t}
                  </span>
                ))}
              </div>
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}
