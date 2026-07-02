"use client";

import { useEffect, useRef, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { AnimatePresence, m } from "framer-motion";
import { site } from "@/lib/content";
import { navItems, primaryNav } from "@/lib/nav";
import { trapTab } from "@/lib/focus-trap";
import { useLocale } from "@/lib/i18n/LocaleContext";
import { useTheme } from "@/lib/theme/ThemeContext";
import Magnetic from "./Magnetic";

function openPalette() {
  window.dispatchEvent(new KeyboardEvent("keydown", { key: "k", metaKey: true }));
}

export default function Nav({ site: siteProp }: { site?: typeof site }) {
  const activeSite = siteProp || site;
  const pathname = usePathname();
  const { locale, setLocale, t } = useLocale();
  const { theme, toggleTheme } = useTheme();
  const [solid, setSolid] = useState(false);
  const [open, setOpen] = useState(false);
  const menuBtnRef = useRef<HTMLButtonElement>(null);
  const closeBtnRef = useRef<HTMLButtonElement>(null);

  const isActive = (href: string) =>
    href === "/" ? pathname === "/" : pathname === href || pathname.startsWith(href + "/");

  useEffect(() => {
    const onScroll = () => setSolid(window.scrollY > 64);
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  // Close the mobile menu whenever the route changes.
  useEffect(() => {
    setOpen(false);
  }, [pathname]);

  // Mobile menu: close on Escape, lock background scroll, manage focus.
  useEffect(() => {
    if (!open) return;
    const trigger = menuBtnRef.current;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") setOpen(false);
    };
    document.addEventListener("keydown", onKey);
    document.documentElement.style.overflow = "hidden";
    closeBtnRef.current?.focus();
    return () => {
      document.removeEventListener("keydown", onKey);
      document.documentElement.style.overflow = "";
      trigger?.focus();
    };
  }, [open]);

  return (
    <>
      <m.nav
        initial={{ y: -40, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ duration: 1, delay: 0.2, ease: [0.22, 1, 0.36, 1] }}
        className={`fixed inset-x-0 top-0 z-[300] flex items-center justify-between px-6 transition-all duration-500 md:px-10 ${
          solid
            ? "border-b border-[var(--line-dark)] bg-void/85 py-3 backdrop-blur-md"
            : "py-6"
        }`}
      >
        <Link href="/" className="group flex items-center gap-2.5" aria-label={`${activeSite.full} — home`}>
          <Image
            src={activeSite.logoMark}
            alt=""
            width={30}
            height={30}
            priority
            className="h-7 w-7 transition-transform duration-500 group-hover:scale-110"
          />
          <span className="font-mono text-[11px] uppercase tracking-label text-ember">
            {activeSite.name}
            <span className="text-mist"> — the third eye</span>
          </span>
        </Link>

        <div className="hidden items-center gap-7 lg:flex">
          {primaryNav.map((l) => (
            <Link
              key={l.href}
              href={l.href}
              aria-current={isActive(l.href) ? "page" : undefined}
              className={`font-mono text-[11px] uppercase tracking-wide transition-colors hover:text-ember ${
                isActive(l.href) ? "text-ember" : "text-mist"
              }`}
            >
              {t(l.label)}
            </Link>
          ))}
          <button
            onClick={openPalette}
            className="flex items-center gap-1.5 text-mist transition-colors hover:text-ember"
            aria-label="Open command menu"
          >
            <span className="kbd">⌘K</span>
          </button>
          <button
            onClick={() => setLocale(locale === "en" ? "hi" : "en")}
            className="font-mono text-[11px] uppercase tracking-wide text-mist transition-colors hover:text-ember"
            aria-label={t("Language")}
          >
            {locale === "en" ? "हिं" : "EN"}
          </button>
          <button
            onClick={toggleTheme}
            className="font-mono text-[11px] uppercase tracking-wide text-mist transition-colors hover:text-ember"
            aria-label="Toggle theme"
          >
            {theme === "dark" ? "☀" : "☾"}
          </button>
          <Magnetic>
            <Link
              href="/contact"
              className="border border-ember px-5 py-2 font-mono text-[11px] uppercase tracking-wide text-ember transition-colors hover:bg-ember hover:text-void"
            >
              {t("Begin")}
            </Link>
          </Magnetic>
        </div>

        <button
          ref={menuBtnRef}
          onClick={() => setOpen(true)}
          className="font-mono text-[11px] uppercase tracking-wide text-bone lg:hidden"
          aria-label="Open menu"
          aria-expanded={open}
          aria-controls="mobile-menu"
        >
          {t("Menu")}
        </button>
      </m.nav>

      <AnimatePresence>
        {open && (
          <m.div
            id="mobile-menu"
            role="dialog"
            aria-modal="true"
            aria-label="Site menu"
            onKeyDown={trapTab}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-[400] flex flex-col items-center justify-center gap-6 overflow-y-auto bg-void/95 px-6 py-24 backdrop-blur-lg lg:hidden"
          >
            <button
              ref={closeBtnRef}
              onClick={() => setOpen(false)}
              className="absolute right-6 top-6 font-mono text-[11px] uppercase tracking-wide text-mist"
              aria-label="Close menu"
            >
              {t("Close")}
            </button>
            {navItems.map((l, i) => (
              <m.div
                key={l.href}
                initial={{ opacity: 0, y: 16 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.04 * i }}
              >
                <Link
                  href={l.href}
                  aria-current={isActive(l.href) ? "page" : undefined}
                  className={`font-display text-3xl font-light ${
                    isActive(l.href) ? "text-ember" : "text-bone"
                  }`}
                >
                  {t(l.label)}
                </Link>
              </m.div>
            ))}
            <m.div
              initial={{ opacity: 0, y: 16 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.04 * navItems.length }}
              className="mt-2"
            >
              <Link
                href="/contact"
                className="border border-ember px-7 py-3 font-mono text-[11px] uppercase tracking-wide text-ember"
              >
                {t("Begin")}
              </Link>
            </m.div>
            <m.div
              initial={{ opacity: 0, y: 16 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.04 * (navItems.length + 1) }}
              className="flex items-center gap-6"
            >
              <button
                onClick={() => setLocale(locale === "en" ? "hi" : "en")}
                className="font-mono text-[11px] uppercase tracking-wide text-mist"
              >
                {locale === "en" ? "हिंदी में देखें" : "View in English"}
              </button>
              <button
                onClick={toggleTheme}
                className="font-mono text-[11px] uppercase tracking-wide text-mist"
                aria-label="Toggle theme"
              >
                {theme === "dark" ? "☀ Light" : "☾ Dark"}
              </button>
            </m.div>
          </m.div>
        )}
      </AnimatePresence>
    </>
  );
}
