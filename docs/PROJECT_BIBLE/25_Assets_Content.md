# Phase 25 — Assets & Content

> Sources: website `public/`, `lib/content.ts`, `sanity/schemas/`, [README "Photography & brand assets"](../divinity-third-eye/divinity/README.md). See also [Appendix/Brand_and_Content_Library](Appendix/Brand_and_Content_Library.md).

## Images

- **Brand:** `public/brand/logo-mark.png` (ember lotus, nav/footer/favicon), `public/brand/logo-full.png` (light surfaces).
- **People:** `public/founder.webp` (Sachin Rajvanshi, About).
- **Studio/practice:** `public/guru_*.webp` (guru/practice), `public/yc_*.webp` (yoga-center/space) → Gallery.
- **Payment:** `public/payment-qr.png` (UPI QR, Membership section).
- Old PNG originals (`logo.png`, `owner.png`, `payment_qr.png`) were quarantined to `EXTRA_FILES/Old Assets/` (duplicates).

## Videos

`[Needs Verification]`: no video assets found in scan.

## PDFs

`[Needs Verification]`: none committed (certificates/brochures may be future).

## Logos

See Brand above. Lotus mark = "The Third Eye" identity.

## Icons

App `third_eye_icon.dart`; web favicons `app/icon.png` / `apple-icon.png`.

## Certificates

`[Needs Verification]`: no certificate generation found (course completion certs are a possible future feature).

## Brand Assets

Tokens (void/bone/ember) + fonts + lotus mark. Full guide: [Appendix/Brand_and_Content_Library](Appendix/Brand_and_Content_Library.md), [design/08-design-tokens.md].

## CMS Content

**Sanity** (optional) manages: disciplines, plans, testimonials (schemas also for schedule + siteSettings). Fallback content in `lib/content.ts`. Override via `lib/sanity.ts` when env set.

## Copywriting

Concept-led, breath-paced voice (see README "The design"). Source of truth: `lib/content.ts`. Content strategy: [design/19-content-strategy.md](../divinity-third-eye/divinity/design/19-content-strategy.md).

## Content Workflow

1. Edit `lib/content.ts` (code) **or** Sanity Studio (no-code) → auto-override.
2. Images → `public/` via `next/image`.
3. Pre-launch content tasks in README checklist (real prices, testimonials, contact info).

## Localization

`[Needs Verification]`: English only currently.

## Media Optimization

`next/image` (AVIF/WebP, responsive, lazy). Source images already `.webp`. ADR-0007 local assets.
