"use client";

import { createContext, useContext, useEffect, useMemo, useState } from "react";

const STORAGE_KEY = "divinity_theme";

export type ThemeMode = "dark" | "light";

type ThemeContextValue = {
  theme: ThemeMode;
  toggleTheme: () => void;
};

const ThemeContext = createContext<ThemeContextValue>({
  theme: "dark",
  toggleTheme: () => {},
});

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  // Dark stays the default identity (ADR-0012's original call) — the
  // toggle is additive, per decision #3 overriding ADR-0012's "no toggle".
  //
  // State starts "dark" on the server AND on the client's first render —
  // matching them avoids a hydration mismatch (React would otherwise detect
  // different rendered content, e.g. the toggle icon, between server and
  // client and throw away the server HTML — a worse flash than the one we're
  // avoiding). The CSS-level flash is fixed separately, and safely, by the
  // inline no-flash script (app/layout.tsx <head>): it sets the `data-theme`
  // DOM attribute directly, outside React's tree, before hydration — CSS
  // reads it immediately, but React never rendered anything conditioned on
  // it, so there's nothing to mismatch. This effect then reads that same
  // attribute AFTER mount to correct the React-level `theme` state (icon,
  // aria-pressed) — a normal post-mount state update, not a render-time read.
  const [theme, setTheme] = useState<ThemeMode>("dark");

  useEffect(() => {
    const attr = document.documentElement.getAttribute("data-theme");
    if (attr === "light") setTheme("light");
  }, []);

  useEffect(() => {
    document.documentElement.setAttribute("data-theme", theme);
  }, [theme]);

  const toggleTheme = () => {
    setTheme((prev) => {
      const next = prev === "dark" ? "light" : "dark";
      window.localStorage.setItem(STORAGE_KEY, next);
      return next;
    });
  };

  const value = useMemo(() => ({ theme, toggleTheme }), [theme]);

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
}

export function useTheme() {
  return useContext(ThemeContext);
}
