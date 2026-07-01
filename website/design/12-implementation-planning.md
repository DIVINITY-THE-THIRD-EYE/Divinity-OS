# 12 — Implementation Planning

Extends the Phase 1–4 roadmap (`03 §15`) with a dependency graph, milestones, sprints, QA, rollback,
analytics, A/B testing, and monitoring. All free-tooling; all incremental on the existing repo.

---

## 1. Feature dependency graph
```
tokens (08) ──┬─> PromoBar ─┐
              ├─> Stats     ├─> page.tsx mount (Phase 1)
              ├─> Newsletter─┘        │
              │     └─ app/api/subscribe (Brevo)   [indep of UI]
              ├─> StickyCta (reuses WhatsAppFab scroll logic)
              │
motion spec(10)─> all animated comps
a11y (09) ─────> all interactive comps (skip link, live regions) [cross-cutting]
              │
StartHere ──── reuses Disciplines intention groups (content.ts)
intensity tags ─ extends Discipline type (content.ts) ─> Disciplines render
Lightbox ───── enhances Gallery (independent)
Quote ──────── standalone
JsonLd Offer ─ depends on offer copy in content.ts (shared w/ PromoBar)
SoundToggle ── standalone (Phase 4)
analytics(track)─ wraps CTA/submit events (after Phase 1 comps exist)
```
**Critical path:** `tokens → content.ts (offer/stats/newsletter) → Phase 1 comps → page mount → QA gate`.
Everything else is parallelizable.

## 2. Milestones
- **M1 — Conversion live** (end Phase 1): promo bar + hero CTA + sticky CTA + stats + newsletter shipped; Lighthouse/axe green; analytics firing.
- **M2 — First-timer & self-qualify** (end Phase 2): StartHere, intensity tags, incentive copy, typed contact routing, gallery lightbox.
- **M3 — Premium polish** (end Phase 3): quote, micro-interactions, motion-token cleanup.
- **M4 — Experiments** (end Phase 4): opt-in sound, Foundations course + schema, PostHog funnels, optional A/B.

## 3. Sprint plan (2 × 1-week sprints + buffer; 1 dev)
**Sprint 1 (Phase 1, ~3.5 d + QA):**
- Day 1: tokens in `globals.css`; `content.ts` offer/stats/newsletter; skip link.
- Day 2: PromoBar + StickyCta + hero CTA.
- Day 3: Stats + Newsletter + `api/subscribe` (Brevo fallback).
- Day 4: a11y wiring (live regions, targets), Lighthouse/axe gate, analytics events. → **M1**

**Sprint 2 (Phase 2, ~3 d + QA):**
- Day 1: StartHere + intensity tags (content.ts + Disciplines).
- Day 2: Gallery hover + Lightbox (focus trap).
- Day 3: Membership incentive copy, typed contact routing, Nav/palette "Start here". → **M2**

**Buffer / Phase 3–4:** quote + polish; optional sound/Foundations/analytics deepening. → **M3/M4**

## 4. QA checklist (per PR)
- [ ] `next build` passes; First-Load JS ≤ 210 kB (`11`).
- [ ] Lighthouse: Perf ≥95, A11y ≥95, SEO 100, BP ≥95.
- [ ] axe DevTools: 0 critical/serious on changed pages.
- [ ] Keyboard pass: no traps, visible focus, logical order; ESC closes overlays.
- [ ] Screen-reader smoke (VoiceOver/NVDA) on new comp.
- [ ] Reduced-motion: every new animation has static fallback.
- [ ] Mobile (390px) + tablet (768px) + desktop (1280px) visual check; targets ≥44px.
- [ ] Reduced-motion + forced-colors render checked.
- [ ] Copy sourced from `lib/content.ts` (no hardcoded strings).
- [ ] No regression to existing features (hero canvas, palette, smooth scroll, contact).

## 5. Rollback plan
- **VCS:** each rec is an isolated, revertible commit/PR; squash-merge per feature.
- **Flags (lightweight):** gate risky/experimental comps (PromoBar offer, SoundToggle) behind a boolean
  in `lib/content.ts` (e.g. `offer.enabled`, `features.sound`) so they disable without a deploy/revert.
- **Vercel:** instant **rollback to previous deployment** if a release regresses CWV/UX.
- **Data:** `api/subscribe` failure = graceful (accept+log, `delivered:false`) — never blocks the user, mirrors contact route.
- **Trigger:** any breach of perf gate, axe critical, or contact/subscribe error rate spike → rollback + fix forward.

## 6. Analytics events (GA4 + GTM, free; PostHog optional)
Thin `lib/track.ts` wrapper; **no PII**; respects consent.
| Event | Params | Fires on |
|---|---|---|
| `promo_view` / `promo_dismiss` | `offer_id` | bar shown / dismissed |
| `cta_book` | `location` (hero/promo/sticky/membership) | any Book CTA |
| `whatsapp_click` | `location` | FAB/sticky/footer |
| `newsletter_submit` | `status` | subscribe attempt |
| `contact_submit` | `intention`, `status` | enquiry |
| `plan_calculator_complete` | `recommended_plan` | existing PlanCalculator |
| `gallery_open` | `index` | lightbox open |
| `section_view` | `id` | major sections (sampled) |
**Funnels:** view → CTA → contact/subscribe. **KPIs:** CTA CTR, enquiry rate, newsletter rate, scroll depth.

## 7. A/B testing plan (free)
- **Tooling:** PostHog free experiments **or** GA4 + a tiny content-flag (`offer.variant`) in `content.ts`.
- **Test 1:** intro-offer copy ("first class free" vs "first class ₹X") — metric: `cta_book` CTR → enquiry.
- **Test 2:** newsletter incentive ("free breathing practice" vs none) — metric: `newsletter_submit` rate.
- **Test 3:** sticky CTA presence on mobile — metric: enquiry rate, bounce.
- **Discipline:** one variable at a time; min sample before calling; guard against CWV regressions per variant.

## 8. Monitoring plan (free tiers)
- **Uptime/CWV field data:** Vercel Analytics (free tier) or **Google Search Console** Core Web Vitals report.
- **Errors:** Sentry free dev tier (or GlitchTip FOSS) for client + API route exceptions; alert on subscribe/contact error spikes.
- **Synthetic:** Lighthouse CI in GitHub Actions on each PR + nightly on `main`.
- **Search health:** GSC coverage + structured-data reports (validate JSON-LD Offer/Event after `14`).
- **Review cadence:** weekly CWV + funnel review during rollout; monthly thereafter.
