# 09 — COMMERCE PAGES (Membership · Pricing · Schedule)

## PURPOSE
The money path. Clarity beats spectacle here — fastest pages on the site.

## INPUTS
Phases 1–4 COMPLETE · `content/pricing.ts` `content/offers.ts` `content/schedule.ts` ·
existing `Membership.tsx`, `PlanCalculator.tsx`.

## ROUTES
| Route | Action |
|---|---|
| `/pricing` | rebuild: plans from `content/pricing.ts`; keep PlanCalculator (re-skin); UPI explainer (existing copy pattern); ₹99 offer block with terms from `content/offers.ts` (PH-005 label until confirmed) |
| `/membership` | NEW: what membership includes (from `content/pricing.ts` features), how joining works (UPI screenshot → verification — mirrors the app flow, copy only), FAQ subset |
| `/schedule` | rebuild: batch grid from `content/schedule.ts` + `BatchPickerCta` (built in 04) on every batch row |

## RULES
- Prices render EXACTLY as in content files. A price placeholder renders as
  "Contact for current pricing" — NEVER a made-up number.
- Every plan card CTA → WhatsApp deep link with plan name prefilled (`lib/links.ts`).
- No payment gateway work — UPI + verification stays in the app (PROJECT_RULES #10).

## FILES ALLOWED
`website/app/{pricing,membership,schedule}/**` · re-skin `Membership.tsx`,
`PlanCalculator.tsx` · `content/{pricing,offers,schedule}.ts` (field additions) ·
STATUS/CHANGELOG/PLACEHOLDERS.

## FILES FORBIDDEN
Everything else.

## STEPS
1. `/pricing` rebuild → validate.
2. `/membership` new → validate.
3. `/schedule` rebuild with picker rows → validate.
4. Cross-link audit: pricing ↔ membership ↔ schedule ↔ contact all reachable ≤1 click.

## VALIDATION
Standard block + Playwright: pricing shows ≥1 plan, schedule picker builds a `wa.me` URL
containing the chosen batch label. Both themes, mobile widths.

## IF VALIDATION FAILS
Same route-by-route protocol as 08.

## STOP CONDITION
Green. Auto-continue.

## NEXT
`10_COMMUNITY_PAGES.md`
