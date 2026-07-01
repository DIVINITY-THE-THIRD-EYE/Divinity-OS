# 23 — Launch Readiness Checklist

Verify before each release (and the full set before the first public launch). Gates reference the
relevant docs. ☐ = to verify.

## Performance (`11`)
- ☐ Lighthouse Perf ≥ 95 (mobile + desktop).
- ☐ LCP < 2.0 s · CLS < 0.05 · INP < 150 ms (lab + field via GSC/Vercel).
- ☐ First-Load JS ≤ 210 kB; no new heavy deps; images have `sizes`.
- ☐ `next build` clean; bundle analyzed if near budget.

## Accessibility (`09`)
- ☐ axe DevTools: 0 critical/serious on all changed pages.
- ☐ Lighthouse A11y ≥ 95.
- ☐ Full keyboard pass (no traps, visible focus, logical order); ESC closes overlays.
- ☐ Screen-reader smoke (VoiceOver/NVDA) on hero, nav, forms, lightbox.
- ☐ Reduced-motion + forced-colors verified; targets ≥ 44px.

## SEO (`03 §14`, `19`)
- ☐ Titles/descriptions/canonical correct; `site.url` set to real domain.
- ☐ JSON-LD validates (LocalBusiness/HealthClub, FAQ, Course, + Offer); Rich Results test passes.
- ☐ `sitemap.xml` + `robots.txt` correct; OG/Twitter image renders.
- ☐ Core copy server-rendered (not JS-hidden).

## Cross-browser & device
- ☐ Latest Chrome, Safari, Firefox, Edge; iOS Safari + Android Chrome.
- ☐ Breakpoints 390/768/1280/1536 visually correct (VRT `20` green).
- ☐ Touch interactions (no hover-only dependence); WhatsApp/UPI links work on mobile.

## Analytics & monitoring (`16`, `12 §8`)
- ☐ GA4/GTM firing; key events verified in DebugView (`cta_book`, `contact_submit`, `newsletter_submit`).
- ☐ Consent banner gates analytics; opt-out works.
- ☐ Sentry (or GlitchTip) capturing client + route errors; alerts configured.
- ☐ Uptime/CWV monitoring on (Vercel/GSC).

## Security (`21`)
- ☐ Rate limit + honeypot on contact/subscribe; origin check.
- ☐ Security headers + CSP live and tested.
- ☐ Secrets only in Vercel env; rotated; no client leakage; `npm audit` clean.
- ☐ Privacy policy + cookie consent published.

## Content correctness (`22` TD9–10)
- ☐ Real prices, phone, WhatsApp number, Instagram, `site.url`, entity.
- ☐ **UPI QR points to the real account** (verified with a test scan).
- ☐ Stats numbers and intro-offer terms owner-approved (true & lawful — risk K5).
- ☐ Testimonials are real/consented; founder bio accurate; Sanskrit verified.

## Resilience
- ☐ Backups configured (Sanity dataset export if used; repo is the content source-of-truth otherwise).
- ☐ **Rollback tested:** Vercel "promote previous deployment" verified; feature flags (`offer.enabled`,
  `features.sound`) toggle cleanly.
- ☐ Contact/subscribe **fallback path** verified (no key → accept+log, UI never hard-fails).

## Documentation
- ☐ This dossier updated; ADRs reflect any new decisions.
- ☐ README env vars current; runbook for "update content / offer / QR".
- ☐ Feature inventory (`17`) + tech-debt register (`22`) reconciled with what shipped.

## Sign-off
- ☐ Product/owner sign-off on offer terms, prices, QR, claims.
- ☐ Eng sign-off on perf/a11y/security gates.
- ☐ Tag release; record baseline metrics (`24`) for the 6-month review.
