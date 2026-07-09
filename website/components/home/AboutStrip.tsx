"use client";

import Image from "next/image";
import Link from "next/link";
import Reveal from "@/components/Reveal";
import { site } from "@/content/site";
import { founder } from "@/content/founder";
import { manifestoLines } from "@/content/marketing";

/** Act I, section 2 — short manifesto + founder pull-quote. Full story lives at /about. */
export default function AboutStrip() {
  return (
    <section
      id="about"
      aria-labelledby="about-strip-heading"
      className="relative overflow-hidden bg-bone px-6 py-28 text-ink md:px-10 md:py-40"
    >
      <div className="mx-auto grid max-w-5xl gap-14 md:grid-cols-[1fr_1.2fr] md:items-center">
        <Reveal>
          <div className="relative aspect-[3/4] w-full max-w-sm overflow-hidden">
            <Image
              src={founder.image}
              alt={`${founder.name}, ${founder.title} of ${site.full}`}
              fill
              sizes="(max-width: 768px) 90vw, 400px"
              className="object-cover grayscale-[0.1]"
            />
          </div>
        </Reveal>

        <Reveal delay={0.1}>
          <p className="eyebrow mb-6 text-ember-deep">The academy</p>
          <h2 id="about-strip-heading" className="font-display text-[clamp(32px,4.6vw,56px)] font-light leading-[1.05] tracking-tight">
            {manifestoLines[0]}
            <br />
            <em>{manifestoLines[1]}</em>
          </h2>
          <blockquote className="mt-8 border-l-2 border-ember pl-6 font-display text-xl italic leading-relaxed">
            &ldquo;{founder.bio}&rdquo;
            <footer className="mt-3 font-mono text-[11px] not-italic uppercase tracking-wide text-ink-mute">
              {founder.name} — {founder.title}
            </footer>
          </blockquote>
          <Link
            href="/about"
            data-hover
            className="mt-8 inline-flex items-center gap-2 font-mono text-[11px] uppercase tracking-wide text-ember-deep transition-colors hover:text-clay"
          >
            Read our story →
          </Link>
        </Reveal>
      </div>
    </section>
  );
}
