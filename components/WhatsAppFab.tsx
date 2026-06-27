"use client";

import { useEffect, useState } from "react";
import { AnimatePresence, motion } from "framer-motion";
import { site } from "@/lib/content";

export default function WhatsAppFab() {
  const [show, setShow] = useState(false);

  useEffect(() => {
    const onScroll = () => setShow(window.scrollY > window.innerHeight * 0.9);
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  const href = `https://wa.me/${site.whatsapp}?text=${encodeURIComponent(
    "Namaste — I'd like to know more about practising at Divinity."
  )}`;

  return (
    <AnimatePresence>
      {show && (
        <motion.a
          href={href}
          target="_blank"
          rel="noopener noreferrer"
          data-hover
          initial={{ opacity: 0, scale: 0.6, y: 20 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.6, y: 20 }}
          transition={{ type: "spring", stiffness: 260, damping: 20 }}
          className="group fixed bottom-6 right-6 z-[320] flex items-center gap-0 overflow-hidden rounded-full border border-ember/40 bg-void/90 py-3 pl-3 pr-3 backdrop-blur-md transition-all hover:pr-5 md:bottom-8 md:right-8"
          aria-label="Chat on WhatsApp"
        >
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" className="shrink-0">
            <path
              d="M12 2a10 10 0 0 0-8.5 15.2L2 22l4.9-1.5A10 10 0 1 0 12 2Zm5.3 14.1c-.2.6-1.3 1.2-1.8 1.2-.5.1-1 .1-1.7-.1-.4-.1-.9-.3-1.6-.6-2.8-1.2-4.6-4-4.7-4.2-.1-.2-1.1-1.5-1.1-2.8 0-1.3.7-2 .9-2.2.2-.3.5-.3.7-.3h.5c.2 0 .4 0 .6.5l.8 1.9c.1.2.1.4 0 .5l-.4.6c-.2.2-.3.4-.1.7.2.3.8 1.3 1.7 2.1 1.2 1 2.1 1.4 2.4 1.5.2.1.4.1.6-.1l.8-1c.2-.2.4-.2.6-.1l1.8.9c.3.1.4.2.5.3.1.2.1.8-.1 1.4Z"
              fill="#D08A3E"
            />
          </svg>
          <span className="max-w-0 whitespace-nowrap font-mono text-[11px] uppercase tracking-wide text-bone opacity-0 transition-all duration-300 group-hover:ml-2.5 group-hover:max-w-[160px] group-hover:opacity-100">
            Chat with us
          </span>
        </motion.a>
      )}
    </AnimatePresence>
  );
}
