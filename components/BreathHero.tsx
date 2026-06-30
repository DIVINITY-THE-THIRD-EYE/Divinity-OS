"use client";

import { useEffect, useRef, useState } from "react";
import Link from "next/link";
import { m } from "framer-motion";

// Pranayama cadence (seconds): sama-style with a longer exhale.
const INHALE = 4;
const HOLD = 4;
const EXHALE = 6;
const CYCLE = INHALE + HOLD + EXHALE;

type Phase = { label: string; remaining: number; breath: number };

// returns breath fullness 0..1 and the current phase
function breathAt(tSec: number): Phase {
  const t = tSec % CYCLE;
  const easeInOut = (x: number) => 0.5 - 0.5 * Math.cos(Math.PI * x);
  if (t < INHALE) {
    return { label: "Inhale", remaining: INHALE - t, breath: easeInOut(t / INHALE) };
  }
  if (t < INHALE + HOLD) {
    return { label: "Hold", remaining: INHALE + HOLD - t, breath: 1 };
  }
  const e = (t - INHALE - HOLD) / EXHALE;
  return { label: "Exhale", remaining: CYCLE - t, breath: 1 - easeInOut(e) };
}

export default function BreathHero() {
  const canvas = useRef<HTMLCanvasElement>(null);
  const [phase, setPhase] = useState<Phase>({ label: "Inhale", remaining: 4, breath: 0 });

  useEffect(() => {
    const c = canvas.current;
    if (!c) return;
    const ctx = c.getContext("2d");
    if (!ctx) return;

    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    let dpr = Math.min(window.devicePixelRatio || 1, 2);
    let W = 0,
      H = 0;

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

    // ambient embers
    const embers = Array.from({ length: 46 }, () => ({
      a: Math.random() * Math.PI * 2,
      rad: 80 + Math.random() * 260,
      sp: (Math.random() - 0.5) * 0.0016,
      o: Math.random() * 0.5 + 0.1,
      sz: Math.random() * 1.6 + 0.4,
    }));

    const start = performance.now();
    let raf = 0;
    let inView = true;
    const shouldRun = () => !reduce && inView && !document.hidden;

    const draw = (now: number) => {
      const tSec = (now - start) / 1000;
      const p = reduce ? { label: "Breathe", remaining: 0, breath: 0.6 } : breathAt(tSec);

      // update the readout a few times a second
      if (Math.floor(tSec * 4) !== Math.floor(((now - start - 16) / 1000) * 4)) {
        setPhase(p);
      }

      const cx = W * (W > 760 ? 0.5 : 0.5);
      const cy = H * 0.46;
      const base = Math.min(W, H) * 0.16;
      const r = base * (0.78 + p.breath * 0.5); // expands on inhale

      ctx.clearRect(0, 0, W, H);

      // dawn glow behind the form
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

      // core orb
      const orb = ctx.createRadialGradient(cx, cy, 0, cx, cy, r);
      orb.addColorStop(0, `rgba(232,196,144,${0.30 + p.breath * 0.22})`);
      orb.addColorStop(0.6, `rgba(208,138,62,${0.10 + p.breath * 0.12})`);
      orb.addColorStop(1, "rgba(208,138,62,0)");
      ctx.beginPath();
      ctx.arc(cx, cy, r, 0, Math.PI * 2);
      ctx.fillStyle = orb;
      ctx.fill();

      // thin core outline
      ctx.beginPath();
      ctx.arc(cx, cy, r * 0.62, 0, Math.PI * 2);
      ctx.strokeStyle = `rgba(232,196,144,${0.35 + p.breath * 0.25})`;
      ctx.lineWidth = 1;
      ctx.stroke();

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
      draw(performance.now()); // single static frame
    } else {
      raf = requestAnimationFrame(draw);

      // Stop rendering when the hero is off-screen or the tab is hidden — the
      // canvas otherwise runs at 60fps forever, wasting CPU and battery.
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

  return (
    <section id="top" className="relative h-[100svh] min-h-[640px] w-full overflow-hidden">
      {/* warm-studio backdrop — pure CSS so the LCP isn't gated on a
          full-viewport image decode (the photo sat at 0.28 opacity under
          these gradients anyway). Evokes the lamp-lit amber studio tone. */}
      <div className="absolute inset-0" aria-hidden>
        <div
          className="absolute inset-0"
          style={{
            background:
              "radial-gradient(90% 70% at 50% 16%, rgba(208,138,62,0.16), transparent 58%), radial-gradient(70% 55% at 80% 6%, rgba(232,196,144,0.10), transparent 60%), linear-gradient(160deg, #20212b 0%, #1a1b23 46%, #15161e 100%)",
          }}
        />
        <div
          className="absolute inset-0"
          style={{
            background:
              "radial-gradient(58% 55% at 50% 46%, rgba(21,22,30,0.55), transparent 64%), linear-gradient(to bottom, rgba(21,22,30,0.4), rgba(21,22,30,0.22) 42%, rgba(21,22,30,0.92))",
          }}
        />
      </div>

      <canvas ref={canvas} className="absolute inset-0 h-full w-full" aria-hidden />

      {/* editorial type */}
      <div className="relative z-10 mx-auto flex h-full max-w-[1400px] flex-col justify-center px-6 md:px-10">
        <m.p
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.1 }}
          className="eyebrow mb-7 text-ember"
        >
          Yoga · Fitness · Wellness — Lucknow
        </m.p>

        {/* Transform-only entrance (opacity stays 1) so the LCP heading is
            painted at first contentful paint, not after the animation. */}
        <h1 className="font-display font-light leading-[0.86] tracking-tight text-bone">
          <m.span
            initial={{ y: 26 }}
            animate={{ y: 0 }}
            transition={{ duration: 0.7, delay: 0.05, ease: [0.22, 1, 0.36, 1] }}
            className="block text-[clamp(72px,16vw,210px)] italic text-ember"
          >
            Breathe
          </m.span>
          <m.span
            initial={{ y: 26 }}
            animate={{ y: 0 }}
            transition={{ duration: 0.7, delay: 0.12, ease: [0.22, 1, 0.36, 1] }}
            className="block pl-[0.06em] text-[clamp(40px,8vw,104px)]"
          >
            your way inward.
          </m.span>
        </h1>

        <m.p
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.3 }}
          className="mt-8 max-w-md font-body text-base leading-relaxed text-mist"
        >
          A yoga, fitness and wellness academy guiding body and mind toward
          balance — one breath at a time.
        </m.p>

        <m.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.4, ease: [0.22, 1, 0.36, 1] }}
          className="mt-10 flex flex-wrap items-center gap-4"
        >
          <Link
            href="/contact"
            className="bg-ember px-8 py-3.5 font-mono text-[11px] uppercase tracking-wide text-void transition-colors hover:bg-ember-pale"
          >
            Book a class — ₹99 first week
          </Link>
          <a
            href="#about"
            className="font-mono text-[11px] uppercase tracking-wide text-mist transition-colors hover:text-bone"
          >
            Learn more ↓
          </a>
        </m.div>
      </div>

      {/* breath guide readout */}
      <m.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 1.2, delay: 1.1 }}
        className="absolute bottom-8 left-1/2 z-10 flex -translate-x-1/2 items-center gap-4 font-mono text-[11px] uppercase tracking-wide text-mist"
      >
        <span className="text-ember">{phase.label}</span>
        <span className="h-3 w-px bg-[var(--line-dark)]" />
        <span>inhale 4 · hold 4 · exhale 6</span>
      </m.div>

      {/* scroll cue */}
      <div className="absolute bottom-8 right-6 z-10 hidden items-center gap-2 font-mono text-[10px] uppercase tracking-wide text-mist md:right-10 md:flex">
        Scroll <span className="inline-block h-8 w-px bg-gradient-to-b from-ember to-transparent" />
      </div>
    </section>
  );
}
