"use client";

import { useEffect, useRef } from "react";
import { getBreath } from "./useBreathClock";

// The hero mark. Formerly a hand-authored seated-meditation silhouette (the
// "living anatomy" figure); replaced with the brand logo mark (no wordmark)
// per owner request. This IS the shipped hero visual (D007: "LCP frame = DOM
// H1 + SilhouetteTier") — what every visitor sees, breathing gently on the
// shared breath clock. The surrounding glow/rings/orb/embers are ambient, not
// the figure, and are kept as-is.
const LOGO_SRC = "/brand/logo-mark.png";

export default function SilhouetteTier() {
  const canvas = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const c = canvas.current;
    if (!c) return;
    const ctx = c.getContext("2d");
    if (!ctx) return;

    // Logo mark, drawn onto the canvas once loaded. Browser-only (like the
    // old Path2D), so it's constructed inside this client effect. reduce-motion
    // draws a single static frame, so redraw on load; otherwise kick the loop.
    const logo = new Image();
    let logoReady = false;
    logo.onload = () => {
      logoReady = true;
      if (reduce) draw();
      else kick();
    };
    logo.src = LOGO_SRC;

    let dpr = Math.min(window.devicePixelRatio || 1, 2);
    let W = 0, H = 0;

    const resize = () => {
      dpr = Math.min(window.devicePixelRatio || 1, 2);
      W = c.clientWidth;
      H = c.clientHeight;
      c.width = W * dpr;
      c.height = H * dpr;
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    };
    resize();
    window.addEventListener("resize", resize);

    // ambient embers (unchanged from the old BreathHero)
    const embers = Array.from({ length: 46 }, () => ({
      a: Math.random() * Math.PI * 2,
      rad: 80 + Math.random() * 260,
      sp: (Math.random() - 0.5) * 0.0016,
      o: Math.random() * 0.5 + 0.1,
      sz: Math.random() * 1.6 + 0.4,
    }));

    let raf = 0;
    let inView = true;
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    const shouldRun = () => !reduce && inView && !document.hidden;

    const draw = () => {
      const p = getBreath();
      const cx = W * 0.5;
      const cy = H * 0.46;
      const base = Math.min(W, H) * 0.16;
      const r = base * (0.78 + p.breath * 0.5);

      ctx.clearRect(0, 0, W, H);

      // dawn glow behind the figure
      const glow = ctx.createRadialGradient(cx, cy, 0, cx, cy, r * 4.2);
      glow.addColorStop(0, `rgba(208,138,62,${0.10 + p.breath * 0.10})`);
      glow.addColorStop(0.4, "rgba(168,94,42,0.05)");
      glow.addColorStop(1, "rgba(21,22,30,0)");
      ctx.fillStyle = glow;
      ctx.fillRect(cx - r * 4.2, cy - r * 4.2, r * 8.4, r * 8.4);

      // concentric breath rings
      for (let i = 0; i < 5; i++) {
        const rr = r * (1 + i * 0.42 + p.breath * 0.12 * i);
        ctx.beginPath();
        ctx.arc(cx, cy, rr, 0, Math.PI * 2);
        ctx.strokeStyle = `rgba(208,138,62,${(0.22 - i * 0.04) * (0.5 + p.breath * 0.5)})`;
        ctx.lineWidth = 1;
        ctx.stroke();
      }

      // Brand mark — centered, breathing gently on the same clock the old
      // silhouette used (scale pulse around its own center). Drawn square
      // (logo-mark is 600×600); slightly translucent so the hero copy stays
      // legible where the text column and this centered mark overlap on
      // narrower viewports.
      if (logoReady) {
        const size = base * 1.7 * (1 + p.breath * 0.03);
        ctx.save();
        ctx.globalAlpha = 0.9 + p.breath * 0.1;
        ctx.drawImage(logo, cx - size / 2, cy - size / 2, size, size);
        ctx.restore();
      }

      // core orb (the "third eye" glow at the chest/throat)
      const orb = ctx.createRadialGradient(cx, cy, 0, cx, cy, r * 0.5);
      orb.addColorStop(0, `rgba(232,196,144,${0.30 + p.breath * 0.22})`);
      orb.addColorStop(0.6, `rgba(208,138,62,${0.10 + p.breath * 0.12})`);
      orb.addColorStop(1, "rgba(208,138,62,0)");
      ctx.beginPath();
      ctx.arc(cx, cy, r * 0.5, 0, Math.PI * 2);
      ctx.fillStyle = orb;
      ctx.fill();

      // embers drift; outward with breath
      embers.forEach((e) => {
        if (!reduce) e.a += e.sp;
        const er = e.rad * (0.7 + p.breath * 0.45);
        const px = cx + Math.cos(e.a) * er;
        const py = cy + Math.sin(e.a) * er * 0.9;
        ctx.beginPath();
        ctx.arc(px, py, e.sz, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(208,138,62,${e.o * (0.4 + p.breath * 0.6)})`;
        ctx.fill();
      });

      if (shouldRun()) raf = requestAnimationFrame(draw);
      else raf = 0;
    };

    const kick = () => {
      if (raf === 0 && shouldRun()) raf = requestAnimationFrame(draw);
    };
    const pause = () => {
      cancelAnimationFrame(raf);
      raf = 0;
    };

    let io: IntersectionObserver | null = null;
    let onVisibility: (() => void) | null = null;

    if (reduce) {
      draw(); // single static frame
    } else {
      raf = requestAnimationFrame(draw);
      io = new IntersectionObserver(
        ([e]) => {
          inView = e.isIntersecting;
          if (inView && !document.hidden) kick();
          else pause();
        },
        { threshold: 0 }
      );
      io.observe(c);
      onVisibility = () => (document.hidden ? pause() : kick());
      document.addEventListener("visibilitychange", onVisibility);
    }

    return () => {
      pause();
      window.removeEventListener("resize", resize);
      io?.disconnect();
      if (onVisibility) document.removeEventListener("visibilitychange", onVisibility);
    };
  }, []);

  return <canvas ref={canvas} className="absolute inset-0 h-full w-full" aria-hidden />;
}
