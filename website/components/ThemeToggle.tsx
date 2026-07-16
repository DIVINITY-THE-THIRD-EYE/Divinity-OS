"use client";

import { useTheme } from "@/lib/theme/ThemeContext";

/** Real button, aria-pressed, 24px+ target, visible focus (global :focus-visible). */
export default function ThemeToggle({ className = "" }: { className?: string }) {
  const { theme, toggleTheme } = useTheme();
  const isDay = theme === "light";

  return (
    <button
      type="button"
      onClick={toggleTheme}
      aria-pressed={isDay}
      aria-label={isDay ? "Switch to night mode" : "Switch to day mode"}
      className={`flex h-8 w-8 items-center justify-center font-mono text-[11px] uppercase tracking-wide text-mist transition-colors hover:text-ember ${className}`}
    >
      <span aria-hidden="true">{isDay ? "☾" : "☀"}</span>
    </button>
  );
}
