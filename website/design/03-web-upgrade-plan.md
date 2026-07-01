# 03 — Website UX Upgrade Plan (Evidence-Based)

The approval artifact. Every recommendation carries the required evidence fields. All changes are
**incremental and additive**; nothing in this plan removes a working feature or alters branding,
routing, business logic, CMS, or existing SEO. Free tools only (everything below uses the current
stack: Next 14, Tailwind, Framer Motion, GSAP, Lenis, Brevo).

Legend — **Cx** complexity, **Eff** effort (dev-days), impacts scored −/0/+/++.

---

## 5. Evidence-based recommendations

### R1 — Intro-offer conversion system  ·  Priority P1
- **Current issue:** the only conversion ask is the contact form near page end; no trial hook, no persistent CTA.
- **Observed pattern:** price-anchored trial as primary CTA + dismissible promo bar + sticky mobile action bar.
- **Reference(s):** highland-yoga (~~$169~~→$30), yogamaya (2wk $59), innsaei (100 CZK), samya (promo marquee).
- **Why it works:** removes commitment friction; a low-risk first step is the #1 driver of studio sign-ups.
- **Drawbacks:** promo bars can feel pushy if undismissable or animated loudly.
- **UX impact:** ++ (clear next step from anywhere on the page).
- **Complexity:** Cx-M. **Perf:** 0 (tiny client comps, `sessionStorage`). **A11y:** + (adds labelled, focusable CTAs; bar is dismissible & not a focus trap). **SEO:** 0. **Mobile:** ++ (sticky bar is mobile-first).
- **Risk:** Low — additive; respects reduced-motion; dismiss persists per session.
- **Effort:** 1.5 d.

### R2 — Proof / stats band  ·  P1
- **Current issue:** no quick credibility signal above the long narrative.
- **Observed pattern:** 3–4 metric band with count-up on scroll-in.
- **Reference(s):** innsaei (12+ styles · 5+ yrs).
- **Why it works:** fast trust; quantified substance before the ask.
- **Drawbacks:** numbers must be truthful — use real, defensible metrics only.
- **UX impact:** + . **Complexity:** Cx-S. **Perf:** 0 (IntersectionObserver, no libs). **A11y:** + (numbers in real text; count-up disabled under reduced-motion, final value rendered). **SEO:** + (keyworded proof text). **Mobile:** + .
- **Risk:** Very low. **Effort:** 0.5 d.

