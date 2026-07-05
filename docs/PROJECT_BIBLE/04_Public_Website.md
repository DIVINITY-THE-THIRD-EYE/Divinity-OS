# Phase 4 — Public Website

> `website/` — Next.js 14 App Router. Sources: [README](../website/README.md), `app/`, `components/`, `lib/`, `design/`.

## Pages (routes)

| Route | File | Type | Notes |
|---|---|---|---|
| `/` | `app/page.tsx` | static | landing: section previews + CTAs, breathing hero |
| `/about` | `app/about/page.tsx` | static | founder (Sachin Rajvanshi), manifesto |
| `/services` + `/services/[slug]` | `app/services/` | SSG | disciplines/offerings |
| `/pricing` | `app/pricing/page.tsx` | static | membership plans + plan calculator |
| `/schedule` | `app/schedule/page.tsx` | static | weekly interactive schedule |
| `/trainers` | `app/trainers/page.tsx` | static | trainer cards |
| `/gallery` | `app/gallery/page.tsx` | static | studio/practice photos (#space) |
| `/blog` + `/blog/[slug]` | `app/blog/` | SSG | articles |
| `/events` + `/events/[slug]` | `app/events/` | SSG | events |
| `/contact` | `app/contact/page.tsx` | static + form | Brevo enquiry |
| `/privacy`, `/terms` | `app/privacy`, `app/terms` | static | legal |
| 404 / errors | `not-found.tsx`, `error.tsx`, `global-error.tsx` | — | boundaries |

## Components (~40)

- **Chrome:** `Nav`, `Footer`, `Cursor`, `ScrollProgress`, `SmoothScroll`, `MotionProvider`, `CommandPalette`, `PromoBar`, `StickyCta`, `WhatsAppFab`.
- **Hero/Concept:** `BreathHero` (hand-built `<canvas>` breathing guide), `Ambient` (breathing gradient + grain), `Manifesto`, `Marquee` (velocity-reactive).
- **Sections:** `About`, `Method`, `Disciplines`, `Schedule`, `Membership`, `PlanCalculator`, `Voices` (testimonials), `Gallery`, `Faq`, `StatsBand`, `Newsletter`, `Contact`.
- **Primitives:** `layout/` (`PageHeader`, `Breadcrumbs`, `PreviewSection`), `ui/` (`CtaLink`, `EmptyState`, `SectionHeading`), `cards/` (`ServiceCard`, `TrainerCard`).
- **Effects:** `Magnetic`, `Reveal`, `JsonLd` (structured data).

See full dependency map: [design/14-component-dependency-map.md](../website/design/14-component-dependency-map.md).

## Layouts

`app/layout.tsx` — fonts (next/font: Cormorant, Hanken Grotesk, JetBrains Mono), metadata base, global chrome (nav/footer/cursor/scroll/motion). `globals.css` holds tokens + base styles.

## SEO

- Per-page metadata via `lib/seo.ts` `pageMeta()` (title, description, OG, Twitter, canonical).
- **JSON-LD** (`JsonLd.tsx`): LocalBusiness (HealthAndBeautyBusiness/SportsActivityLocation), FAQPage, Course; per-page BreadcrumbList + Service/Article/Event.
- Generated `sitemap.ts` (static + dynamic slugs), `robots.ts`, dynamic `opengraph-image.tsx`, `manifest.ts` (PWA). See [design/19-content-strategy](../website/design/19-content-strategy.md).

## Animations

Framer Motion (transitions/micro), **GSAP + ScrollTrigger** (horizontal-scroll disciplines, scroll-tied reveals), **Lenis** (smooth scroll). Signature: breathing hero cadence (4-4-6), breath-paced manifesto reveal. All gated by `prefers-reduced-motion`. Spec: [design/10-motion-spec.md](../website/design/10-motion-spec.md).

## CMS Integration

Sanity is **optional**. `lib/content.ts` is the source of truth; `lib/sanity.ts` `fetchOrFallback` overrides when env vars are present. Content is strictly partitioned into VERIFIED and STAGING categories to prevent false claims before launch (see [Appendix/Brand_and_Content_Library](Appendix/Brand_and_Content_Library.md)). CMS-managed: disciplines, plans, testimonials (schemas also for schedule + siteSettings). See [14_Integrations](14_Integrations.md), [25_Assets_Content](25_Assets_Content.md).

## Routing

File-based App Router; navigation single-sourced in `lib/nav.ts` (primary/footer/legal); active-route highlighting; command palette (⌘K) for jump-to.

## Forms

- `/contact` → `POST /api/contact` (Brevo). `/newsletter` → `POST /api/subscribe`.
- Guards: rate-limit (`lib/rate-limit.ts`), honeypot field, body-size limit, validation (`lib/validation.ts`). Errors shaped by `lib/form-error.ts`.

## Accessibility

Keyboard focus rings, `prefers-reduced-motion` (animations + smooth scroll disabled), focus trap (`lib/focus-trap.ts`), semantic structure, responsive. Target WCAG AA. Audit: [design/09-accessibility-audit.md](../website/design/09-accessibility-audit.md). See [11_UIUX_Design_System](11_UIUX_Design_System.md).

## Performance

Automatic on this stack: `next/font` (no CLS), static prerender, route prefetch, Vercel CDN/edge. Budgets: [design/11-performance-budgets.md](../website/design/11-performance-budgets.md); baselines in `design/phase0/reports/` (Lighthouse desktop/mobile). See [13_Performance](13_Performance.md).

## Analytics

`[Needs Verification]`: web analytics provider not confirmed in-repo (event taxonomy exists at [design/16-analytics-taxonomy.md](../website/design/16-analytics-taxonomy.md)). Likely Vercel Analytics or GA — confirm. See [23_Data_Analytics](23_Data_Analytics.md).

## Media Assets

In `public/`: `brand/logo-mark.png`, `brand/logo-full.png`, `founder.webp`, `guru_*.webp`, `yc_*.webp` (studio), `payment-qr.png`. Wired via `next/image`. Curated in `lib/content.ts` (`studioGallery`, `payment`).

---

## WebGL & Prisma Reference Website

The repository contains an archived Next.js + Prisma + tRPC prototype website preserved under [`Divinity/reference/divinity-website/`](file:///C:/Users/PC/OneDrive/Documents/Divinity%20TTE/Divinity/reference/divinity-website/). It includes active student portals, mockups, and the custom interactive WebGL `AuraCanvas` particle shader. 

For a complete architectural breakdown, file listings, and a future migration path, see the [Comparative Website Analysis](COMPARATIVE_WEBSITE_ANALYSIS.md) document.

