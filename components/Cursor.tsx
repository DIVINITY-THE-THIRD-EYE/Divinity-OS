"use client";

import { useEffect, useRef } from "react";

export default function Cursor() {
  const dot = useRef<HTMLDivElement>(null);
  const ring = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const fine = window.matchMedia("(hover: hover) and (pointer: fine)").matches;
    if (!fine) return;

    let mx = 0,
      my = 0,
      rx = 0,
      ry = 0,
      raf = 0;

    const move = (e: MouseEvent) => {
      mx = e.clientX;
      my = e.clientY;
      if (dot.current) {
        dot.current.style.transform = `translate(${mx}px, ${my}px)`;
      }
    };
    const grow = (e: Event) => {
      if (!(e.target as HTMLElement).closest("a, button, [data-hover]")) return;
      ring.current?.style.setProperty("--s", "2.6");
    };
    const shrink = (e: Event) => {
      if (!(e.target as HTMLElement).closest("a, button, [data-hover]")) return;
      ring.current?.style.setProperty("--s", "1");
    };

    const loop = () => {
      rx += (mx - rx) * 0.16;
      ry += (my - ry) * 0.16;
      if (ring.current) ring.current.style.transform = `translate(${rx}px, ${ry}px)`;
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
    };
  }, []);

  return (
    <>
      <div
        ref={dot}
        aria-hidden
        className="pointer-events-none fixed left-0 top-0 z-[9999] hidden h-1.5 w-1.5 -translate-x-1/2 -translate-y-1/2 rounded-full bg-ember mix-blend-difference md:block"
        style={{ marginLeft: "-3px", marginTop: "-3px" }}
      />
      <div
        ref={ring}
        aria-hidden
        className="pointer-events-none fixed left-0 top-0 z-[9998] hidden h-9 w-9 rounded-full border border-ember/50 mix-blend-difference md:block"
        style={{
          marginLeft: "-18px",
          marginTop: "-18px",
          // @ts-expect-error custom prop
          "--s": "1",
          scale: "var(--s)",
          transition: "scale .3s ease",
        }}
      />
    </>
  );
}
