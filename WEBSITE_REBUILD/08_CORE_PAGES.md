# 08 — CORE PAGES (About · Founder · Trainers · Programs · Therapeutic Yoga · Meditation)

## PURPOSE
Rebuild the identity pages on the new design system. Same language as the homepage,
no 3D scene, fast.

## INPUTS
- Phases 1–4 COMPLETE. `content/` modules. Existing pages under `website/app/`.

## ROUTES (D008)
| Route | Status today | Action |
|---|---|---|
| `/about` | exists | rebuild on tokens; merge Manifesto+Method flow |
| `/founder` | NEW | founder story page — `content/founder.ts`; placeholder-labeled bio until PH-001 done |
| `/trainers` | exists | rebuild; profiles from `content/trainers.ts` (PH-003) |
| `/services` → programs hub | exists | rebuild as `/programs` with redirect from `/services` (301 in `next.config.mjs`) |
| `/programs/therapeutic-yoga` | NEW | deep page — therapeutic focus (real differentiator) |
| `/programs/meditation` | NEW | deep page — pranayama/meditation |

Program deep pages: template component `components/pages/ProgramDetail.tsx` fed by
`content/programs.ts` entries (add `slug`, `longDescription`, `sessions`, `whoFor` fields
— placeholders where unknown). Two pages now; other disciplines can be added by content only.

## SHARED TEMPLATE RULES
- Reuse `PageHeader`, `Breadcrumbs`, `CtaLink`, `SectionHeading` (re-skin to semantic
  tokens where they still use primitives — that re-skin IS allowed here).
- Every page ends with a small conversion band (offer from `content/offers.ts`).
- Metadata via existing `pageMeta()` with `content/seo.ts` overrides.

## FILES ALLOWED
`website/app/{about,founder,trainers,programs,services}/**` ·
`website/components/pages/**` · re-skin-only edits to the four shared components ·
`content/programs.ts` `content/founder.ts` `content/trainers.ts` (field additions) ·
`next.config.mjs` (redirect only) · STATUS/CHANGELOG/PLACEHOLDERS.

## FILES FORBIDDEN
Homepage, scene, cursor, auth, api, supabase, flutter-app.

## STEPS
1. Re-skin the four shared components to semantic tokens (visual parity in night theme).
2. Build/rebuild routes in table order. After each route: build green + both themes checked.
3. `/services` → `/programs` 301; update internal links (`grep -rn '"/services"' website`).
4. All business facts from `content/` (spot-check: zero literals — run the 02 grep on new files).

## VALIDATION
Standard block + Playwright smoke per route (h1 present, no console errors) + both themes
+ 375px/1440px no overflow.

## IF VALIDATION FAILS
Route-by-route commits; revert failing route only.

## CHECKPOINT
Commit per route.

## STOP CONDITION
All six routes green. Auto-continue (same phase).

## NEXT
`09_COMMERCE_PAGES.md`
