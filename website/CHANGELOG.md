# Changelog

All notable changes to Divinity — The Third Eye website.

## [1.1.0](https://github.com/DIVINITY-THE-THIRD-EYE/Divinity-OS/compare/divinity-website-v1.0.0...divinity-website-v1.1.0) (2026-07-16)


### ✨ Features

* 10-phase build-out — Plans, leave rules, waitlist, certs, events payments, i18n, unified theme ([d4a769e](https://github.com/DIVINITY-THE-THIRD-EYE/Divinity-OS/commit/d4a769e2d10b46a956632cf79149101e0535a5f3))
* Hindi + English i18n on both Flutter app and website ([2c24840](https://github.com/DIVINITY-THE-THIRD-EYE/Divinity-OS/commit/2c2484060456b8d8d2213be38a0c156c5904d839))
* unified void/bone/ember design system across website and Flutter app ([974f420](https://github.com/DIVINITY-THE-THIRD-EYE/Divinity-OS/commit/974f42048a205e4bbeeb2e06bf431160fc5e061f))

## [Unreleased] — Phase 1: Conversion & Trust

### Added
- **WeatherWidget** — Open-Meteo Weather & Air Quality monitoring card on the Contact page with 15-minute client-side `localStorage` caching, fallback offline support, loading shimmers, and combined weather/AQI wellness recommendations.
- **Accessible Maps Embed** — Responsive Google Maps iframe container on the Contact page with proper accessibility titles, lazy-loading, "Open in Google Maps" redirect, and "Directions" buttons driven by location configurations.
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
