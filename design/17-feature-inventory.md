# 17 — Feature Inventory

Master list of every feature: **Status · Owner · Dependencies · Priority · Complexity · Effort · Business
value · Tech debt · Future improvements.** Owner `—` = unassigned (assign at kickoff).
Status: ✅ shipped · 🟡 proposed (this upgrade) · 🔵 future product.

## Existing features (✅ shipped — preserve)

| Feature | Deps | Pri | Cx | Biz value | Tech debt | Future |
|---|---|---|---|---|---|---|
| Breathing-canvas hero | canvas, framer | — | M | High (signature) | none | optional Spline swap |
| Smooth scroll (Lenis) | lenis, gsap | — | M | Med | reduced-motion ok | tune lerp |
| Command palette ⌘K | framer | — | M | Med | add "Start here" entry | more actions |
| Custom cursor / magnetic | framer | — | S | Med | gated to fine-pointer | — |
| Scroll progress / ambient / grain | framer/css | — | S | Low–Med | none | — |
| Intro curtain | framer | — | S | Med | session-gated | — |
| Kinetic marquee | css/js | — | S | Low | static under RM | — |
| Manifesto (GSAP) | gsap | — | S | Med | none | — |
| About + founder portrait | next/image | — | S | High (trust) | none | — |
| Disciplines (GSAP horizontal) | gsap | — | M | High | add intensity tags (R5) | finder |
| Method (Align/Awaken/Ascend) | Reveal | — | S | Med | none | — |
| Schedule (weekly) | content | — | M | Med | static only | live (app) |
| Membership + UPI QR | next/image | — | High | High (revenue) | manual reconcile; placeholder prices | Razorpay (ADR-0006) |
| Plan calculator | framer | — | M | High | none | discipline finder |
| Voices (testimonials) | framer | — | S | Med | strengthen specificity | named photos |
| Gallery (studio/guru) | next/image | — | M | High | add lightbox (R6) | numbered index |
| FAQ | framer | — | S | Med | none | schema present |
| Contact form → Brevo | api route | — | M | High (lead) | no rate-limit/honeypot/aria-live | typed routing (R9) |
| WhatsApp FAB | framer | — | S | High (conversion) | placeholder number | — |
| SEO: JSON-LD, OG, sitemap, robots | content | — | M | High | add Offer schema | Event/Course |
| CMS-or-fallback (Sanity) | sanity | — | M | Med | schemas to extend | wire Studio |

## Proposed features (🟡 this upgrade — see `03`)

| Feature | Rec | Phase | Pri | Cx | Effort | Biz value |
|---|---|---|---|---|---|---|
| Promo bar | R1 | 1 | P1 | M | 0.5d | High (conversion) |
| Hero intro-offer CTA | R1 | 1 | P1 | S | 0.25d | High |
| Sticky mobile CTA | R1 | 1 | P1 | S | 0.5d | High |
| Proof/stats band | R2 | 1 | P1 | S | 0.5d | High (trust) |
| Newsletter + lead magnet | R3 | 1 | P1 | M | 1d | High (capture) |
| Form a11y (live status, skip link) | R9 | 1 | P1 | S | 0.5d | Med (a11y) |
| StartHere path | R4 | 2 | P2 | S–M | 1d | High (onboarding) |
| Intensity tags + personality | R5 | 2 | P2 | S | 0.5d | Med |
| Gallery lightbox | R6 | 2 | P2 | M | 1d | Med |
| Membership incentive copy | R8 | 2 | P2 | S | 0.25d | Med–High |
| Contact typed routing | R9 | 2 | P2 | S | 0.5d | Med |
| Wisdom quote | R7 | 3 | P3 | S | 0.25d | Low–Med |
| Analytics (`track`) + GA4/GTM | — | 1–4 | P2 | S | 0.5d | High (measurement) |
| PWA layer | ADR-0009 | 4 | P3 | M | 1d | Med |
| Opt-in ambient sound | R10 | 4 | P4 | M | 1d | Low–Med |
| Dated Foundations course | R11 | 4 | P4 | S | 0.5d | Med |

## Future product (🔵 separate app — ADR-0011)
Auth, student/trainer/admin dashboards, live booking, QR attendance, payments automation, on-demand
library, breathwork/meditation, progress/streaks, health/wearables, community/chat, notifications,
events/tickets, teacher-training applications, AI modules (`13`). Pri/effort estimated at product kickoff.

## Rollup
- ✅ 21 shipped features (the current site is feature-complete as a marketing site).
- 🟡 16 proposed upgrades (~10–11 dev-days, `03 §18`).
- 🔵 ~15 future-product epics (separate backlog).
