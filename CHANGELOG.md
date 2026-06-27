# Changelog

All notable changes to Divinity — The Third Eye website.

## [Unreleased] — Phase 1: Conversion & Trust

### Added
- **PromoBar** — dismissible amber promo banner (₹99 first-week offer) at page top
- **StickyCta** — mobile sticky bottom bar (WhatsApp + Book a class) visible mid-scroll, hidden past contact section
- **StatsBand** — animated count-up proof band (200+ members · 6 disciplines · 3 batches · 2+ years) between hero and marquee
- **Newsletter** — free guided pranayama lead-magnet signup with Brevo contact API (`/api/subscribe`)
- **Hero CTAs** — primary "Book a class — ₹99 first week" button + "Learn more ↓" anchor in BreathHero
- **`/api/subscribe`** — Brevo contact-add route, graceful no-key fallback matching contact route pattern
- **`BREVO_LIST_ID`** env var support for list segmentation

### Fixed
- **A11y R9** — Contact form `<select>` (intention) now has `id="contact-intention"` linked to `htmlFor` on its label; all form fields have matching `id`/`htmlFor` pairs (fixes WCAG 1.3.1 / axe `select-name` failure)
- Added `role="alert"` to form error paragraphs (`Contact`, `Newsletter`) for screen-reader announcement
- Added `aria-required="true"` to all required form fields

### Performance
- **Mobile LCP fix** — GSAP + ScrollTrigger converted to dynamic imports in `Manifesto.tsx` and `Disciplines.tsx`; removes ~218 KB from the synchronous parse/execute path on mobile, targeting LCP 4.3s → <2.5s

---

## [1.0.0] — Phase 0 Baseline — 2026-06-26

### Added
- Complete Next.js 14 App Router marketing site
- BreathHero with canvas breathing guide + studio backdrop
- Disciplines horizontal scroll (GSAP pinned)
- Gallery masonry (Framer Motion)
- Membership cards with UPI QR payment
- Contact form with Brevo email delivery
- WhatsApp FAB, command palette, smooth scroll (Lenis)
- Founder portrait, logo mark, favicons
- 12 ADRs, design dossier, Phase 0 baseline artifacts
- CI scaffold (`.github/workflows/ci.yml`)
- Git repo initialised; pushed to GitHub as `divinity-website`

### Baseline metrics (MEASURED 2026-06-26)
- Lighthouse Desktop: Perf 99 · A11y 87 · BP 100 · SEO 100
- Lighthouse Mobile: Perf 83 · A11y 87 · BP 100 · SEO 100
- First-Load JS `/`: 198 kB · LCP desktop 0.9s · LCP mobile 4.3s
