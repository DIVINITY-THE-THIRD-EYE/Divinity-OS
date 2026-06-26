# 07 — Visual Pattern Library (capture-ready)

A reusable, screenshot-backed library. **Integrity note:** external-site screenshots can't be captured
in this session (no headless browser bridge available, scrape token invalid). Rather than fabricate
images, each pattern below is a **capture-ready card**: an image slot, the **exact deep link**, what to
shoot, an **ASCII wireframe**, why it works, where to apply in Divinity, and complexity. Add the PNG to
`assets/patterns/` (see its README) and the image renders automatically.

Divinity's **own** patterns *can* be screenshotted locally (run `npm run dev`, then the preview/DevTools
capture) — recommended for the "after" column.

Legend: 🟢 low · 🟡 medium · 🔴 high complexity.

---

### P01 — Intro-offer system (promo bar + hero CTA + sticky mobile bar) 🟡
![P01](assets/patterns/p01-intro-offer.png)
- **Capture:** highland-yoga.com (hero offer "~~$169~~ $30") · yogamaya.com (2-week popup) · samyastudios.com (top promo marquee). Shoot the hero + sticky elements on mobile.
- **Wireframe:**
  ```
  ┌─ promo bar: "First class on us — Book a free intro"      [×] ─┐
  │ HERO  H1 ........  [Book your first class] [Explore]         │
  └──────────────────────────────────────────────────────────────┘
  (mobile) ▁▁▁▁▁ sticky: [ Book ]  [ WhatsApp ] ▁▁▁▁▁
  ```
- **Why it works:** a low-commitment first step is the top driver of studio sign-ups; persistent CTA removes "where do I start?".
- **Apply:** `PromoBar`, `StickyCta`, hero CTA (R1).

### P02 — Proof / stats band 🟢
![P02](assets/patterns/p02-stats.png)
- **Capture:** innsaei.studio (12+ styles · 5+ yrs). Shoot the metrics strip.
- **Wireframe:** `[ Est. 2024 ] [ 6 disciplines ] [ 20+ classes/wk ] [ all levels ]`
- **Why:** quantified credibility before the ask. **Apply:** `Stats` (R2).

### P03 — Lead-magnet newsletter 🟡
![P03](assets/patterns/p03-newsletter.png)
- **Capture:** mindfulflowwithangie.com (subscribe → free 30-min practice) · ourano newsletter block.
- **Wireframe:** `"Begin with breath — a free guided practice" [ email ] [ Send ]  ✓ status`
- **Why:** captures top-of-funnel intent with an on-brand gift (breath, not a discount). **Apply:** `Newsletter` + Brevo (R3).

### P04 — Need-state onboarding chooser 🟡
![P04](assets/patterns/p04-starthere.png)
- **Capture:** headspace.com ("What kind of headspace are you looking for?") · herspace ("find what you need right now").
- **Wireframe:** `New here? → [ For the body ] [ For the breath ] [ For healing ] → Book first class`
- **Why:** routes first-timers by intent in one tap. **Apply:** `StartHere` (R4), reuse Disciplines' intention groups.

### P05 — Hover-reveal + numbered gallery + lightbox 🟡
![P05](assets/patterns/p05-gallery.png)
- **Capture:** wearealma.com (numbered index, hover-reveal). Shoot hover state + an open large image.
- **Wireframe:** `grid [img 01][img 02][img 03] → hover: caption fades in → click: ⤢ lightbox (ESC, ←/→)`
- **Why:** turns a passive grid into an explorable space. **Apply:** `Gallery` + `Lightbox` (R6).

### P06 — Intensity / level tags on classes 🟢
![P06](assets/patterns/p06-intensity.png)
- **Capture:** livingbarreandyoga.com.au (per-class intensity labels).
- **Wireframe:** `Vinyasa Flow  ● Vigorous · All levels`
- **Why:** instant self-qualification (text + colour, not colour alone). **Apply:** `Disciplines` + `lib/content.ts` (R5).

