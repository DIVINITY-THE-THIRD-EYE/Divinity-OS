"use client";

import Image from "next/image";
import Reveal from "./Reveal";
import { site } from "@/lib/content";

export default function About({ site: siteProp }: { site?: typeof site }) {
  const activeSite = siteProp || site;
  return (
    <section id="about" className="relative overflow-hidden bg-deep px-6 py-28 text-ink md:px-10 md:py-40">
      {/* faint Devanagari watermark — आज्ञा (Ajna, the third eye). Rendered as
          pseudo-content (see .watermark) so it stays out of contrast checks. */}
      <span
        aria-hidden
        data-watermark="आज्ञा"
        className="watermark pointer-events-none absolute -right-4 -top-10 select-none font-display text-[clamp(180px,30vw,460px)] italic leading-none text-ink/[0.04]"
      />

      <div className="relative mx-auto grid max-w-6xl gap-16 md:grid-cols-2 md:gap-20">
        <Reveal className="md:pt-10">
          <p className="eyebrow mb-7 text-ember-deep">The academy</p>
          <h2 className="font-display text-[clamp(38px,5.5vw,78px)] font-light leading-[0.98] tracking-tight">
            The space between
            <br />
            the <em className="text-ember-deep">brows.</em>
          </h2>

          {/* Founder portrait */}
          <div className="relative mt-12 max-w-sm">
            <div className="overflow-hidden border border-[var(--line-light)]">
              <Image
                src={activeSite.founderImage}
                alt={`${activeSite.founder}, ${activeSite.founderRole} of ${activeSite.full}`}
                width={860}
                height={1571}
                sizes="(max-width: 768px) 90vw, 380px"
                className="h-auto w-full object-cover"
              />
            </div>
            <div className="absolute -bottom-4 left-4 bg-deep px-4 py-2.5 shadow-sm ring-1 ring-[var(--line-light)]">
              <span className="block font-display text-lg italic leading-none text-ink">
                {activeSite.founder}
              </span>
              <span className="font-mono text-[10px] uppercase tracking-wide text-ink-mute">
                {activeSite.founderRole}
              </span>
            </div>
          </div>
        </Reveal>

        <div className="flex flex-col justify-end">
          <Reveal delay={0.1}>
            <p className="mb-6 max-w-md font-body text-[17px] leading-[1.85] text-ink-mute">
              The Ajna — the third eye — is the seat of intuition and inner
              sight. {activeSite.full} is built on that idea: a place where the
              physical and the formless meet, where movement becomes meditation.
            </p>
            <p className="max-w-md font-body text-[17px] leading-[1.85] text-ink-mute">
              Here in {activeSite.city} we guide each student through yoga, breath,
              fitness and mindful living — meeting you where you are, and walking
              with you toward where you wish to be.
            </p>
          </Reveal>

          <Reveal delay={0.2}>
            <div className="mt-9 flex items-center gap-4 border-t border-[var(--line-light)] pt-6">
              <span className="flex h-12 w-12 items-center justify-center rounded-full border border-[var(--line-light)] font-display text-xl text-ember-deep">
                ॐ
              </span>
              <span>
                <span className="block font-display text-2xl italic">
                  Est. {activeSite.est}
                </span>
                <span className="font-mono text-[10px] uppercase tracking-wide text-ink-mute">
                  {activeSite.city}
                </span>
              </span>
            </div>
          </Reveal>
        </div>
      </div>
    </section>
  );
}
