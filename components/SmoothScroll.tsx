"use client";

import { useEffect } from "react";

export default function SmoothScroll() {
  useEffect(() => {
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    if (reduce) return;

    let cleanup = () => {};
    let cancelled = false;
    let started = false;

    const start = async () => {
      if (started || cancelled) return;
      started = true;

      // Dynamic import keeps Lenis + GSAP off the critical render path, and
      // deferring the *fetch* until idle/first-scroll keeps these chunks out
      // of the initial load window (so they don't gate TTI/LCP).
      const [{ default: Lenis }, { gsap }, { ScrollTrigger }] = await Promise.all([
        import("lenis"),
        import("gsap"),
        import("gsap/ScrollTrigger"),
      ]);
      if (cancelled) return;

      gsap.registerPlugin(ScrollTrigger);

      const lenis = new Lenis({
        duration: 1.15,
        easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
        smoothWheel: true,
      });

      lenis.on("scroll", ScrollTrigger.update);

      const ticker = (time: number) => lenis.raf(time * 1000);
      gsap.ticker.add(ticker);
      gsap.ticker.lagSmoothing(0);

      // Anchor links route through Lenis
      const onClick = (e: MouseEvent) => {
        const a = (e.target as HTMLElement).closest('a[href^="#"]');
        if (!a) return;
        const id = a.getAttribute("href");
        if (!id || id === "#") return;
        const el = document.querySelector(id);
        if (el) {
          e.preventDefault();
          lenis.scrollTo(el as HTMLElement, { offset: -10 });
          // Move focus to programmatically-focusable targets (skip link → main).
          if ((el as HTMLElement).hasAttribute("tabindex")) {
            (el as HTMLElement).focus({ preventScroll: true });
          }
        }
      };
      document.addEventListener("click", onClick);

      cleanup = () => {
        document.removeEventListener("click", onClick);
        gsap.ticker.remove(ticker);
        lenis.destroy();
      };
    };

    // Kick off on first real intent (scroll/pointer/key) or when the browser
    // goes idle — whichever comes first. Keeps the scroll libraries out of the
    // initial network window so they don't delay TTI/LCP.
    const triggers: Array<keyof WindowEventMap> = ["wheel", "touchstart", "pointerdown", "keydown", "scroll"];
    const onIntent = () => {
      removeTriggers();
      start();
    };
    const removeTriggers = () =>
      triggers.forEach((t) => window.removeEventListener(t, onIntent));
    triggers.forEach((t) => window.addEventListener(t, onIntent, { passive: true, once: true }));

    const w = window as Window & {
      requestIdleCallback?: (cb: () => void, opts?: { timeout: number }) => number;
      cancelIdleCallback?: (id: number) => void;
    };
    const ric = w.requestIdleCallback
      ? w.requestIdleCallback(onIntent, { timeout: 2500 })
      : window.setTimeout(onIntent, 1800);

    return () => {
      cancelled = true;
      removeTriggers();
      if (w.cancelIdleCallback) w.cancelIdleCallback(ric);
      else clearTimeout(ric);
      cleanup();
    };
  }, []);

  return null;
}
