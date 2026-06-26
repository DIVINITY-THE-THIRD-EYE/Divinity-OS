# 02 — Pattern Library · Design System · Component Inventory · IA

---

## 3. Reusable UI/UX pattern library

Only patterns that can improve Divinity. Each: *what it is · best reference · how Divinity applies it*.

### Conversion patterns
1. **Intro-offer hook** — price-anchored first-class/trial as the primary CTA. *Ref:* highland, yogamaya, innsaei. *Apply:* hero secondary CTA + promo bar.
2. **Dismissible promo marquee/bar** — sitewide, time-boxed, `sessionStorage`-dismissed. *Ref:* samya. *Apply:* `PromoBar`.
3. **Sticky mobile action bar** — Book / WhatsApp pinned bottom on scroll. *Ref:* highland mobile. *Apply:* `StickyCta` (complements existing `WhatsAppFab`).
4. **Drop-in → membership incentive** — "first class credited to your plan." *Ref:* casadelmoviment. *Apply:* copy in `Membership`.
5. **Welcome bundle** — discounted starter pack of credits. *Ref:* herspace. *Apply:* optional plan in `lib/content.ts`.

### Trust patterns
6. **Stats/proof band** — 3–4 metrics, count-up on view. *Ref:* innsaei. *Apply:* `Stats`.
7. **"Featured in" / certification strip** — press logos or accreditation badges. *Ref:* herspace, panijoga. *Apply:* `Credibility` (only with real assets).
8. **Named, specific testimonials** — name + tenure + concrete result. *Ref:* highland, mindfulflow. *Apply:* already present in `Voices` — strengthen specificity.

### Onboarding patterns
9. **"New here? Start here" path** — 3 steps to first class. *Ref:* highland, panijoga, MYA. *Apply:* `StartHere`.
10. **Class/need finder** — "which class is right for me?" *Ref:* samya, herspace. *Apply:* Divinity already has `PlanCalculator`; optionally extend to a discipline finder.
11. **Dated foundations course** — beginner cohort with a START date. *Ref:* panijoga, three jewels. *Apply:* card in `Schedule`/Events.

### Content & storytelling patterns
12. **Three-word spine** — Align·Awaken·Ascend. *Ref:* practicefeelglow, sacredspace (validates current device). *Apply:* keep, reinforce.
13. **Literary quote block** — one attributed line, full-bleed. *Ref:* samya, panijoga. *Apply:* `Quote`.
14. **Personality class copy + intensity tags**. *Ref:* samya, livingbarre. *Apply:* `Disciplines` + `lib/content.ts`.
15. **Lead-magnet newsletter** — "free guided breathing practice" for an email. *Ref:* mindfulflow, ourano. *Apply:* `Newsletter` + Brevo.

### Interaction patterns
16. **Hover-reveal gallery + numbered index + lightbox**. *Ref:* wearealma. *Apply:* `Gallery`.
17. **Opt-in ambient sound** (off by default). *Ref:* innsaei. *Apply:* optional `SoundToggle`.
18. **Typed contact routing** — inquiry-type dropdown drives reply-to/labels. *Ref:* balance-group. *Apply:* already partly in `Contact` (intention select) — add server-side labelling.

---

## 4. Design-system improvements

Divinity already has a coherent token core (`globals.css` `:root` + `tailwind.config.ts`). These are
**additive hardening** moves, not replacements — they formalise what exists so new components stay consistent.

### Current tokens (preserve)
```
--void #15161E  --deep #1E2029  --smoke #2A2D38
--bone #ECE7DB  --bone-2 #E2DCCB
--ember #D08A3E --ember-deep #A85E2A --ember-pale #E8C490 --clay #9C4A2A
--mist #8E93A6  --ink #20242F   --ink-mute #5C5F52
--line-dark rgba(208,138,62,.16)  --line-light rgba(32,36,47,.14)
Fonts: Cormorant (display) · Hanken Grotesk (body) · JetBrains Mono (mono)
```

