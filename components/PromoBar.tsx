"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { site } from "@/lib/content";

const whatsappHref = `https://wa.me/${site.whatsapp}?text=${encodeURIComponent(
  "Namaste — I'd like to claim the first-week trial offer at Divinity."
)}`;

export default function PromoBar() {
  const [dismissed, setDismissed] = useState(false);

  return (
    <AnimatePresence>
      {!dismissed && (
        <motion.div
          initial={{ height: 0, opacity: 0 }}
          animate={{ height: "auto", opacity: 1 }}
          exit={{ height: 0, opacity: 0 }}
          transition={{ duration: 0.35, ease: [0.22, 1, 0.36, 1] }}
          className="relative z-[350] overflow-hidden bg-ember"
        >
          <div className="flex items-center justify-between gap-3 px-4 py-2.5 md:justify-center md:gap-6">
            <p className="font-mono text-[11px] uppercase tracking-wide text-void">
              <span className="line-through opacity-90">₹500</span>
              <span className="mx-1.5 font-bold">₹99 first week</span>
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
        </motion.div>
      )}
    </AnimatePresence>
  );
}
