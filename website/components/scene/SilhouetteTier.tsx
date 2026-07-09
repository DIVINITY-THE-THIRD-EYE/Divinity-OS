"use client";

import { useEffect, useRef } from "react";
import { getBreath } from "./useBreathClock";

// Seated meditation silhouette, hand-authored as two closed sub-paths (head +
// torso/crossed-legs), normalized to a 200×220 box. Drawn via Path2D onto the
// hero canvas — this IS the shipped hero visual (D007: "LCP frame = DOM H1 +
// SilhouetteTier"), not a placeholder; it's also what every non-3D-capable
// visitor (mobile, coarse pointer, reduced motion, no WebGL2, low memory,
// save-data) sees permanently, and what desktop users see for the brief
// window before the 3D chunk (07's Scene, not yet built — see DECISIONS.md/
// PLACEHOLDERS.md) loads in.
// Path2D is a browser-only API — even in a "use client" component, this
// module is still evaluated on the server during prerendering (Next.js needs
// it to render the initial HTML), so constructing Path2D at module scope
// crashed the build with "Path2D is not defined". Kept as plain strings here;
// instantiated lazily inside the client-only effect below.
const HEAD_D =
  "M100,8 C88,8 78,18 78,32 C78,46 88,55 100,55 C112,55 122,46 122,32 C122,18 112,8 100,8 Z";
const BODY_D =
  "M65,60 C55,75 45,100 40,130 C38,145 35,150 22,160 C15,168 15,180 25,192 " +
  "C45,205 75,205 100,195 C125,205 155,205 175,192 C185,180 185,168 178,160 " +
  "C165,150 162,145 160,130 C155,100 145,75 135,60 C125,52 112,50 100,52 C88,50 75,52 65,60 Z";
const FIGURE_BOX = { w: 200, h: 220, chestX: 100, chestY: 70 };

export default function SilhouetteTier() {
  const canvas = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const c = canvas.current;
    if (!c) return;
    const ctx = c.getContext("2d");
    if (!ctx) return;

    const HEAD_PATH = new Path2D(HEAD_D);
    const BODY_PATH = new Path2D(BODY_D);

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

      // Seated silhouette — a soft translucent presence, not a hard opaque
      // shape (copy must stay legible wherever it happens to overlap; on
      // narrower viewports the hero text column and this centered figure
      // occupy the same screen region). Scaled gently around the chest point
      // on the breath (a coarse stand-in for the full 3D Figure's per-vertex
      // chest displacement; this tier is deliberately ~3kB, not a shader).
      const scale = (base * 0.9) / FIGURE_BOX.w;
      const breathScale = 1 + p.breath * 0.03;
      ctx.save();
      ctx.translate(cx, cy + base * 0.7);
      ctx.scale(scale * breathScale, scale * breathScale);
      ctx.translate(-FIGURE_BOX.chestX, -FIGURE_BOX.chestY);
      ctx.fillStyle = `rgba(21,22,30,${0.22 + p.breath * 0.08})`;
      ctx.fill(HEAD_PATH);
      ctx.fill(BODY_PATH);
      ctx.strokeStyle = `rgba(232,196,144,${0.3 + p.breath * 0.25})`;
      ctx.lineWidth = 1.4 / (scale * breathScale);
      ctx.stroke(HEAD_PATH);
      ctx.stroke(BODY_PATH);
      ctx.restore();

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
