"use client";

import { useEffect, useState } from "react";
import Image from "next/image";
import { AnimatePresence, motion } from "framer-motion";
import { site } from "@/lib/content";
import Magnetic from "./Magnetic";

const links = [
  { href: "#about", label: "Academy", id: "about" },
  { href: "#disciplines", label: "Practice", id: "disciplines" },
  { href: "#space", label: "The space", id: "space" },
  { href: "#schedule", label: "Schedule", id: "schedule" },
  { href: "#membership", label: "Membership", id: "membership" },
];

function openPalette() {
  window.dispatchEvent(new KeyboardEvent("keydown", { key: "k", metaKey: true }));
}

export default function Nav() {
  const [solid, setSolid] = useState(false);
  const [open, setOpen] = useState(false);
  const [active, setActive] = useState<string>("");

  useEffect(() => {
    const onScroll = () => setSolid(window.scrollY > 64);
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  useEffect(() => {
    const sections = links
      .map((l) => document.getElementById(l.id))
      .filter(Boolean) as HTMLElement[];
    const obs = new IntersectionObserver(
      (entries) => {
        entries.forEach((e) => {
          if (e.isIntersecting) setActive(e.target.id);
        });
      },
      { rootMargin: "-45% 0px -50% 0px" }
    );
    sections.forEach((s) => obs.observe(s));
    return () => obs.disconnect();
  }, []);

  return (
    <>
      <motion.nav
        initial={{ y: -40, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ duration: 1, delay: 0.2, ease: [0.22, 1, 0.36, 1] }}
        className={`fixed inset-x-0 top-0 z-[300] flex items-center justify-between px-6 transition-all duration-500 md:px-10 ${
          solid
            ? "border-b border-[var(--line-dark)] bg-void/85 py-3 backdrop-blur-md"
            : "py-6"
        }`}
      >
        <a href="#top" className="group flex items-center gap-2.5" aria-label={`${site.full} — home`}>
          <Image
            src={site.logoMark}
            alt=""
            width={30}
            height={30}
            priority
            className="h-7 w-7 transition-transform duration-500 group-hover:scale-110"
          />
          <span className="font-mono text-[11px] uppercase tracking-label text-ember">
            {site.name}
            <span className="text-mist"> — the third eye</span>
          </span>
        </a>

        <div className="hidden items-center gap-9 md:flex">
          {links.map((l) => (
            <a
              key={l.href}
              href={l.href}
              className={`font-mono text-[11px] uppercase tracking-wide transition-colors hover:text-ember ${
                active === l.id ? "text-ember" : "text-mist"
              }`}
            >
              {l.label}
            </a>
          ))}
          <button
            onClick={openPalette}
            className="flex items-center gap-1.5 text-mist transition-colors hover:text-ember"
            aria-label="Open command menu"
          >
            <span className="kbd">⌘K</span>
          </button>
          <Magnetic>
            <a
              href="#contact"
              className="border border-ember px-5 py-2 font-mono text-[11px] uppercase tracking-wide text-ember transition-colors hover:bg-ember hover:text-void"
            >
              Begin
            </a>
          </Magnetic>
        </div>

        <button
          onClick={() => setOpen(true)}
          className="font-mono text-[11px] uppercase tracking-wide text-bone md:hidden"
          aria-label="Open menu"
        >
          Menu
        </button>
      </motion.nav>

      <AnimatePresence>
        {open && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-[400] flex flex-col items-center justify-center gap-8 bg-void/95 backdrop-blur-lg md:hidden"
          >
            <button
              onClick={() => setOpen(false)}
              className="absolute right-6 top-6 font-mono text-[11px] uppercase tracking-wide text-mist"
              aria-label="Close menu"
            >
              Close
            </button>
            {[...links, { href: "#contact", label: "Begin", id: "contact" }].map((l, i) => (
              <motion.a
                key={l.href}
                href={l.href}
                onClick={() => setOpen(false)}
                initial={{ opacity: 0, y: 16 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.06 * i }}
                className="font-display text-4xl font-light text-bone"
              >
                {l.label}
              </motion.a>
            ))}
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
