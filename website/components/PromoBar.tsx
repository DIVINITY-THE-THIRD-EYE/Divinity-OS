"use client";

import { useEffect, useRef, useState } from "react";
import { m, AnimatePresence } from "framer-motion";
import { waHref } from "@/lib/links";
import { introOffer } from "@/content/offers";

const whatsappHref = waHref(
  "Namaste — I'd like to claim the first-week trial offer at Divinity."
);

/**
 * Fixed at the very top (above Nav). Publishes its own rendered height as
 * `--promo-h` on <html> so Nav can sit fixed just below it instead of
 * overlapping — before this, both were independently fixed/positioned at the
 * same y:0 with Nav's lower z-index, so the promo bar silently ate every
 * click meant for the nav underneath it (caught via Playwright: clicking the
 * "Pricing" nav link timed out — elementFromPoint at that link's coordinates
 * resolved to the promo bar, not the link).
 */
export default function PromoBar() {
  const [dismissed, setDismissed] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (dismissed) {
      document.documentElement.style.setProperty("--promo-h", "0px");
      return;
    }
    const el = ref.current;
    if (!el) return;
    const update = () => document.documentElement.style.setProperty("--promo-h", `${el.offsetHeight}px`);
    update();
    const ro = new ResizeObserver(update);
    ro.observe(el);
    return () => ro.disconnect();
  }, [dismissed]);

  useEffect(() => {
    return () => document.documentElement.style.setProperty("--promo-h", "0px");
  }, []);

  return (
    <AnimatePresence>
      {!dismissed && (
        <m.div
          ref={ref}
          initial={{ height: 0, opacity: 0 }}
          animate={{ height: "auto", opacity: 1 }}
          exit={{ height: 0, opacity: 0 }}
          transition={{ duration: 0.35, ease: [0.22, 1, 0.36, 1] }}
          className="fixed inset-x-0 top-0 z-[360] overflow-hidden bg-ember"
        >
          <div className="flex items-center justify-between gap-3 px-4 py-2.5 md:justify-center md:gap-6">
            <p className="font-mono text-[11px] uppercase tracking-wide text-void">
              <span className="line-through opacity-90">₹500</span>
              <span className="mx-1.5 font-bold">{introOffer.price} {introOffer.duration}</span>
              <span className="hidden md:inline">— try any class, no commitment.</span>
            </p>
            <a
              href={whatsappHref}
              target="_blank"
              rel="noopener noreferrer"
              className="shrink-0 border border-void/30 px-3 py-1 font-mono text-[10px] uppercase tracking-wide text-void transition-colors hover:bg-void hover:text-ember"
            >
              Claim offer
            </a>
            <button
              onClick={() => setDismissed(true)}
              aria-label="Dismiss offer banner"
              className="absolute right-2 top-1/2 flex h-7 w-7 -translate-y-1/2 items-center justify-center text-void/80 hover:text-void md:static md:translate-y-0"
            >
              ✕
            </button>
          </div>
        </m.div>
      )}
    </AnimatePresence>
  );
}
