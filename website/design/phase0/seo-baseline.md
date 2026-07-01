# SEO Baseline (Phase 0)

Captured 2026-06-26 from `app/layout.tsx`, `components/JsonLd.tsx`, `app/sitemap.ts`, `app/robots.ts`,
`app/opengraph-image.tsx`, and section markup. **Preserve all of this** — the upgrade only adds.

## Metadata (`app/layout.tsx`)
| Field | Value |
|---|---|
| `metadataBase` | `new URL(site.url)` — ⚠️ `site.url` is placeholder `https://divinity.example` (fix pre-launch, TD9) |
| Title | "Divinity — The Third Eye \| Yoga, Fitness & Wellness, Lucknow" |
| Description | present (breath/movement/stillness, Lucknow, Sachin Rajvanshi) |
| Keywords | yoga Lucknow, fitness Lucknow, wellness academy, therapeutic yoga, pranayama, Sachin Rajvanshi |
| Canonical | `alternates.canonical = "/"` |
| Open Graph | title, description, url, siteName, type=website, locale=`en_IN` |
| Twitter | `summary_large_image` + title/description |
| `lang` | `en` (on `<html>`) |

## Structured data (`components/JsonLd.tsx`, server-rendered)
- **LocalBusiness / HealthClub** (from `site`).
- **FAQPage** (from `faqs`).
- **Course** (from `disciplines`).
- Status: ✅ present. **Add Offer** (intro offer / prices) + **Event/Course** for R11 (`design/03 §14`).
- Validate at: Google Rich Results Test + Schema.org validator (record pass in `reports/`).

## Crawl & indexing
| Artifact | State |
|---|---|
| `sitemap.xml` | ✅ generated (`app/sitemap.ts`) |
| `robots.txt` | ✅ generated (`app/robots.ts`) |
| OG image | ✅ dynamic (`app/opengraph-image.tsx`, edge, 1200×630) |
| Icons | ✅ `icon.png` + `apple-icon.png` (ember lotus) |

## Heading hierarchy (single-page outline)
```
h1  BreathHero — "Breathe / your way inward."   (exactly one h1 ✅)
h2  About · Disciplines · Method · Schedule · Membership · PlanCalculator · Voices · Faq · Contact · Gallery
    (each section a single h2; sub-items use h3/h4)
```
Rule: new sections (Stats/StartHere/Newsletter/Quote) each add **one** `<h2>`; keep the single `<h1>`.

## Content crawlability
- ✅ Core copy is **server-rendered** (RSC) — not hidden behind client islands.
- ⚠️ Keep new conversion elements (PromoBar/Newsletter) from hiding core content from crawlers; render
  their copy server-side where it carries keywords.

## Baseline gaps → fix windows
| Gap | Fix |
|---|---|
| `site.url` placeholder | Real domain before launch (TD9, `23`) |
| No Offer schema | Add with R1/R8 (`03 §14`) |
| No analytics/GSC verification | Set up GA4 + Search Console at launch (`16`, `23`) |

## Non-regression rule
Future work must not remove metadata, break JSON-LD validity, alter the single-`h1` outline, or hide
core copy behind JS. Re-validate structured data + run a Lighthouse SEO check (target 100) each phase.
