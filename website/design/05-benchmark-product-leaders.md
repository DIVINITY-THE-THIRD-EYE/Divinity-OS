# 05 — Benchmark: Product & Interaction Leaders

Used **only** for interaction quality, motion, onboarding, navigation, accessibility, and product
polish — **not** for yoga branding or content. Each entry: positioning → the patterns worth borrowing →
the specific Divinity application. Grounded by fetch where possible; patterns marked *(canonical)* are
well-documented public behaviours of these products.

---

### Apple (apple.com product pages) — weighted 9.0
- **Positioning:** product storytelling as cinema.
- **Borrow:** **scroll-driven progressive disclosure** (sections reveal/scrub as you scroll), huge
  restrained type, generous negative space, **sticky purchase/CTA bar** that follows the scroll,
  pinned media that scrubs *(canonical)*.
- **Divinity application:** Divinity already does scroll-reveal (Reveal) + GSAP pin (Disciplines). Add a
  **sticky CTA bar** (R1) in the same spirit; keep the "one idea per viewport" pacing for new sections.

### Linear (linear.app) — 8.9
- **Positioning:** "the system for product development," speed + keyboard-first.
- **Borrow:** the **⌘K command palette** (canonical origin of the pattern), keyboard-first everything,
  **speed as a feature**, restrained dark UI, **inline product demo** that animates real UI on the page.
- **Divinity application:** Divinity **already ships a ⌘K palette** — validate it against Linear's bar
  (fuzzy match, arrow keys, hints; all present). Keep "speed/quiet" as a design value in `08-design-tokens`.

### Stripe (stripe.com) — 8.8
- **Positioning:** "financial infrastructure," developer-grade polish.
- **Borrow:** **animated gradient-mesh backdrop**, **customer-logo proof marquee**, immaculate grid &
  vertical rhythm, fast first paint, tabs for code/feature variants *(canonical)*.
- **Divinity application:** the ember **ambient gradient** Divinity already has is the same instinct —
  keep it tasteful. Borrow the **proof marquee** idea for the `Stats`/`Credibility` band (R2).

### Airbnb (airbnb.com) — 8.8
- **Positioning:** search-first marketplace; a mature Design Language System.
- **Borrow:** **search/booking front-and-centre**, ruthless **card consistency**, lazy media grids,
  delightful favorite micro-interaction, sticky filter/CTA on mobile *(canonical)*.
- **Divinity application:** elevate the booking ask to the top (R1 promo bar + hero CTA); keep card
  components consistent (`08-design-tokens` component naming) as new cards (newsletter/stats) are added.

### Headspace (headspace.com) — 8.8
- **Positioning:** "lifelong guide to better mental health," playful + warm.
- **Borrow:** **need-state onboarding chooser** ("What kind of headspace are you looking for?" →
  Stress less / Sleep / Anxiety…), friendly mascot, **free-trial primacy** ("Try for $0"), category tiles.
- **Divinity application:** the **StartHere** path (R4) is Divinity's "need-state chooser" — frame entry
  by intent ("for the body / breath / healing," which already exists in Disciplines).

### Calm (calm.com) — 8.8
- **Positioning:** "#1 app for meditation and sleep," single-focus calm.
- **Borrow:** **single calming hero** (one focus, soft motion), **transparent trial pricing** with
  explicit terms, **social-proof count** ("2M+ 5-star reviews"), opt-in ambient nature audio *(canonical)*.
- **Divinity application:** validates the **opt-in ambient sound** experiment (R10, off by default) and
  the **stats band** (R2: real, specific proof). Keep trial terms explicit (risk K5).

### Raycast (raycast.com) — 8.3
- **Positioning:** "your shortcut to everything," keyboard-first launcher.
- **Borrow:** **interactive hero demo** (animated keyboard), **speed/reliability metrics** as copy
  ("think in milliseconds," "99.8% crash-free"), extensibility framing.
- **Divinity application:** present concrete proof in the `Stats` band; treat the breathing hero as the
  "interactive demo" equivalent (already a live, interactive signature).

### Vercel (vercel.com) — 8.2
- **Positioning:** "infrastructure," performance-led.
- **Borrow:** **proof-by-customer** ("Notion powers millions on Vercel"), terminal/command snippets,
  **performance as narrative**, clean dark system.
- **Divinity application:** adopt **performance budgets** as a first-class artifact (`11-performance-budgets.md`)
  — make speed a stated promise, like Vercel.

### Arc / The Browser Company (arc.net) — 8.2
- **Positioning:** "a browser that anticipates you," calm + playful.
- **Borrow:** **personality in copy**, **tweet/testimonial wall** with real handles, "clean and calm"
  restraint, delightful but non-gratuitous motion.
- **Divinity application:** strengthen `Voices` with named, specific testimonials (already named — add
  specificity); keep copy warm (Manifesto already nails this).

### Nike (nike.com) — 8.3
- **Positioning:** bold editorial commerce.
- **Borrow:** **editorial hero blocks**, fearless type scale, motion-rich storytelling, strong imagery.
- **Divinity application:** the studio gallery + hero already lean editorial; keep the type scale
  disciplined (`08-design-tokens`) so boldness reads as premium, not loud.

### Notion (notion.com) — 8.0
- **Positioning:** "AI workspace," modular + friendly.
- **Borrow:** **modular content blocks**, friendly illustration, **"try it" inline interactivity**,
  trust logos.
- **Divinity application:** keep sections modular/composable (already the component model); the
  `PlanCalculator` is Divinity's "try it" moment — keep that interactive ethos.

---

## What the leaders collectively teach Divinity (and what to ignore)

**Adopt (interaction/product):**
1. **Conversion infrastructure is non-negotiable** — sticky CTA, trial primacy, transparent pricing (Apple, Calm, Headspace, Airbnb).
2. **Speed & restraint read as premium** — keep JS lean, motion purposeful (Linear, Vercel, Arc).
3. **Proof, quantified** — customer counts, ratings, metrics (Stripe, Vercel, Calm, Raycast).
4. **Onboarding by intent** — need-state choosers reduce first-timer friction (Headspace).
5. **Performance as a stated promise** — budgets, not vibes (Vercel).

**Ignore (not Divinity's context):** marketplace search density (Airbnb), commerce catalog (Nike),
developer code tabs (Stripe), app-store funnels (Calm/Headspace) — these belong to their business
models, not a single-studio wellness site.

> Net: the leaders **raise the interaction/conversion bar**; Divinity already meets them on motion and
> brand. The gap to close is the same one the scoring matrix flags — booking, conversion, trust.
