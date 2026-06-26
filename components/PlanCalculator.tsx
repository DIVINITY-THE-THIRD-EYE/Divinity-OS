"use client";

import { useMemo, useState } from "react";
import { AnimatePresence, motion } from "framer-motion";
import Reveal from "./Reveal";
import { plans, site } from "@/lib/content";

type Commit = "Try it" | "Monthly" | "Quarterly" | "Yearly";
type Focus = "One discipline" | "Everything";

function recommend(commit: Commit, focus: Focus, oneToOne: boolean) {
  if (oneToOne || commit === "Yearly") return "The Yogi";
  if (commit === "Try it") return "Drop-in";
  if (focus === "One discipline" && commit === "Monthly") return "The Seeker";
  return "The Devotee";
}

const Option = ({
  active,
  onClick,
  children,
}: {
  active: boolean;
  onClick: () => void;
  children: React.ReactNode;
}) => (
  <button
    onClick={onClick}
    className={`border px-4 py-2.5 font-mono text-[11px] uppercase tracking-wide transition-colors ${
      active
        ? "border-ember bg-ember text-void"
        : "border-[var(--line-dark)] text-mist hover:text-ember"
    }`}
  >
    {children}
  </button>
);

export default function PlanCalculator() {
  const [commit, setCommit] = useState<Commit>("Quarterly");
  const [focus, setFocus] = useState<Focus>("Everything");
  const [oneToOne, setOneToOne] = useState(false);

  const rec = useMemo(
    () => recommend(commit, focus, oneToOne),
    [commit, focus, oneToOne]
  );
  const plan = plans.find((p) => p.name === rec) ?? plans[0];

  const wa = `https://wa.me/${site.whatsapp}?text=${encodeURIComponent(
    `Namaste — based on the site I think ${rec} suits me. I'd like to begin.`
  )}`;

  return (
    <section
      id="calculator"
      className="border-t border-[var(--line-dark)] bg-void px-6 py-28 md:px-10 md:py-36"
    >
      <div className="mx-auto max-w-5xl">
        <Reveal className="mb-14 max-w-2xl">
          <p className="eyebrow mb-6 text-ember">Shape your practice</p>
          <h2 className="font-display text-[clamp(34px,5vw,64px)] font-light leading-none tracking-tight">
            Find the path that <em className="text-ember">fits.</em>
          </h2>
        </Reveal>

        <div className="grid gap-10 md:grid-cols-[1fr_0.9fr] md:gap-16">
          <div className="space-y-9">
            <div>
              <p className="eyebrow mb-4 text-mist">How would you like to start?</p>
              <div className="flex flex-wrap gap-2">
                {(["Try it", "Monthly", "Quarterly", "Yearly"] as Commit[]).map((c) => (
                  <Option key={c} active={commit === c} onClick={() => setCommit(c)}>
                    {c}
                  </Option>
                ))}
              </div>
            </div>

            <div>
              <p className="eyebrow mb-4 text-mist">Your focus</p>
              <div className="flex flex-wrap gap-2">
                {(["One discipline", "Everything"] as Focus[]).map((f) => (
                  <Option key={f} active={focus === f} onClick={() => setFocus(f)}>
                    {f}
                  </Option>
                ))}
              </div>
            </div>

            <div>
              <p className="eyebrow mb-4 text-mist">One-on-one guidance?</p>
              <div className="flex flex-wrap gap-2">
                <Option active={!oneToOne} onClick={() => setOneToOne(false)}>
                  Group is fine
                </Option>
                <Option active={oneToOne} onClick={() => setOneToOne(true)}>
                  Yes, personal
                </Option>
              </div>
            </div>
          </div>

          {/* Result */}
          <div className="relative flex flex-col justify-between overflow-hidden border border-[var(--line-dark)] p-8">
            <span
              aria-hidden
              className="pointer-events-none absolute -right-12 -top-12 h-48 w-48 rounded-full"
              style={{
                background:
                  "radial-gradient(circle, rgba(208,138,62,0.16), transparent 70%)",
              }}
            />
            <div className="relative">
              <p className="eyebrow text-mist">We'd suggest</p>
              <AnimatePresence mode="wait">
                <motion.div
                  key={plan.name}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -8 }}
                  transition={{ duration: 0.3 }}
                >
                  <div className="mt-3 font-display text-4xl italic text-bone">
                    {plan.name}
                  </div>
                  <div className="mt-1 font-display text-5xl font-light text-bone">
                    {plan.price}
                    <span className="ml-2 font-mono text-sm text-mist">
                      / {plan.cadence.replace("per ", "")}
                    </span>
                  </div>
                  <p className="mt-4 font-body text-sm text-mist">{plan.blurb}</p>
                </motion.div>
              </AnimatePresence>
            </div>

            <div className="relative mt-8 flex flex-col gap-3">
              <a
                href="#contact"
                className="block bg-ember py-3.5 text-center font-mono text-[11px] uppercase tracking-wide text-void transition-colors hover:bg-ember-pale"
              >
                Enquire about {plan.name}
              </a>
              <a
                href={wa}
                target="_blank"
                rel="noopener noreferrer"
                className="block border border-[var(--line-dark)] py-3.5 text-center font-mono text-[11px] uppercase tracking-wide text-bone transition-colors hover:border-ember hover:text-ember"
              >
                Ask on WhatsApp
              </a>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