### R3 — Newsletter capture + lead magnet (Brevo)  ·  P1
- **Current issue:** visitors not ready to enquire leave no contact; **Brevo is integrated but only used for the contact form.**
- **Observed pattern:** "free guided breathing practice" in exchange for an email.
- **Reference(s):** mindfulflowwithangie (free 30-min practice), ourano, livingbarre.
- **Why it works:** captures top-of-funnel intent; on-brand value (breath) instead of a generic discount.
- **Drawbacks:** needs a real deliverable (PDF/audio/link) eventually; until then, confirm-only.
- **UX impact:** + . **Complexity:** Cx-M (new `app/api/subscribe/route.ts` mirroring contact route's graceful fallback). **Perf:** 0. **A11y:** + (labelled input, status live-region). **SEO:** 0. **Mobile:** + .
- **Risk:** Low — reuses proven Brevo pattern; no key ⇒ accepted+logged (`delivered:false`), same as contact.
- **Effort:** 1 d.

### R4 — "New here? Start here" path  ·  P2
- **Current issue:** first-timers must scroll the whole story to learn how to begin.
- **Observed pattern:** compact 3-step onboarding (choose a practice → book your first class → what to bring).
- **Reference(s):** highland ("For New Students"), panijoga (intro course), MYA.
- **Why it works:** shortens time-to-action for the least-committed, highest-drop segment.
- **UX impact:** ++ . **Complexity:** Cx-S–M. **Perf:** 0. **A11y:** + (ordered list semantics, anchors). **SEO:** + (intent keywords: "new to yoga", "first class"). **Mobile:** + .
- **Risk:** Low. **Effort:** 1 d.

### R5 — Disciplines: intensity tags + personality copy  ·  P2
- **Current issue:** disciplines list lacks scannable level/intensity metadata for self-selection.
- **Observed pattern:** per-class intensity labels + voice-rich descriptions.
- **Reference(s):** livingbarre (intensity), samya ("vinyasa swimming in syrup").
- **Why it works:** faster self-qualification; warmth signals premium.
- **UX impact:** + . **Complexity:** Cx-S (extend `Discipline` type + render a chip). **Perf:** 0. **A11y:** + (chip text, not colour-only). **SEO:** + . **Mobile:** + .
- **Risk:** Very low. **Effort:** 0.5 d.

### R6 — Gallery hover captions + accessible lightbox  ·  P2
- **Current issue:** gallery images have alt text but no visible captions and no enlarge-on-click.
- **Observed pattern:** numbered editorial index, hover-reveal caption, click-to-lightbox.
- **Reference(s):** wearealma, balance-group.
- **Why it works:** turns a passive grid into an explorable space; supports the "see the studio" goal.
- **Drawbacks:** lightbox must trap focus and restore it correctly.
- **UX impact:** + . **Complexity:** Cx-M. **Perf:** 0/− (lazy; full-res only on open — guard with `sizes`/priority off). **A11y:** + if done right (focus trap, ESC, `role=dialog`, `aria-label`). **SEO:** 0. **Mobile:** + (tap-to-zoom).
- **Risk:** Low–Med (focus management). **Effort:** 1 d.

### R7 — Attributed wisdom quote  ·  P3
- **Current issue:** none (enhancement) — a quiet beat between sections.
- **Observed pattern:** single full-bleed attributed line.
- **Reference(s):** samya (Rupi Kaur), panijoga (Iyengar).
- **Why it works:** rhythm + credibility via lineage.
- **UX impact:** + (perceived quality). **Complexity:** Cx-S. **Perf:** 0. **A11y:** + (`<blockquote>`/`<cite>`). **SEO:** 0. **Mobile:** + .
- **Risk:** Very low. **Effort:** 0.25 d.

### R8 — Membership incentive copy + optional welcome bundle  ·  P2
- **Current issue:** placeholder note only; no "first step" nudge on pricing.
- **Observed pattern:** drop-in credited to membership; discounted welcome credits.
- **Reference(s):** casadelmoviment (50% refund), herspace (welcome package).
- **Why it works:** lowers perceived cost of trying; bridges drop-in → recurring.
- **UX impact:** + . **Complexity:** Cx-S (copy + optional plan in `lib/content.ts`). **Perf:** 0. **A11y:** 0/+. **SEO:** 0. **Mobile:** + .
- **Risk:** Very low (business-approval needed for the offer itself). **Effort:** 0.25 d.

### R9 — Contact: typed routing + form hardening  ·  P2
- **Current issue:** the "intention" select isn't used to label/route the lead; form lacks explicit `aria-live` status and field-level errors.
- **Observed pattern:** inquiry-type dropdown that routes/labels submissions.
- **Reference(s):** balance-group (typed inquiry form).
- **Why it works:** faster triage; better reply relevance.
- **UX impact:** + . **Complexity:** Cx-S (server-side: include intention in Brevo subject/tags; client: `aria-live`, `aria-invalid`). **Perf:** 0. **A11y:** ++ (screen-reader status, error association). **SEO:** 0. **Mobile:** + .
- **Risk:** Low. **Effort:** 0.5 d.

### R10 — Opt-in ambient breath sound  ·  P4 (experiment)
- **Current issue:** none — a signature flourish.
- **Observed pattern:** off-by-default sound toggle.
- **Reference(s):** innsaei.
- **Why it works:** deepens the "breathe" concept for engaged users.
- **Drawbacks:** audio is intrusive if mishandled; bandwidth.
- **UX impact:** + (for some). **Complexity:** Cx-M. **Perf:** − (audio asset; lazy-load on first toggle). **A11y:** must be **off by default**, labelled, persists choice, never autoplay. **SEO:** 0. **Mobile:** 0.
- **Risk:** Med. **Effort:** 1 d. *Recommend only after P1–P2.*

### R11 — Dated "Foundations" beginner course  ·  P4 (optional)
- **Current issue:** schedule has no cohort/onboarding entry with a start date.
- **Observed pattern:** dated beginner course.
- **Reference(s):** panijoga (START date), three jewels (trainings).
- **Why it works:** concrete commitment device for beginners.
- **UX impact:** + . **Complexity:** Cx-S. **Perf:** 0. **A11y:** + . **SEO:** + (Event/Course schema possible). **Mobile:** + . **Risk:** Low (needs real dates). **Effort:** 0.5 d.

---

## 11. Conversion optimisation

| Lever | Now | Action | Source |
|---|---|---|---|
| Primary CTA visibility | only at contact | persistent: hero CTA + promo bar + sticky mobile bar (R1) | highland |
| Risk reversal | none | intro offer / first-class incentive (R1, R8) | yogamaya, casadelmoviment |
| First-timer path | none | StartHere (R4) | highland, MYA |
| Lead capture | contact only | newsletter lead magnet (R3) | mindfulflow |
| Social proof placement | testimonials late | stats band early (R2) + specific testimonials | innsaei |
| Self-qualification | minimal | intensity tags (R5) + existing PlanCalculator | livingbarre |

**Measurement (free):** GA4 + GTM events on `cta_book`, `promo_dismiss`, `newsletter_submit`,
`contact_submit`, plus PostHog free for funnels. Wire as a thin `track()` util; no PII.

---

## 12. Accessibility audit (WCAG 2.2 AA)

Current build is already strong (focus-visible ember ring, reduced-motion globally, semantic sections).
Findings + fixes (all to land **with** the new work):

| Issue | WCAG | Severity | Fix |
|---|---|---|---|
| Custom cursor hides native cursor | 2.4.7/1.4 | Med | Already gated to fine-pointer; ensure focus ring always visible (present). Verify new comps don't set `cursor:none` on interactive. |
| `Marquee`/`Ambient`/breath canvas motion | 2.3.3 | Med | Already respect reduced-motion; extend same guard to `Stats` count-up, `PromoBar`, `StickyCta`, `SoundToggle`. |
| Form status feedback | 4.1.3 | Med | Add `aria-live="polite"` status + `aria-invalid`/error ids to `Contact` and `Newsletter` (R9, R3). |
| Color-only meaning | 1.4.1 | Low | Intensity tags (R5) must include text, not just colour. |
| Target size | 2.5.8 (2.2) | Low–Med | Sticky CTA + promo dismiss ≥ 24×24px (use ≥44px touch). |
| Lightbox focus | 2.4.3/2.1.2 | Med | Focus trap, ESC close, return focus to trigger (R6). |
| Heading order | 1.3.1 | Low | New sections use a single `<h2>`; keep one `<h1>` (hero). |
| Link purpose | 2.4.4 | Low | Footer Instagram/WhatsApp now have real hrefs (done); give icon-only controls `aria-label`. |
| Skip link | 2.4.1 | Low | Add a visually-hidden "Skip to content" before `Nav`. |

**Target:** zero axe-core criticals; manual keyboard pass on all new components.

---

## 13. Performance plan (Core Web Vitals)

Current strengths: `next/font` (no CLS), static prerender, `next/image` everywhere, route prefetch.

| Area | Action | Why |
|---|---|---|
| **LCP** | Hero studio image already `priority`. Keep new above-the-fold additions text-first; promo bar must not push hero image render. Add explicit `sizes` on all new `Image`s. | Protect LCP. |
| **Gallery weight** | Sources are 4000–6000px webp; ensure `sizes` caps optimisation; lightbox loads full-res **only on open**. | Avoid over-fetching. |
| **JS budget** | All new comps are small client islands; avoid adding animation libs (reuse Framer Motion/GSAP already bundled). No new heavy deps. | Keep First-Load JS (~198 kB today) flat. |
| **Sound asset (R10)** | Lazy-load audio on first user toggle only. | No idle cost. |
| **Fonts** | Already `display:swap`, subset latin. Keep weights minimal when adding UI. | No regressions. |
| **Verify** | Run `next build` + Lighthouse (free) before/after each phase; budget: LCP < 2.5s, CLS < 0.1, INP < 200ms. | Evidence-based. |

---

## 14. SEO plan

Current: metadata, canonical, JSON-LD (LocalBusiness/HealthClub, FAQPage, Course), dynamic OG,
sitemap/robots. **Preserve all.** Additions:

| Action | Benefit |
|---|---|
| Add **Offer** to existing JSON-LD (intro offer / membership prices) | Rich-result eligibility for pricing. |
| `Stats`, `StartHere`, intensity copy add **intent keywords** ("first yoga class Lucknow", "beginner yoga") | Long-tail capture. |
| If R11 ships: add **Event**/**Course** schema for Foundations cohort | Event rich results. |
| Newsletter & promo are client islands → keep **content in SSR/SSG**; don't hide core copy behind JS | Crawlability. |
| Keep single `<h1>` (hero) and one `<h2>` per new section | Clean outline. |
| `alt` text already meaningful on gallery (done) | Image SEO. |

No URL changes ⇒ **no redirects, no SEO risk.**

---

## 15. Prioritised roadmap

### Phase 1 — High impact / low risk (quick wins)  ~3.5 dev-days
- R1 Intro-offer system · R2 Stats band · R3 Newsletter (Brevo) · R9 (form a11y portion) · skip link.
- **Exit:** persistent conversion path + lead capture + a11y status live; `next build` + Lighthouse green.

### Phase 2 — High impact (major UX)  ~3 dev-days
- R4 StartHere · R5 intensity tags + copy · R8 incentive copy · R9 typed routing · R6 gallery lightbox.
- **Exit:** first-timer path, self-qualification, explorable gallery.

### Phase 3 — Premium enhancements (motion/story/refinement)  ~1.5 dev-days
- R7 wisdom quote · micro-interaction polish (card hovers, magnetic on new CTAs) · motion-token cleanup.

### Phase 4 — Optional experiments  ~1.5–2 dev-days
- R10 opt-in ambient sound · R11 dated Foundations course (+ schema) · optional analytics (PostHog free).

---

## 16. File-by-file modification plan

> ➕ new · ✏️ edit · 🔒 do-not-touch logic (only additive props)

**Phase 1**
- ➕ `components/PromoBar.tsx` — dismissible bar; `sessionStorage`; reduced-motion aware.
- ➕ `components/StickyCta.tsx` — mobile-only sticky Book/WhatsApp; appears past hero (reuse `WhatsAppFab` scroll logic).
- ➕ `components/Stats.tsx` — IntersectionObserver count-up; final value rendered for reduced-motion/SSR.
- ➕ `components/Newsletter.tsx` — email form; `aria-live` status.
- ➕ `app/api/subscribe/route.ts` — Brevo contact add; graceful fallback (mirror `app/api/contact/route.ts`).
- ✏️ `lib/content.ts` — add `offer`, `stats[]`, `newsletter` copy (typed). 🔒 keep existing exports.
- ✏️ `components/BreathHero.tsx` — add secondary intro-offer CTA (keep canvas + existing copy).
- ✏️ `app/page.tsx` — mount `PromoBar` (top), `Stats` (after hero), `Newsletter` (before FAQ), `StickyCta` (end). 🔒 keep Sanity fetch + order otherwise.
- ✏️ `app/layout.tsx` — add skip-link target/markup. 🔒 keep fonts/metadata/JsonLd.
- ✏️ `components/Contact.tsx` — `aria-live` status + `aria-invalid` (no logic change).
- ✏️ `app/globals.css` — add motion/radius/elevation tokens + `.sr-only`/skip-link styles.

**Phase 2**
- ➕ `components/StartHere.tsx`, ➕ `components/Lightbox.tsx`.
- ✏️ `components/Disciplines.tsx` + `lib/content.ts` — add `intensity` to `Discipline` (optional field; back-compat).
- ✏️ `components/Gallery.tsx` — hover caption + lightbox trigger (keep masonry/aspect logic).
- ✏️ `components/Membership.tsx` + `lib/content.ts` — incentive copy / optional welcome plan.
- ✏️ `app/api/contact/route.ts` — include `intention` in Brevo subject/tags. 🔒 keep fallback behaviour.
- ✏️ `components/Nav.tsx` + `components/CommandPalette.tsx` — add "Start here" anchor.

**Phase 3–4**
- ➕ `components/Quote.tsx`, ➕ `components/SoundToggle.tsx` (optional), ➕ `lib/track.ts` (optional analytics).
- ✏️ `components/JsonLd.tsx` — add Offer (+ Event/Course if R11). 🔒 keep existing graph.
- ✏️ `app/page.tsx` — mount `Quote` (and Foundations card in `Schedule` if R11).

**Never touched:** `lib/sanity.ts`, sitemap/robots, `opengraph-image.tsx`, `tailwind.config.ts`
color tokens, existing animation internals (BreathHero canvas, Manifesto GSAP, Disciplines scroll).

---

## 17. Risk register

| ID | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| K1 | Promo bar/sticky CTA feel intrusive | Med | Med | Dismissible + session-persist; subtle entrance; off under reduced-motion. |
| K2 | New above-fold elements regress LCP/CLS | Low | High | Text-first; reserved heights; `next build`+Lighthouse gate per phase. |
| K3 | Lightbox focus-management bugs | Med | Med | Use a tested focus-trap pattern; keyboard QA; ESC + return focus. |
| K4 | Brevo subscribe abuse/spam | Med | Low | Honeypot + basic rate-limit in route; double-opt-in later. |
| K5 | Stats/offer claims inaccurate | Low | High (trust/legal) | Only real, owner-approved numbers/offers before launch. |
| K6 | Audio autoplay / a11y violation (R10) | Low | High | Off by default, explicit toggle, persisted, never autoplay. |
| K7 | Scope creep into dashboards/app | Med | High | Hard out-of-scope boundary (see 04 doc); marketing site stays static. |
| K8 | New strings bypass CMS | Low | Low | All copy added to `lib/content.ts` (CMS-or-fallback). |
| K9 | Token additions clash with existing UI | Low | Low | Tokens are additive; defaults unchanged; visual diff review. |

---

## 18. Estimated timeline

Assumes one developer, sequential phases, with `next build` + Lighthouse/axe gate between each.

| Phase | Scope | Effort | Calendar (1 dev) |
|---|---|---|---|
| 1 | Conversion + trust + a11y status | ~3.5 d | Week 1 |
| 2 | First-timer, self-qualify, gallery | ~3 d | Week 2 |
| 3 | Premium polish | ~1.5 d | Week 2–3 |
| 4 | Optional experiments + analytics | ~1.5–2 d | Week 3 |
| — | QA, Lighthouse/axe, content sign-off | ~1 d | rolling |
| **Total** | | **~10–11 dev-days** | **~3 weeks** |

> Phases are independently shippable. Phase 1 alone closes the biggest competitive gap (conversion + capture).