### Proposed additions (tokens only — no visual change to existing UI)
| Layer | Add | Rationale |
|---|---|---|
| **Spacing** | Formalise an 8pt scale as Tailwind already follows; document section rhythm (`py-28`/`py-40`). | Consistency for new sections. |
| **Radius** | `--r-sm 2px / --r-md 4px / --r-lg 8px / --r-pill 999px`. Current UI is mostly sharp-edged; keep that as default, use radius sparingly (QR card, chips). | Prevent ad-hoc radii. |
| **Elevation** | 3 shadow tokens (`--e1` subtle card, `--e2` raised, `--e3` overlay) for light (`bone`) surfaces only — dark surfaces stay shadow-less per current style. | New cards (newsletter, stats) need a defined shadow, not invented ones. |
| **Glass** | One token recipe for overlays: `bg-void/85 + backdrop-blur-md` (already used in Nav/CommandPalette). Document it; don't proliferate blur. | Consistent overlay language. |
| **Motion** | Tokenise the existing easing/durations: `--ease-out [0.22,1,0.36,1]`, `--dur-fast 200ms / --dur-base 600ms / --dur-slow 900ms`. These are already the de-facto values in Reveal/Nav. | Single source for new animations. |
| **Focus** | Keep `:focus-visible` ember ring (already present, WCAG-friendly). Add `:focus-visible` to all new interactive elements. | A11y floor. |
| **Z-index** | Document the existing scale (nav 300, FAB 320, scrollbar 350, mobile menu 400, palette 450) and slot PromoBar `=200`, StickyCta `=310`. | Avoid stacking bugs. |

> **No neumorphism.** It conflicts with the flat, editorial, high-contrast identity and tends to fail
> contrast checks. Recommended **against** despite being in the brief.

### Design principles (codify)
1. **Breath over flash** — motion serves the concept; nothing autoplays loud.
2. **Restraint is premium** — one accent (ember), generous negative space.
3. **Every effect degrades** — `prefers-reduced-motion` is a first-class path.
4. **Content-owned** — visible strings live in `lib/content.ts` (CMS-or-fallback), never hardcoded in new components.

---

## 9. Component inventory

Existing (24 components) — **all preserved**:

| Group | Components |
|---|---|
| Chrome | `Nav`, `Footer`, `CommandPalette`, `Cursor`, `ScrollProgress`, `SmoothScroll`, `Ambient`, `IntroCurtain`, `WhatsAppFab` |
| Hero/identity | `BreathHero`, `Marquee`, `Manifesto` |
| Content | `About`, `Disciplines`, `Method`, `Schedule`, `Membership`, `PlanCalculator`, `Voices`, `Faq`, `Gallery` |
| Conversion | `Contact` |
| Utility | `Reveal`, `Magnetic`, `JsonLd` |

Proposed **new** components (additive, typed, modular):

| New | Purpose | Tier |
|---|---|---|
| `PromoBar` | Dismissible intro-offer bar | 1 |
| `StickyCta` | Mobile sticky Book/WhatsApp | 1 |
| `Stats` | Proof band (count-up) | 1 |
| `Newsletter` | Lead-magnet email capture (Brevo) | 1 |
| `StartHere` | First-timer 3-step path | 2 |
| `Quote` | Attributed wisdom line | 2 |
| `Lightbox` | Accessible gallery viewer | 2 |
| `SoundToggle` | Opt-in ambient audio | 3 (optional) |

All new components: client/server boundary respected, props typed, `prefers-reduced-motion`-aware,
keyboard-operable, content from `lib/content.ts`.

---

## 10. Information-architecture review

### Current IA (single-page marketing site)
`Hero → Marquee → Manifesto → About → Disciplines → Method → Schedule → Membership → PlanCalculator
→ Voices → FAQ → Contact → Footer`, plus ⌘K palette and section anchors.

**Assessment:** strong narrative arc; good "what → how → when → price → proof → act" order. Gaps:
1. **No first-timer fast-path** — a new visitor must scroll the full story to find "how do I start?"
2. **No conversion anchor early** — the only ask is the contact form near the end.
3. **No email capture** — visitors who aren't ready to enquire leave no trace (Brevo unused for this).
4. **Disciplines lack scannable metadata** (level/intensity) for quick self-selection.

### Recommended IA (still one page; additions only)
```
[PromoBar]                     ← new, dismissible
Hero (+ intro-offer CTA)       ← CTA added
Stats                          ← new (proof)
Marquee
Manifesto / Quote              ← Quote new (optional)
About
Disciplines (+ intensity)      ← metadata added
StartHere                      ← new first-timer path
Method
Gallery (+ lightbox)
Schedule (+ Foundations date)  ← optional
Membership (+ incentive copy)
PlanCalculator
Voices
Newsletter                     ← new (capture)
FAQ
Contact
Footer
[StickyCta]                    ← new, mobile
```
Nav/`CommandPalette` already updated to include "The space" — add "Start here" anchor when 2.1 ships.
Routing stays single-page; no new routes except API `app/api/subscribe/route.ts`.
