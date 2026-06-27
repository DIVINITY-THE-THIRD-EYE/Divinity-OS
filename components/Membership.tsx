"use client";

import Image from "next/image";
import Reveal from "./Reveal";
import { payment, type Plan } from "@/lib/content";

export default function Membership({ plans }: { plans: Plan[] }) {
  const featured = plans.find((p) => p.featured) ?? plans[0];
  const rest = plans.filter((p) => p !== featured);

  return (
    <section id="membership" className="bg-bone px-6 py-28 text-ink md:px-10 md:py-40">
      <div className="mx-auto max-w-6xl">
        <Reveal className="mb-16">
          <p className="eyebrow mb-6 text-ember-deep">Membership</p>
          <h2 className="font-display text-[clamp(38px,5.5vw,78px)] font-light leading-none tracking-tight">
            Choose your <em className="text-ember-deep">path.</em>
          </h2>
        </Reveal>

        <div className="grid gap-8 md:grid-cols-[1.05fr_0.95fr] md:items-stretch">
          {/* Featured */}
          <Reveal>
            <div className="relative flex h-full flex-col justify-between overflow-hidden bg-void p-10 text-bone md:p-12">
              <span
                aria-hidden
                className="pointer-events-none absolute -right-16 -top-16 h-64 w-64 rounded-full"
                style={{
                  background:
                    "radial-gradient(circle, rgba(208,138,62,0.18), transparent 70%)",
                }}
              />
              <div className="relative">
                <span className="bg-ember px-3 py-1 font-mono text-[9px] uppercase tracking-wide text-void">
                  Most chosen
                </span>
                <div className="mt-8 font-display text-4xl italic">{featured.name}</div>
                <div className="mt-1 font-display text-[68px] font-light leading-none">
                  {featured.price}
                  <span className="ml-2 font-mono text-sm not-italic text-mist">
                    / {featured.cadence.replace("per ", "")}
                  </span>
                </div>
                <p className="mt-4 font-body text-sm text-mist">{featured.blurb}</p>

                <ul className="mt-8 space-y-0">
                  {featured.features?.map((f) => (
                    <li
                      key={f}
                      className="flex items-center gap-3 border-b border-[var(--line-dark)] py-2.5 font-body text-sm text-mist"
                    >
                      <span className="h-1 w-1 shrink-0 rounded-full bg-ember" />
                      {f}
                    </li>
                  ))}
                </ul>
              </div>

              <a
                href="#contact"
                className="relative mt-10 block bg-ember py-4 text-center font-mono text-[11px] uppercase tracking-wide text-void transition-colors hover:bg-ember-pale"
              >
                Become a Devotee
              </a>
            </div>
          </Reveal>

          {/* Rest */}
          <Reveal delay={0.1}>
            <div className="flex h-full flex-col">
              {rest.map((p) => (
                <a
                  key={p.name}
                  href="#contact"
                  data-hover
                  className="grid flex-1 grid-cols-1 items-center gap-2 border-t border-[var(--line-light)] py-7 transition-[padding] duration-300 last:border-b hover:pl-4 md:grid-cols-[1fr_auto] md:gap-6"
                >
                  <div>
                    <div className="font-display text-[28px] italic">{p.name}</div>
                    <div className="mt-1 max-w-xs font-body text-[13px] text-ink-mute">
                      {p.blurb}
                    </div>
                  </div>
                  <div className="whitespace-nowrap font-display text-[34px]">
                    {p.price}
                    <span className="ml-1 font-mono text-xs text-ink-mute">
                      /{p.cadence.replace("per ", "")}
                    </span>
                  </div>
                </a>
              ))}
            </div>
          </Reveal>
        </div>

        {/* UPI payment */}
        <Reveal className="mt-14">
          <div className="mx-auto flex max-w-2xl flex-col items-center gap-7 border border-[var(--line-light)] bg-bone-2/40 p-7 sm:flex-row sm:gap-9 sm:p-9">
            <div className="shrink-0 bg-white p-3 shadow-sm ring-1 ring-[var(--line-light)]">
              <Image
                src={payment.qr}
                alt={`UPI payment QR code for ${payment.bank}`}
                width={148}
                height={148}
                className="h-[148px] w-[148px]"
              />
            </div>
            <div className="text-center sm:text-left">
              <p className="eyebrow mb-2 text-ember-deep">Pay by UPI</p>
              <p className="font-display text-2xl italic leading-tight text-ink">
                Scan to reserve your place.
              </p>
              <p className="mt-3 max-w-sm font-body text-[14px] leading-relaxed text-ink-mute">
                {payment.note}
              </p>
              <p className="mt-4 font-mono text-[10px] uppercase tracking-wide text-ink-mute">
                {payment.bank} · No card gateway needed
              </p>
            </div>
          </div>
        </Reveal>
      </div>
    </section>
  );
}
