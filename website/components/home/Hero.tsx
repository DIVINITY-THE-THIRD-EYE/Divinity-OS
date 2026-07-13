"use client";

import Image from "next/image";
import { m } from "framer-motion";
import { introOffer } from "@/content/offers";
import CtaLink from "@/components/ui/CtaLink";

/**
 * Clay hero: light canvas (blobs live in <Ambient/>), a Nunito display
 * headline with a gradient accent phrase, clay CTAs, and the brand logo mark
 * suspended in a nested-depth clay orb (extruded ring → inset well → floating
 * amber mark) — the "complex nested depth" signature of the system. The mark
 * is the amber brand logo, kept as the secondary accent against the violet UI.
 */
export default function Hero() {
  return (
    <section
      id="top"
      className="relative flex min-h-[92svh] w-full items-center overflow-hidden px-6 py-24 md:px-10"
    >
      <div className="mx-auto grid w-full max-w-7xl items-center gap-14 lg:grid-cols-[1.05fr_0.95fr]">
        {/* copy */}
        <div>
          <m.p
            initial={{ opacity: 0, y: 16 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="eyebrow mb-7 inline-block rounded-full bg-[var(--void)] px-4 py-2 text-accent shadow-clay-inset-sm"
          >
            Yoga · Fitness · Wellness — Lucknow
          </m.p>

          <h1 className="font-display text-5xl font-black leading-[1.04] tracking-tight text-fg sm:text-6xl md:text-7xl">
            Breathe{" "}
            <span className="clay-text-gradient">your way</span> inward.
          </h1>

          <p className="mt-7 max-w-md text-lg font-medium leading-relaxed text-fg-muted">
            A yoga, fitness and wellness academy guiding body and mind toward
            balance — one breath at a time.
          </p>

          <div className="mt-10 flex flex-col gap-4 sm:flex-row sm:items-center">
            <CtaLink href="/contact">
              Book a class — {introOffer.price} {introOffer.duration}
            </CtaLink>
            <CtaLink href="/schedule" variant="outline">
              See the schedule
            </CtaLink>
          </div>

          {/* breath guide — recessed clay pill */}
          <div className="mt-10 inline-flex items-center gap-3 rounded-2xl bg-[var(--void)] px-5 py-3 text-sm font-semibold text-fg-muted shadow-clay-pressed">
            <span className="clay-breathe h-2.5 w-2.5 rounded-full bg-accent" />
            inhale 4 · hold 4 · exhale 6
          </div>
        </div>

        {/* logo orb — nested clay depth */}
        <m.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.7, ease: [0.22, 1, 0.36, 1] }}
          className="relative mx-auto grid aspect-square w-full max-w-xs place-items-center sm:max-w-sm lg:max-w-md"
        >
          <div className="clay-breathe grid h-[86%] w-[86%] place-items-center rounded-full bg-[var(--void)] shadow-clay-card">
            <div className="grid h-[74%] w-[74%] place-items-center rounded-full bg-[var(--void)] shadow-clay-inset">
              <Image
                src="/brand/logo-mark.png"
                alt="Divinity — The Third Eye"
                width={240}
                height={240}
                priority
                className="clay-float h-[64%] w-[64%] object-contain"
              />
            </div>
          </div>
        </m.div>
      </div>
    </section>
  );
}
