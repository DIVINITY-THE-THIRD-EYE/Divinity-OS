"use client";

import Reveal from "./Reveal";
import { method } from "@/lib/content";

export default function Method() {
  return (
    <section className="bg-bone px-6 py-28 text-ink md:px-10 md:py-40">
      <div className="mx-auto max-w-6xl">
        <Reveal className="mb-20 max-w-3xl">
          <p className="eyebrow mb-6 text-ember-deep">The path</p>
          <h2 className="font-display text-[clamp(38px,5.5vw,78px)] font-light leading-[0.98] tracking-tight">
            Three movements toward <em className="text-ember-deep">stillness.</em>
          </h2>
        </Reveal>

        <div>
          {method.map((m, i) => (
            <Reveal key={m.step} delay={i * 0.05}>
              <div className="group grid grid-cols-1 items-start gap-6 border-t border-[var(--line-light)] py-11 transition-[padding] duration-500 last:border-b hover:md:pl-6 md:grid-cols-[110px_1fr_minmax(0,380px)] md:gap-12">
                <span className="font-mono text-[11px] uppercase tracking-wide text-ember-deep md:pt-4">
                  Stage {m.step}
                </span>
                <h3 className="font-display text-[clamp(34px,4.5vw,58px)] font-light leading-none tracking-tight">
                  {m.name}
                </h3>
                <p className="font-body text-[15px] leading-[1.85] text-ink-mute">
                  {m.body}
                </p>
              </div>
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  );
}
