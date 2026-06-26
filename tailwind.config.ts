import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        void: "#15161E",
        deep: "#1E2029",
        smoke: "#2A2D38",
        bone: "#ECE7DB",
        "bone-2": "#E2DCCB",
        ember: "#D08A3E",
        "ember-deep": "#A85E2A",
        "ember-pale": "#E8C490",
        clay: "#9C4A2A",
        mist: "#8E93A6",
        ink: "#20242F",
        "ink-mute": "#5C5F52",
      },
      fontFamily: {
        display: ["var(--font-display)", "Georgia", "serif"],
        body: ["var(--font-body)", "system-ui", "sans-serif"],
        mono: ["var(--font-mono)", "monospace"],
      },
      letterSpacing: {
        label: "0.28em",
        wide: "0.18em",
      },
    },
  },
  plugins: [],
};
export default config;
