"use client";

import Link from "next/link";
import { m } from "framer-motion";
import { introOffer } from "@/content/offers";
import Magnetic from "@/components/Magnetic";
import ScrollScore from "./ScrollScore";
import SilhouetteTier from "@/components/scene/SilhouetteTier";
import { useBreathPhase } from "@/components/scene/useBreathClock";

export default function Hero() {
  const phase = useBreathPhase();

  return (
    <>
    <ScrollScore />
    <section
      id="top"
      className="relative h-[100svh] min-h-[640px] w-full overflow-hidden"
      // The backdrop below is a fixed dark/amber gradient — it never
      // participates in the day/night toggle (D001's cinematic hero stays
      // dark regardless). text-bone/text-mist DO flip per theme (they're
      // designed for sections whose background also flips), so left alone
      // they'd render dark-on-dark in day mode. Pinning them to their night
      // values here, scoped to just this section, keeps the hero legible
      // regardless of the global theme. Found via Playwright screenshot
      // during 07's SilhouetteTier work — a pre-existing bug, not one this
      // task introduced (light theme's own text never rendered here before).
      style={
        {
          // Tailwind's text-bone/text-mist resolve through the -rgb channel
          // vars (see tailwind.config.ts withOpacity()), not the hex vars —
          // both need pinning for this to actually take effect.
          "--bone": "#ece7db",
          "--bone-rgb": "236 231 219",
          "--mist": "#8e93a6",
          "--mist-rgb": "142 147 166",
        } as React.CSSProperties
      }
    >
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

      <SilhouetteTier />

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
          <Magnetic>
            <Link
              href="/contact"
              className="bg-ember px-8 py-3.5 font-mono text-[11px] uppercase tracking-wide text-void transition-colors hover:bg-ember-pale"
            >
              Book a class — {introOffer.price} {introOffer.duration}
            </Link>
          </Magnetic>
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
    </>
  );
}
