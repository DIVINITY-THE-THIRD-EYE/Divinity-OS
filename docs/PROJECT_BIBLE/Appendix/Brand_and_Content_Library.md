# Appendix — Brand & Content Library

> Approved brand identity, voice, and content references. Sources: website [README](../../website/README.md), `design/08-design-tokens.md`, `lib/content.ts`, `public/`.

## Identity

- **Name:** Divinity — The Third Eye
- **What:** Yoga, fitness & wellness academy, **Lucknow, India**
- **Guided by:** Sachin Rajvanshi (founder / lead guru)
- **Mark:** lotus, recoloured **ember on transparent** (`public/brand/logo-mark.png`); full lockup `public/brand/logo-full.png`
- **Concept:** **"Breathe."** — pranayama as the soul of brand + product

## Color palette (tokens)

| Token | Hex | Meaning |
|---|---|---|
| `--void` | `#15161E` | exhale · stillness · dark ground |
| `--bone` | `#ECE7DB` | light surface · paper |
| `--ember` | `#D08A3E` | inhale · prana · warm accent |

> Palette intent: warm **ember** (inhale/prana/light) meeting cool **indigo-void** (exhale/stillness). Extend via tokens only — don't add ad-hoc colors. Full scale: `design/phase0/tokens.json`.

## Typography

| Family | Use |
|---|---|
| **Cormorant** | airy light display + italic accent words |
| **Hanken Grotesk** | body text |
| **JetBrains Mono** | labels + the breath counter |

## Voice & tone

- **Calm, deliberate, premium.** Restraint over spectacle ("piling on every effect reads as AI clutter").
- **Concept-anchored:** language returns to breath, stillness, intention, transformation.
- **Structure as information:** numbering only where there's a real sequence (the Method); group by intention, not decoration.
- **Inclusive:** accessible by default; respect the reader's attention and motion preferences.

### Do / Don't

| Do | Don't |
|---|---|
| Tie copy/motion to "Breathe" | Add decorative effects/numbers |
| Use the three intentions for offerings | Invent class names not in content |
| Keep it spacious and quiet | Crowd the layout / shout |
| Respect reduced-motion | Force animation |

## Signature brand moments (web)

Breathing hero (4-4-6 cadence) · GSAP horizontal-scroll disciplines · breath-paced manifesto reveal · velocity-reactive marquee · magnetic CTA + custom cursor · ambient breathing gradient + film grain · intro curtain (once per session).

## Photography & media

- **Founder:** `public/founder.webp` (About).
- **The space:** `public/guru_*.webp`, `public/yc_*.webp` → Gallery (#space). Curated in `studioGallery` (`lib/content.ts`).
- **Hero:** darkened studio shot behind the breathing canvas.
- **Payment:** `public/payment-qr.png` (UPI QR).
- **Style:** warm, calm, real academy photography; optimized to WebP via `next/image`.

## Content source of truth

- **Code:** `lib/content.ts` (single source + CMS fallback).
- **No-code:** Sanity Studio (`sanity/schemas/`: discipline, plan, testimonial, classSlot, siteSettings) overrides when configured.
- **Navigation:** `lib/nav.ts`. **SEO copy:** `lib/seo.ts`.

## Content Classification

To maintain high data integrity and comply with our product standards, website content is strictly partitioned into:

1. **VERIFIED CONTENT**:
   - Proven business parameters extracted from the repository or confirmed by the owner.
   - Includes: Founder name (`Sachin Rajvanshi`), founder role (`Founder & Guide`), founder portrait (`/founder.webp`), studio location (`Lucknow, Uttar Pradesh`), legal entity name (`Amaratv Krishi LLP`), and the support phone/WhatsApp number (`+91 92146 52400`).

2. **STAGING CONTENT**:
   - High-quality placeholder entries used for visual layout demonstration and build validation.
   - Prefixed with `[STAGING CONTENT]` or `[STAGING]` in titles/bodies.
   - Includes: all customer testimonials, blog posts (journal articles), and upcoming workshops/events.
   - This content is temporary and must be replaced before launching publicly.

3. **CMS CONTENT (Sanity)**:
   - Dynamic overrides that load from Sanity CMS when configured, replacing local Staging Content automatically without code modifications.

---

## Actionable TODO: Business Content Launch Dependencies

The following content requires verification or real business data from the owner before public launch:

- [ ] **Domain & URL**: Update `site.url` in `lib/content.ts` (currently `https://divinity.example`).
- [ ] **Instagram Handle**: Add the official Instagram profile link (currently `https://instagram.com/`).
- [ ] **UPI Payment QR**: Replace `public/payment-qr.png` with the academy's official merchant QR, and verify UCO Bank credentials in `lib/content.ts`.
- [ ] **Testimonials**: Swap out `[STAGING]` testimonials in `lib/content.ts` (or upload via Sanity CMS) with real, consented quotes from active students.
- [ ] **Blog Posts**: Replace `[STAGING]` articles with real guides on breathing science and yoga philosophy.
- [ ] **Upcoming Events/Workshops**: Replace `[STAGING]` events with actual scheduled workshops and Satsangs.
- [ ] **Pricing Plans**: Verify quarterly (₹3,900), monthly (₹1,500), annual (₹12,000), and drop-in (₹200) pricing rates with the owner.
- [ ] **Class Schedule**: Verify daily batch hours, names, levels, and trainer assignments with the active shala routine.
- [ ] **Trainer Bios & Photos**: Add real teacher profiles, bios, focus areas, and portrait shots.

## Channels

- **WhatsApp** (primary quick contact) — pre-filled `wa.me` links.
- **Email** (Brevo) — enquiry + newsletter.
- **Instagram** — `[Needs Verification]` handle in content.
