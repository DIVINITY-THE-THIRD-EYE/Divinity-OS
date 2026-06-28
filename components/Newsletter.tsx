"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import Reveal from "./Reveal";

type Status = "idle" | "sending" | "done" | "error";

export default function Newsletter() {
  const [status, setStatus] = useState<Status>("idle");
  const [error, setError] = useState("");

  async function onSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setStatus("sending");
    setError("");
    const form = new FormData(e.currentTarget);
    const email = String(form.get("email") || "").trim();
    const company = String(form.get("company") || ""); // honeypot
    try {
      const res = await fetch("/api/subscribe", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, company }),
      });
      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error(data.error || "Something went wrong.");
      }
      setStatus("done");
    } catch (err) {
      setStatus("error");
      setError(err instanceof Error ? err.message : "Please try again.");
    }
  }

  return (
    <section className="border-t border-[var(--line-dark)] bg-deep px-6 py-20 md:px-10">
      <Reveal>
        <div className="mx-auto max-w-2xl text-center">
          <p className="eyebrow mb-4 text-ember">Free guided practice</p>
          <h2 className="font-display text-[clamp(28px,4vw,52px)] font-light leading-tight text-bone">
            Begin with a free<br />
            <em className="text-ember">breathing session.</em>
          </h2>
          <p className="mx-auto mt-4 max-w-md font-body text-[14px] leading-relaxed text-mist">
            Join our mailing list and receive a complimentary guided pranayama
            recording — the same breath practice we teach in the dawn batch.
          </p>

          {status === "done" ? (
            <motion.p
              role="status"
              aria-live="polite"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              className="mt-8 font-display text-xl italic text-ember"
            >
              Check your inbox — your free session is on its way.
            </motion.p>
          ) : (
            <form onSubmit={onSubmit} className="mt-8 flex flex-col gap-3 sm:flex-row sm:justify-center">
              {/* Honeypot — hidden from users and the a11y tree */}
              <div className="absolute left-[-9999px]" aria-hidden="true">
                <label htmlFor="newsletter-company">Company</label>
                <input id="newsletter-company" name="company" type="text" tabIndex={-1} autoComplete="off" />
              </div>
              <label htmlFor="newsletter-email" className="sr-only">Email address</label>
              <input
                id="newsletter-email"
                name="email"
                type="email"
                required
                autoComplete="email"
                inputMode="email"
                aria-required="true"
                placeholder="your@email.com"
                className="w-full border-b border-[var(--line-dark)] bg-transparent py-3 px-0 font-body text-bone placeholder:text-mist/50 focus:border-ember focus:outline-none sm:w-72"
              />
              <button
                type="submit"
                disabled={status === "sending"}
                className="border border-ember px-6 py-3 font-mono text-[11px] uppercase tracking-wide text-ember transition-colors hover:bg-ember hover:text-void disabled:opacity-60"
              >
                {status === "sending" ? "Sending…" : "Get free session"}
              </button>
            </form>
          )}
          {status === "error" && (
            <p role="alert" className="mt-3 font-mono text-[12px] text-clay">{error}</p>
          )}
          <p className="mt-4 font-mono text-[10px] uppercase tracking-wide text-mist/50">
            No spam. Unsubscribe any time.
          </p>
        </div>
      </Reveal>
    </section>
  );
}
