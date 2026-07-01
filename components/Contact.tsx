"use client";

import { useEffect, useRef, useState } from "react";
import Reveal from "./Reveal";
import { site, locationConfig } from "@/lib/content";
import { formErrorMessage } from "@/lib/form-error";
import WeatherWidget from "./WeatherWidget";

type Status = "idle" | "sending" | "done" | "error";

const intentions = [
  "Yoga",
  "Fitness",
  "Therapeutic yoga",
  "Pranayama & meditation",
  "Diet & lifestyle",
  "Not sure yet",
];

export default function Contact({ site: siteProp }: { site?: typeof site }) {
  const activeSite = siteProp || site;
  const [status, setStatus] = useState<Status>("idle");
  const [error, setError] = useState("");
  const abortRef = useRef<AbortController | null>(null);

  // Cancel any in-flight request if the form unmounts (e.g. route change).
  useEffect(() => () => abortRef.current?.abort(), []);

  async function onSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    // Supersede any prior in-flight submit so a double-tap can't race.
    abortRef.current?.abort();
    const controller = new AbortController();
    abortRef.current = controller;
    setStatus("sending");
    setError("");
    const form = new FormData(e.currentTarget);
    const payload = {
      name: String(form.get("name") || ""),
      email: String(form.get("email") || ""),
      intention: String(form.get("intention") || ""),
      message: String(form.get("message") || ""),
      company: String(form.get("company") || ""), // honeypot
    };
    try {
      const res = await fetch("/api/contact", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
        signal: controller.signal,
      });
      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error(data.error || "Something went wrong. Please try again.");
      }
      setStatus("done");
    } catch (err) {
      // Aborted (unmounted or superseded) — drop silently, don't flash an error.
      if (controller.signal.aborted) return;
      setStatus("error");
      setError(formErrorMessage(err));
    }
  }

  const field =
    "w-full border-b border-[var(--line-dark)] bg-transparent py-3 font-body text-bone placeholder:text-mist/60 focus:border-ember focus:outline-none";

  return (
    <section
      id="contact"
      className="relative overflow-hidden border-t border-[var(--line-dark)] bg-void px-6 py-28 md:px-10 md:py-40"
    >
      <span
        aria-hidden
        data-watermark="Divinity"
        className="watermark pointer-events-none absolute bottom-[-90px] left-1/2 -translate-x-1/2 select-none font-display text-[clamp(120px,20vw,320px)] leading-none text-bone/[0.025]"
      />

      <div className="relative mx-auto grid max-w-6xl gap-16 md:grid-cols-2 md:gap-24">
        <Reveal>
          <p className="eyebrow mb-7 text-ember">Begin today</p>
          <h2 className="font-display text-[clamp(40px,6vw,92px)] font-light leading-[0.92] tracking-tight text-bone">
            Your first
            <br />
            <em className="text-ember">breath</em> with us.
          </h2>
          <p className="mt-8 max-w-sm font-body text-base leading-relaxed text-mist">
            Visit us in {activeSite.city}, or send a note below. The first step is the
            simplest — and it is yours to take.
          </p>
          <div className="mt-10 space-y-1 font-mono text-[12px] uppercase tracking-wide text-mist">
            <p>{activeSite.city}</p>
            <p>{activeSite.entity}</p>
          </div>
          
          <div className="mt-12 space-y-8">
            <WeatherWidget />
            
            <div className="space-y-4">
              <div className="relative h-[280px] w-full overflow-hidden border border-[var(--line-dark)]">
                <iframe
                  title={`Interactive location map of Divinity in ${locationConfig.name}`}
                  src={`https://maps.google.com/maps?q=${encodeURIComponent(locationConfig.name + ", " + locationConfig.city)}&t=&z=15&ie=UTF8&iwloc=&output=embed`}
                  width="100%"
                  height="100%"
                  style={{ border: 0 }}
                  allowFullScreen
                  loading="lazy"
                  className="opacity-85 hover:opacity-100 transition-opacity"
                />
              </div>
              <div className="flex flex-wrap gap-3">
                <a
                  href={`https://maps.google.com/?q=${encodeURIComponent(locationConfig.name + ", " + locationConfig.city)}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-block border border-[var(--line-dark)] px-4 py-2.5 font-mono text-[10px] uppercase tracking-wider text-bone hover:border-ember hover:text-ember transition-colors"
                >
                  Open in Google Maps
                </a>
                <a
                  href={`https://www.google.com/maps/dir/?api=1&destination=${locationConfig.latitude},${locationConfig.longitude}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-block bg-ember px-4 py-2.5 font-mono text-[10px] uppercase tracking-wider text-void hover:bg-ember-pale transition-colors"
                >
                  Directions
                </a>
              </div>
            </div>
          </div>
        </Reveal>

        <Reveal delay={0.1}>
          {status === "done" ? (
            <div role="status" aria-live="polite" className="flex h-full flex-col justify-center border border-[var(--line-dark)] p-10 text-center">
              <p className="font-display text-3xl italic text-ember">
                Thank you.
              </p>
              <p className="mt-3 font-body text-mist">
                We have received your note and will reach out shortly to begin.
              </p>
            </div>
          ) : (
            <form onSubmit={onSubmit} className="space-y-7" aria-label="Contact enquiry form">
              {/* Honeypot — hidden from users, off the a11y tree; bots fill it */}
              <div className="absolute left-[-9999px]" aria-hidden="true">
                <label htmlFor="contact-company">Company</label>
                <input
                  id="contact-company"
                  name="company"
                  type="text"
                  tabIndex={-1}
                  autoComplete="off"
                />
              </div>
              <div>
                <label htmlFor="contact-name" className="eyebrow mb-2 block text-mist">Name</label>
                <input id="contact-name" name="name" required autoComplete="name" className={field} placeholder="Your name" aria-required="true" />
              </div>
              <div>
                <label htmlFor="contact-email" className="eyebrow mb-2 block text-mist">Email</label>
                <input
                  id="contact-email"
                  name="email"
                  type="email"
                  required
                  autoComplete="email"
                  inputMode="email"
                  aria-required="true"
                  className={field}
                  placeholder="you@example.com"
                />
              </div>
              <div>
                <label htmlFor="contact-intention" className="eyebrow mb-2 block text-mist">
                  What draws you
                </label>
                <select id="contact-intention" name="intention" required aria-required="true" className={`${field} appearance-none`} defaultValue="">
                  <option value="" disabled className="bg-deep">
                    Choose a practice
                  </option>
                  {intentions.map((it) => (
                    <option key={it} value={it} className="bg-deep">
                      {it}
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <label htmlFor="contact-message" className="eyebrow mb-2 block text-mist">Message</label>
                <textarea
                  id="contact-message"
                  name="message"
                  rows={3}
                  className={`${field} resize-none`}
                  placeholder="Anything we should know — goals, history, questions."
                />
              </div>

              {status === "error" && (
                <p role="alert" className="font-mono text-[12px] text-clay">{error}</p>
              )}

              <button
                type="submit"
                disabled={status === "sending"}
                className="w-full bg-ember py-4 font-mono text-[11px] uppercase tracking-wide text-void transition-colors hover:bg-ember-pale disabled:opacity-60"
              >
                {status === "sending" ? "Sending…" : "Send enquiry"}
              </button>
            </form>
          )}
        </Reveal>
      </div>
    </section>
  );
}
