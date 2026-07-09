# 14 — SEO

## PURPOSE
Every page indexed correctly, structured data complete, no placeholder content in the index.

## INPUTS
Phases 1–6 COMPLETE · existing `lib/seo.ts`, `JsonLd.tsx`, `sitemap.ts`, `robots.ts` ·
`content/seo.ts`.

## OUTPUTS / CHECK MATRIX (run per route — record a table in STATUS)
| Check | Rule |
|---|---|
| Title/description | unique per route, from `pageMeta` + `content/seo.ts` |
| Canonical | present, correct |
| OG/Twitter | present; OG image route re-rendered in new art direction |
| `noindex` set | `/blog` (until PH-012), `/events` (until real event), `/testimonials` (until real quotes), `/refund` (until PH-009), `/portal/**` + `/login` (ALWAYS noindex) |
| h1 | exactly one per page |
| Schema.org | see below |

Structured data additions (extend `JsonLd.tsx`, data from `content/`):
- `LocalBusiness` (site-wide): name, address, phone, hours, geo — from `content/contact.ts`.
- `Person` (founder page): only VERIFIED facts — placeholder fields are omitted from schema, never emitted.
- `Course` (each program page).
- `FAQPage` (/faq).

## FILES ALLOWED
`lib/seo.ts` · `components/JsonLd.tsx` · `app/sitemap.ts` · `app/robots.ts` ·
`app/opengraph-image.tsx` · per-page `metadata` exports · `content/seo.ts` · STATUS/CHANGELOG.

## FILES FORBIDDEN
Page layouts/visuals, everything else.

## STEPS
1. Sitemap: include all new routes, exclude noindex + portal routes.
2. Apply the noindex list (route `metadata.robots`).
3. Schema additions; validate each JSON-LD block with a parser test (Vitest: JSON.parse +
   required fields present).
4. OG image re-render (satori route already exists — restyle to new tokens).
5. Full matrix sweep; write the table to STATUS.

## VALIDATION
Standard block + schema unit tests + `curl` each route's rendered head in `next start`
(grep title/canonical/robots) — script the sweep, don't hand-check.

## STOP CONDITION
Matrix table complete, all rules PASS. Auto-continue.

## NEXT
`15_PERFORMANCE.md`

## AMENDMENT (executed 2026-07-10)
- `components/JsonLd.tsx` (root-layout, site-wide) was emitting `FAQPage`
  and a generic `Course` block on every route, not just where that content
  is actually visible — reduced to `LocalBusiness`-family only (now with
  real `geo` from `locationConfig`); see E-013.
- Added `Person` schema to `/founder` (new), `Course` schema (converted
  from `Service`) to all three program-detail pages, both via new pure,
  unit-tested builder functions in `lib/seo.ts`
  (`buildLocalBusinessJsonLd`/`buildFaqJsonLd`/`buildCourseJsonLd`/
  `buildPersonJsonLd`) — satisfies Step 3's "validate each JSON-LD block
  with a parser test" without rendering React.
- Confirmed (grep, not assumed) the full noindex checklist already held from
  prior tasks: `/blog`, `/events` (+ `[slug]`), `/testimonials`, `/refund`,
  `/login`, `/portal` all carry `noindex`.
- OG image (`app/opengraph-image.tsx`) checked against the current semantic
  token hex values (`--surface`/`--accent`/`--fg`/`--fg-muted`, night
  theme) — already an exact match (03_DESIGN_SYSTEM kept night-theme hex
  values unchanged when introducing the semantic layer), so no re-render
  was needed.
- Wired the previously-dead `content/seo.ts` into the homepage's keywords
  (IN-010).
- Matrix sweep scripted as `e2e/seo.spec.ts` (25 tests: title/canonical/
  single-h1/indexable per route, noindex per route, JSON-LD presence/
  correctness) instead of hand-checked — see STATUS.md for the full table.
