import type { Config } from "tailwindcss";

// Each brand color resolves through a CSS variable (defined in
// app/globals.css, `:root` for dark / `[data-theme="light"]` for light) so
// the theme toggle can swap values at runtime — see ThemeContext. The
// `-rgb` (space-separated channel) variant plus this opacityValue function
// is required to keep Tailwind's opacity-modifier utilities working
// (bg-void/85 etc.), which a plain `var(--void)` string can't support.
function withOpacity(cssVar: string) {
  return ({ opacityValue }: { opacityValue?: string }) =>
    opacityValue !== undefined
      ? `rgb(var(${cssVar}) / ${opacityValue})`
      : `rgb(var(${cssVar}))`;
}

const config: Config = {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}"],
  theme: {
    extend: {
      // Tailwind v3 supports function-value colors at runtime (this is the
      // documented pattern for CSS-variable + opacity-modifier support),
      // but this version's Config type doesn't model that variant — hence
      // the cast. See withOpacity() above.
      colors: {
        void: withOpacity("--void-rgb"),
        deep: withOpacity("--deep-rgb"),
        smoke: withOpacity("--smoke-rgb"),
        bone: withOpacity("--bone-rgb"),
        "bone-2": withOpacity("--bone-2-rgb"),
        ember: withOpacity("--ember-rgb"),
        "ember-deep": withOpacity("--ember-deep-rgb"),
        "ember-pale": withOpacity("--ember-pale-rgb"),
        clay: withOpacity("--clay-rgb"),
        mist: withOpacity("--mist-rgb"),
        ink: withOpacity("--ink-rgb"),
        "ink-mute": withOpacity("--ink-mute-rgb"),
        // Semantic layer (03_DESIGN_SYSTEM) — plain var() since nothing consumes
        // an opacity-modifier variant of these yet; add -rgb + withOpacity() if
        // a future component needs e.g. bg-surface/50.
        surface: "var(--surface)",
        "surface-2": "var(--surface-2)",
        "surface-3": "var(--surface-3)",
        fg: "var(--fg)",
        "fg-muted": "var(--fg-muted)",
        accent: "var(--accent)",
        "accent-2": "var(--accent-2)",
      } as unknown as Record<string, string>,
      fontFamily: {
        display: ["var(--font-display)", "Georgia", "serif"],
        body: ["var(--font-body)", "system-ui", "sans-serif"],
        mono: ["var(--font-mono)", "monospace"],
      },
      letterSpacing: {
        label: "0.28em",
        wide: "0.18em",
      },
      fontSize: {
        "display-xl": "clamp(72px, 16vw, 210px)",
        "display-l": "clamp(40px, 8vw, 104px)",
        "display-m": "clamp(36px, 6vw, 72px)",
        lead: ["18px", "1.6"],
        body: ["16px", "1.6"],
        caption: ["14px", "1.4"],
      },
    },
  },
  plugins: [],
};
export default config;
