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
        // Semantic layer (03_DESIGN_SYSTEM). surface/-2/-3 need opacity-modifier
        // support (bg-surface/85 etc., used by Nav's scroll-solid state) so they
        // get the same -rgb + withOpacity() treatment as the primitives above.
        surface: withOpacity("--surface-rgb"),
        "surface-2": withOpacity("--surface-2-rgb"),
        "surface-3": withOpacity("--surface-3-rgb"),
        fg: "var(--fg)",
        "fg-muted": "var(--fg-muted)",
        accent: "var(--accent)",
        "accent-light": "var(--accent-light)",
        "accent-2": "var(--accent-2)",
        gold: withOpacity("--gold-rgb"),
      } as unknown as Record<string, string>,
      fontFamily: {
        // Display = Nunito (clay), body = DM Sans. mono aliases to body since
        // the clay/neu system has no monospace role (eyebrows use DM Sans).
        display: ["var(--font-display)", "Nunito", "system-ui", "sans-serif"],
        body: ["var(--font-body)", "system-ui", "sans-serif"],
        mono: ["var(--font-body)", "system-ui", "sans-serif"],
      },
      // Clay/neu shadow stacks — themable via the --sh-* vars (globals.css).
      boxShadow: {
        "clay-card": "var(--sh-card)",
        "clay-card-hover": "var(--sh-card-hover)",
        "clay-raised": "var(--sh-raised)",
        "clay-raised-hover": "var(--sh-raised-hover)",
        "clay-sm": "var(--sh-sm)",
        "clay-button": "var(--sh-button)",
        "clay-button-hover": "var(--sh-button-hover)",
        "clay-pressed": "var(--sh-pressed)",
        "clay-inset": "var(--sh-inset-deep)",
        "clay-inset-sm": "var(--sh-inset-sm)",
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
