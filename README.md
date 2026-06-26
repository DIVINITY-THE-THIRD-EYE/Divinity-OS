# Divinity — The Third Eye

A landing page for a yoga, fitness & wellness academy in Lucknow, guided by Sachin Rajvanshi.

Built to run **with zero configuration** — every integration (CMS, email) has a
graceful fallback, so `npm install && npm run dev` gives you a working site
immediately. Add keys when you're ready to go live.

---

## Stack

| Layer | Tool |
|---|---|
| Framework + hosting | **Next.js 14** (App Router) on **Vercel** |
| Styling | **Tailwind CSS** |
| Page transitions + micro-animation | **Framer Motion** |
| Scroll-tied animation | **GSAP** + ScrollTrigger |
| Smooth scroll | **Lenis** |
| Email / contact form | **Brevo** (transactional API) |
| Content management | **Sanity** (optional, free tier) |
| Type | Google Fonts — Cormorant · Hanken Grotesk · JetBrains Mono |

> **3D hero (Spline):** the hero signature is a hand-built `<canvas>` *breathing
> guide* (no dependency, works offline). To swap in a Spline scene instead,
> install `@splinetool/react-spline` and replace the canvas in
> `components/BreathHero.tsx` with `<Spline scene="..." />`.

---

## Run locally

```bash
npm install
npm run dev          # http://localhost:3000
```

```bash
npm run build && npm start   # production build
```

---

## The design

**Concept — "Breathe."** Pranayama (breath control) is the heart of the
practice, so the hero is a *breathing guide* that moves on a real cadence
(inhale 4s · hold 4s · exhale 6s) and invites the visitor to breathe along.

- **Palette** embodies the idea: warm **ember** (inhale / prana / light) meeting
  cool **indigo-void** (exhale / stillness).
  `--void #15161E` · `--bone #ECE7DB` · `--ember #D08A3E`
- **Type:** Cormorant (airy light display + italic accent words), Hanken Grotesk
  (body), JetBrains Mono (labels + the breath counter).
- **Structure as information:** numbering appears **only** on the Method
  (Align / Awaken / Ascend — a real sequence). Disciplines are grouped by
  *intention* (for the body / for the breath / for healing), not decorative 01–06.
- **Signature moments:** breathing hero · GSAP horizontal-scroll through the
  disciplines · interactive weekly schedule · breath-paced manifesto reveal.

Accessibility floor: keyboard focus rings, `prefers-reduced-motion` respected
(animations and smooth scroll disabled), responsive to mobile.

---

## What was added from the roadmap

Selected for impact — and kept restrained, because piling on every effect reads
as AI clutter and works *against* award juries.

**Award / motion layer**
- Command palette — press **⌘K / Ctrl+K** to jump to any section or action
- Magnetic CTA, custom cursor, scroll-progress bar, active-section nav
- Intro curtain on first visit (once per session, reduced-motion safe)
- Kinetic marquee that reacts to scroll velocity (skews + speeds with you)
- Breathing ambient gradient + film-grain texture (ties to the concept)

**Conversion layer**
- Floating WhatsApp button (appears past the hero, pre-fills a message)
- "Shape your practice" plan calculator → recommends a membership + routes to enquiry/WhatsApp
- FAQ section

**SEO layer**
- JSON-LD structured data: LocalBusiness/HealthClub, FAQPage, Course
- Dynamic Open Graph image (`/opengraph-image`), Twitter card, canonical
- `sitemap.xml` and `robots.txt` (generated)

**Performance** is largely automatic on this stack: `next/font` (no layout
shift), static prerendering, route prefetching, and Vercel's CDN/edge caching.
Add real photos as `next/image` for AVIF/WebP optimisation.

## Deliberately out of scope (separate project)

The roadmap's **Student / Trainer / Admin portals, authentication, Supabase +
RLS backend, notifications/analytics, and the Flutter mobile apps** are a
distinct *product*, not part of this marketing site. They belong in their own
repo with their own auth and database. Keeping them out keeps this site fast,
static, and secure. This landing page is the public front door; it links into
that product when it's ready.

---


## Contact form (Brevo)

The form posts to `app/api/contact/route.ts`.

- **No `BREVO_API_KEY`** → the enquiry is accepted and logged server-side so the
  UI works in development (`delivered: false`).
- **With a key** → an email is sent to your inbox via Brevo, with the visitor as
  reply-to.

Set in `.env.local` (copy from `.env.local.example`):

```
BREVO_API_KEY=xkeysib-...
BREVO_TO_EMAIL=you@yourdomain.com
BREVO_FROM_EMAIL=no-reply@yourdomain.com   # must be a verified sender in Brevo
```

---

## Content management (Sanity — optional)

The site reads content from `lib/content.ts`. If you connect Sanity, matching
documents override those values automatically (see `lib/sanity.ts`).

1. Create a free project at <https://sanity.io/manage>.
2. Spin up a Studio and register the schemas in `sanity/schemas/` (export
   `schemaTypes` from `sanity/schemas/index.ts`).
3. Add to `.env.local`:
   ```
   NEXT_PUBLIC_SANITY_PROJECT_ID=your_id
   NEXT_PUBLIC_SANITY_DATASET=production
   ```

CMS-managed today: **disciplines**, **membership plans**, **testimonials**
(schemas for **schedule** and **site settings** are included to extend).

---

## Deploy to Vercel

1. Push this folder to a Git repo.
2. Import it at <https://vercel.com/new>.
3. Add the env vars above in **Project → Settings → Environment Variables**.
4. Deploy. (Framework preset: Next.js — auto-detected.)

---

## Photography & brand assets

Real photography from the academy is wired in via `next/image` (sources live in
`public/`):

- **Logo** — the lotus mark is recoloured to ember on transparent
  (`public/brand/logo-mark.png`) for the nav + footer; it's also the favicon
  (`app/icon.png`, `app/apple-icon.png`). The full lockup is in
  `public/brand/logo-full.png` for light surfaces.
- **Founder** — `public/founder.webp` (optimised) appears in the About section.
- **The space** — studio + practice photos (`public/studio`, `public/guru`)
  drive the new **Gallery** section (`#space`). Curate the set in
  `studioGallery` (`lib/content.ts`).
- **Hero** — a darkened studio shot sits behind the breathing canvas.
- **Payment** — the UPI QR (`public/payment-qr.png`) is shown in the Membership
  section; details are in `payment` (`lib/content.ts`).

## Before launch — checklist

- [ ] Set `site.url`, `phone`, `whatsapp`, and `instagram` in `lib/content.ts`
- [ ] Replace placeholder membership prices with real fees
- [ ] Swap testimonials for real students
- [ ] Add a verified Brevo sender + API key
- [ ] (Optional) Connect Sanity so the owner can edit content without code
- [ ] Replace the generated OG image with a photo-based one if you prefer
- [ ] Confirm the UPI QR (`public/payment-qr.png`) points to the real account
- [x] Studio & founder photography integrated (hero, About, Gallery) via `next/image`

---

## Structure

```
app/
  layout.tsx          fonts + metadata
  page.tsx            section assembly (fetches CMS-or-fallback)
  globals.css         tokens + base styles
  api/contact/route.ts  Brevo handler
components/            Hero, Nav, Disciplines, Schedule, … (one per section)
lib/
  content.ts          content source of truth / CMS fallback
  sanity.ts           Sanity client + safe fetch
sanity/schemas/       schemas for a Sanity Studio
```