### P07 — Attributed wisdom quote 🟢
![P07](assets/patterns/p07-quote.png)
- **Capture:** samyastudios.com (Rupi Kaur block) · panijoga.pl (Iyengar).
- **Wireframe:** `“ … one quiet full-bleed line … ”  — B.K.S. Iyengar`
- **Why:** rhythm + lineage credibility. **Apply:** `Quote` (R7).

### P08 — Membership incentive / welcome bundle 🟢
![P08](assets/patterns/p08-incentive.png)
- **Capture:** casadelmoviment.com (50% first-class refund) · herspace (welcome 15 credits).
- **Wireframe:** `"Your first drop-in is credited to your membership."`
- **Why:** bridges drop-in → recurring; lowers cost-of-trying. **Apply:** `Membership` copy (R8).

### P09 — Sticky purchase/CTA bar (scroll-following) 🟡
![P09](assets/patterns/p09-stickybar.png)
- **Capture:** apple.com/airpods-pro (sticky buy bar) · airbnb mobile sticky CTA.
- **Wireframe:** `▔▔ on scroll: [ Plan name · ₹price ]            [ Book ] ▔▔`
- **Why:** the ask is always one tap away. **Apply:** `StickyCta` (R1, mobile-first).

### P10 — Command palette (validate, already shipped) 🟢
![P10](assets/patterns/p10-palette.png)
- **Capture:** linear.app (⌘K) — and Divinity's own `CommandPalette` for the "after".
- **Wireframe:** `⌘K → [ search ] → ▸ Academy ▸ The space ▸ Membership ▸ WhatsApp`
- **Why:** power-user nav; signals product quality. **Apply:** already present — keep parity (fuzzy, arrows, hints).

### P11 — Customer-proof marquee / logos 🟢
![P11](assets/patterns/p11-proof.png)
- **Capture:** stripe.com (logo marquee) · herspace ("featured in").
- **Wireframe:** `‹ press / certification logos scrolling ›`
- **Why:** borrowed authority. **Apply:** `Credibility` strip — **only with real logos/accreditations** (else skip).

### P12 — Transparent trial pricing 🟢
![P12](assets/patterns/p12-trial.png)
- **Capture:** calm.com (trial terms explicit) · highland (anchor + savings).
- **Wireframe:** `Drop-in ₹200 · first class free · cancel anytime — terms shown inline`
- **Why:** trust through clarity (no dark patterns). **Apply:** `Membership`/`PromoBar` copy (R1/R8).

### P13 — Opt-in ambient sound toggle 🔴
![P13](assets/patterns/p13-sound.png)
- **Capture:** innsaei.studio (sound play button) · calm ambient.
- **Wireframe:** `◔ sound: off ⟶ on  (persisted, never autoplay)`
- **Why:** deepens the "breathe" concept for engaged users. **Apply:** `SoundToggle` (R10, off by default).

### P14 — Scroll-driven progressive disclosure 🟡
![P14](assets/patterns/p14-scroll.png)
- **Capture:** apple.com product page (pinned/scrubbed sections) — and Divinity's Disciplines (GSAP) for "after".
- **Wireframe:** `pin section → scrub content as scroll advances → release`
- **Why:** cinematic pacing, one idea per viewport. **Apply:** already present (Disciplines, Manifesto) — keep; don't over-pin.

---

## Index → recommendation → status

| Pattern | Rec | Phase | Divinity status |
|---|---|---|---|
| P01, P09, P12 | R1 | 1 | new |
| P02, P11 | R2 | 1 | new (P11 only if real assets) |
| P03 | R3 | 1 | new (reuses Brevo) |
| P04 | R4 | 2 | new |
| P06 | R5 | 2 | new field on existing comp |
| P05 | R6 | 2 | enhances existing `Gallery` |
| P07 | R7 | 3 | new |
| P08 | R8 | 2 | copy on existing comp |
| P13 | R10 | 4 | optional |
| P10, P14 | — | — | **already shipped** (validate only) |

> When screenshots are added to `assets/patterns/`, this file becomes a standalone visual design library
> usable beyond this upgrade.
