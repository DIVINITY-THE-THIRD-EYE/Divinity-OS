# 11 — CONTACT & LEGAL (Contact · Certificate Verify · Privacy · Terms · Refund)

## PURPOSE
Working contact path + complete legal set (D008 requires a Refund page that doesn't exist yet).

## INPUTS
Phases 1–4 · `content/{contact,legal,seo}.ts` · existing `Contact.tsx`, `VerifyForm.tsx`,
`app/api/contact`, `app/api/verify-certificate` (KEEP — working, tested, rate-limited).

## ROUTES
| Route | Action |
|---|---|
| `/contact` | rebuild visual on tokens; form logic/API untouched; contact facts from `content/contact.ts`; map link, hours, WhatsApp block |
| `/verify` | re-skin only; `VerifyForm` logic untouched |
| `/privacy` | re-skin; text from `content/legal.ts` (PH-010 confirm) |
| `/terms` | re-skin; text from `content/legal.ts` (PH-010) |
| `/refund` | NEW; text from `content/legal.ts` → `refund`; until PH-009 provides real policy: page renders labeled placeholder + "contact us" fallback and stays `noindex` |

## RULES
- API routes, honeypot, rate limiting: DO NOT TOUCH (PROJECT_RULES; they have tests).
- Legal text is business data: never draft final legal language yourself; placeholder
  protocol applies. Structural/heading scaffolding is fine.

## FILES ALLOWED
`website/app/{contact,verify,privacy,terms,refund}/**` (page/presentation files only) ·
`content/{contact,legal}.ts` · STATUS/CHANGELOG/PLACEHOLDERS.

## FILES FORBIDDEN
`website/app/api/**` · `lib/validation.ts` · `lib/rate-limit.ts` · everything else.

## STEPS
Table order; validate each; run the EXISTING api tests untouched
(`npm test -- api-routes`) to prove no regression.

## VALIDATION
Standard block + Playwright: contact form happy path (mock/send guarded), verify form
renders, refund page shows placeholder label.

## STOP CONDITION
Phase 5 gate (08+09+10+11 all COMPLETE). Gate report + rebase → auto-continue (D011).

## NEXT
`12_STUDENT_LOGIN.md`

## AMENDMENT (executed 2026-07-09/10)
- `components/Contact.tsx` and `components/VerifyForm.tsx` re-skinned too (not
  just the pages) — the tokens live in the components, not the thin pages that
  compose them. Same recurring FILES ALLOWED gap as IN-001..007. See IN-008.
- `/privacy` and `/terms` already had real, non-placeholder body text sitting
  in their pre-existing page JSX (contradicting this file's PH-010 assumption
  that migration/placeholder was needed). Migrated that real text verbatim
  into `content/legal.ts` instead of stubbing it with a placeholder — see E-010.
- Also touched `lib/nav.ts` (added `/refund` to `legalItems`) and
  `lib/i18n/translations.ts` (Hindi entry for "Refund Policy") for footer
  reachability + i18n-completeness test — same recurring class as IN-001..007.
- Found (not fixed, out of FILES ALLOWED — `next.config.mjs`): production CSP
  blocks the Contact page's WeatherWidget fetches and Google Maps iframe.
  Flagged as a background task, not silently patched.
