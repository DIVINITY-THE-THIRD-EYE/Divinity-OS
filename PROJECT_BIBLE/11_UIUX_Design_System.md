# Phase 11 — UI/UX & Design System

> Sources: website [README](../divinity-third-eye/divinity/README.md), [design/08-design-tokens.md](../divinity-third-eye/divinity/design/08-design-tokens.md), [design/phase0/tokens.json](../divinity-third-eye/divinity/design/phase0/tokens.json), `app/globals.css`, Flutter `core/theme/`.

## Brand

**Divinity — The Third Eye.** Concept: **"Breathe"** — pranayama as the organizing metaphor. Warm **ember** (inhale/prana/light) meets cool **indigo-void** (exhale/stillness). Lotus mark recoloured ember on transparent. Founder/guru: Sachin Rajvanshi. Full brand voice + assets: [Appendix/Brand_and_Content_Library](Appendix/Brand_and_Content_Library.md).

## Colors (tokens)

| Token | Value | Meaning |
|---|---|---|
| `--void` | `#15161E` | exhale / stillness / dark ground |
| `--bone` | `#ECE7DB` | light surface / paper |
| `--ember` | `#D08A3E` | inhale / prana / accent |

(Authoritative token set: `design/phase0/tokens.json` + `app/globals.css`. Additional shades/scales `[Needs Verification]` against those files.)

## Typography

- **Cormorant** — airy light display + italic accent words.
- **Hanken Grotesk** — body.
- **JetBrains Mono** — labels + the breath counter.

Loaded via `next/font` (web, no CLS) and `google_fonts` (app). Type scale: [design/08-design-tokens.md](../divinity-third-eye/divinity/design/08-design-tokens.md).

## Icons

Lotus brand mark (`public/brand/logo-mark.png`); app uses a custom `third_eye_icon.dart` widget + `cupertino_icons`. Favicons from `app/icon.png` / `apple-icon.png`.

## Components

- **Web:** see [04_Public_Website](04_Public_Website.md) component list + [design/07-visual-pattern-library.md](../divinity-third-eye/divinity/design/07-visual-pattern-library.md) and [design/14-component-dependency-map.md](../divinity-third-eye/divinity/design/14-component-dependency-map.md).
- **App:** `shared/widgets/` reusable set — `spring_tap` (tactile press), `shimmer_loading` (skeletons), `animated_list_item`, `loading_widget`, `notification_bell`, `third_eye_icon`.

## Motion

- **Principle:** restrained; every motion ties to "Breathe"; `prefers-reduced-motion` always respected.
- **Web:** Framer Motion + GSAP/ScrollTrigger + Lenis. Signatures: breathing hero (4-4-6), horizontal-scroll disciplines, velocity marquee, manifesto reveal, magnetic CTA, custom cursor, scroll progress, intro curtain. Spec: [design/10-motion-spec.md](../divinity-third-eye/divinity/design/10-motion-spec.md), inventory: [design/phase0/motion-inventory.md](../divinity-third-eye/divinity/design/phase0/motion-inventory.md).
- **App:** `flutter_animate` + custom `app_transitions` + `app_motion.dart` (`core/theme`).

## Spacing

Token-driven spacing scale in `design/08-design-tokens.md` / `tokens.json`. `[Needs Verification]` for exact scale values.

## Responsive Rules

Mobile-first; web responsive to mobile (README accessibility note). Breakpoints via Tailwind defaults + custom config (`tailwind.config.ts`). App adapts via Flutter layout.

## Accessibility Standards

WCAG 2.2 AA target. Keyboard focus rings, focus trap, reduced-motion, semantic landmarks. Audit + baseline: [design/09-accessibility-audit.md](../divinity-third-eye/divinity/design/09-accessibility-audit.md), [design/phase0/accessibility-baseline.md](../divinity-third-eye/divinity/design/phase0/accessibility-baseline.md). See also the scoped `Divinity:accessibility` and `Divinity:10k-checklist` skills.

## Design Tokens

Frozen in [design/phase0/design-token-freeze.md](../divinity-third-eye/divinity/design/phase0/design-token-freeze.md) + `tokens.json`. Single source feeding `globals.css` (web) and `app_theme.dart` (app). **Do not** introduce ad-hoc colors — extend tokens. (Locked per AI_CONTEXT §8.)

## Theme

No user theme toggle (ADR-0012) — the dark, breath-paced aesthetic is the identity. App theming via `theme_provider.dart` + `app_theme.dart`.
