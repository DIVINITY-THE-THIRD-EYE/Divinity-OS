"use client";

import { useEffect, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { waHref } from "@/lib/links";

const whatsappHref = waHref("Namaste — I'd like to book a first class at Divinity.");

export default function StickyCta() {
  const [visible, setVisible] = useState(false);
  const [pastContact, setPastContact] = useState(false);

  useEffect(() => {
    const onScroll = () => {
      const y = window.scrollY;
      const contact = document.getElementById("contact");
      const contactTop = contact ? contact.getBoundingClientRect().top + y : Infinity;
      setVisible(y > window.innerHeight * 0.6);
      setPastContact(y + window.innerHeight > contactTop);
    };
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  return (
    <AnimatePresence>
      {visible && !pastContact && (
        <motion.div
          initial={{ y: 80, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          exit={{ y: 80, opacity: 0 }}
          transition={{ duration: 0.4, ease: [0.22, 1, 0.36, 1] }}
          className="fixed bottom-0 inset-x-0 z-[280] flex gap-0 md:hidden"
        >
          <a
            href={whatsappHref}
            target="_blank"
            rel="noopener noreferrer"
            className="flex-1 bg-[#25D366] py-4 text-center font-mono text-[11px] uppercase tracking-wide text-void"
          >
            WhatsApp
          </a>
          <a
            href="#contact"
            className="flex-1 bg-ember py-4 text-center font-mono text-[11px] uppercase tracking-wide text-void"
          >
            Book a class
          </a>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
