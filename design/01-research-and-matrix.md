# 01 — Research Report & Ranked Comparison Matrix

Effort allocated by design value, not equally. Tier 1 = deep reverse-engineering; Tier 2 = pattern
extraction; Tier 3 = quick review.

---

## 1. Research report — all 21 sites

### Tier 1 — Deep reverse-engineering (exceptional)

**innsaei.studio (Prague)** — *Built on Tilda.*
- **Positioning:** "Yoga-portal in the centre of Prague." Place + emotion led.
- **Hero:** layered photographic collage with animated SVG accents, a sound **play button** (opt-in
  ambient audio), and an immediate **price-led trial CTA** ("Book a class for 100 CZK").
- **Trust:** stats triplet — *12+ styles · 5+ yrs avg teacher experience · central location*.
- **IA:** location-forward (map links repeated), EN/RU toggle, schedule anchor.
- **Decisions worth copying:** trial-price CTA above the fold; stats band; emotional "Imagine
  yourself in our studio" sequencing; opt-in sound as signature.
- **Weakness:** Tilda DOM is heavy; many rasterised SVG/PNG layers hurt LCP.

**highland-yoga (Atlanta/Nashville, multi-location)** — *Best conversion engine in the set.*
- **Positioning:** "Hot Power Yoga · Sculpt · Strength," the HY Method.
- **Conversion:** crossed-out anchor pricing (**~~$169~~ → $30, 1 month**), a dedicated **"For New
  Students"** path, a **"Find a Studio"** locator, and testimonials with strong specificity.
- **Content:** feature quartet (Flow&Core / Studio / Heat / Vibe) — scannable value props.
- **Decisions worth copying:** intro-offer with visible savings; explicit first-timer route;
  benefit-tile quartet.
- **Weakness:** template-y visual identity; little motion personality.

**samyastudios (London/Islington)**
- **Positioning:** neighbourhood studio, poetic and warm.
- **Patterns:** **running promo marquee** ("10 classes for £100"), a **"Which class is right for
  me?"** finder, a literary **quote block** (Rupi Kaur), and class copy with real personality
  ("vinyasa flow but swimming in syrup").
- **Decisions worth copying:** promo marquee; class-finder; voice; treatments cross-sell.

**herspace (Munich)** — *Strongest values/brand narrative.*
- **Positioning:** "A studio designed by women, for women."
- **Patterns:** manifesto-grade mission copy, **"featured in" press strip**, **welcome package**
  (15 credits at a discount), and a **state-based finder** ("find what you need *right now*",
  cycle-aware).
- **Decisions worth copying:** press/credibility strip; need-state entry; welcome bundle.

**threejewels (NYC, since '96)** — *Depth & lineage storytelling.*
- **Patterns:** **six-pillar IA** (Classes / On-Demand / Courses / Retreats / Trainings / Service),
  "Not your average yoga studio" voice, world-tour schedule.
- **Decisions worth copying:** multi-format IA; lineage/credibility narrative; service/community as a pillar.

### Tier 2 — Pattern extraction (good, not exceptional)

- **wearealma** (Framer) — **numbered editorial index** + large-image **hover-reveal gallery**; ultra-minimal HOME/ABOUT/CONTACT nav. *Borrow:* gallery hover captions + numbered indexing.
- **openstudiosberlin ("OPEN", 8 spaces)** — **"Choose your space" booking chooser**, class-type tiles (Pilates/Yoga/Sculpt/Sound/Red), inclusivity statement, newsletter. *Borrow:* space/segment chooser pattern (only if Divinity goes multi-location); newsletter.
- **balance-group (DE, 23 yrs)** — **studios grid** locator, academy IA, **typed contact form** with an inquiry-type dropdown, careers. *Borrow:* inquiry-type field on contact; academy/teacher-training IA.
- **myawellbeing** — Movement/Meditation/Programs triad, **free online trial**, founder bios, structured programs (3-week beginner). *Borrow:* program/cohort structure; founder credibility; free-trial framing.
- **panijoga (Radom, PL — Iyengar)** — **certification trust badge**, **beginner intro course with a START date**, FAQ, address + map, Iyengar quote. *Borrow:* dated foundations course; certification trust; FAQ+map pairing.
- **ourano (Brisbane, since 2010)** — poetic **newsletter** voice, holistic-therapy offerings, private-class CTA, events. *Borrow:* newsletter tone; private-session CTA.
- **casadelmoviment (Barcelona)** — **50%-refund incentive** (first drop-in credited to membership), shop, YTT. *Borrow:* drop-in→membership incentive copy.
- **sacredspacemiami** — **Evolve · Nourish · Grow** triad, Space/Farm/Shop IA, destination/events storytelling, non-profit foundation. *Borrow:* triad spine reinforcement; events IA.

### Tier 3 — Quick review (average / niche)

- **livingbarreandyoga (Brisbane)** — inclusive "every body welcome" voice; **per-class intensity labels**; community/retreats. *Borrow:* intensity tags.
- **thegoddessmovement (pole/heels)** — bold, fearless, inclusive brand voice; community-as-product. *Borrow:* voice courage (tone reference only).
- **mindfulflowwithangie (Singapore, solo)** — anatomy-led personal brand; **lead magnet** ("subscribe → free 30-min practice"); named testimonials; "Scroll" cue. *Borrow:* lead-magnet newsletter; named testimonials.
- **practicefeelglow (DE, solo)** — **Practice · Feel · Glow** three-word spine (validates Divinity's Align/Awaken/Ascend device); personal story; newsletter.
- **yogamaya (NYC, Chelsea)** — **intro-offer popup** ("2 weeks $59"). *Borrow:* intro-offer (non-intrusive variant).
- **glowflowyoga (DE)** — glow/warmth theme (light read; partial crawl).

### Excluded from detailed audit (not crawlable)
- **aoustudio.com** — JS-only Wix shell, no extractable content.
- **hale.now** — HTTP 503 / blocked.

---

## 2. Ranked comparison matrix

Winner + runner-up per category, across the 19 analysed sites. Performance/Accessibility are
**stack-inferred** (see integrity note in README), not measured on third-party domains.

| Category | 🥇 Winner | 🥈 Runner-up | Why |
|---|---|---|---|
| **Best Hero** | innsaei | herspace | Layered, emotive, trial-CTA + sound; herspace = manifesto power |
| **Best Navigation** | wearealma | OPEN | Radical minimal index; OPEN's space-chooser is clearest multi-loc nav |
| **Best Booking** | highland-yoga | OPEN | Intro-offer + new-student path; OPEN's "choose your space" flow |
| **Best Motion** | innsaei | wearealma | Animated hero/sound; Framer hover-reveal craft |
| **Best Storytelling** | herspace | threejewels | Values manifesto; Three Jewels' lineage depth |
| **Best Mobile** | highland-yoga | samya | Clean conversion-first mobile; Samya's marquee/finder scale well |
| **Best Typography** | wearealma | samya | Editorial restraint; Samya's warm serif/sans mix |
| **Best Colours** | sacredspacemiami | glowflowyoga | Earthy lush palette; glow warmth |
| **Best Forms** | balance-group | herspace | Typed inquiry routing; herspace welcome flow |
| **Best Gallery** | wearealma | sacredspace | Numbered hover-reveal; destination imagery |
| **Best Pricing** | highland-yoga | yogamaya | Anchor + savings; clean 2-week intro |
| **Best UX (overall)** | highland-yoga | samya | First-timer clarity end-to-end |
| **Best Accessibility** | highland-yoga | balance-group | Conventional semantics/contrast (inferred) |
| **Best Performance** | mindfulflow / practicefeelglow | highland-yoga | Lean single-purpose sites (inferred); innsaei/Framer heavier |
| **Best Premium Feeling** | innsaei | herspace | Craft + atmosphere |
| **Best Conversion** | highland-yoga | casadelmoviment | Offer + path; refund incentive |
| **Best Brand Identity** | herspace | sacredspace | Distinct POV; strong world-building |

### How Divinity already compares
Against this field, Divinity's **breathing-canvas hero, GSAP horizontal disciplines, ⌘K palette,
and breath-paced motion** would rank at/near the top for **Motion** and **Premium Feeling** today.
Its gaps are concentrated in **Booking/Conversion** and **Trust/Forms (email capture)** — precisely
where Highland, Yogamaya, herspace, and the newsletter-led solos win. That focuses the upgrade.
