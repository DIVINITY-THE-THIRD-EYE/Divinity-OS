# 10 — COMMUNITY PAGES (Events · Gallery · Testimonials · FAQ · Blog)

## PURPOSE
Proof-and-life pages. Honest empty handling — these pages may launch with little real content.

## INPUTS
Phases 1–4 COMPLETE · `content/{events,gallery,testimonials,faq,posts}.ts`.

## ROUTES
| Route | Action | Empty rule |
|---|---|---|
| `/events` | rebuild from `content/events.ts` | empty → "announcements coming" state + newsletter CTA; page stays `noindex` until ≥1 real event (14_SEO) |
| `/gallery` | rebuild; depth/parallax grid (reuse ScrollScore-free parallax — simple `IntersectionObserver` translate) from `content/gallery.ts` | photos exist (PH-015 rights confirm) |
| `/testimonials` | NEW dedicated page from `content/testimonials.ts` | zero real quotes → page renders explanation + invite-to-share form (mailto/WhatsApp), `noindex` |
| `/faq` | NEW dedicated page (existing Faq component content → `content/faq.ts`) | FAQ schema (14) |
| `/blog` | rebuild listing from `content/posts.ts` | `noindex` until ≥1 real post (PH-012) |

## RULES
- NEVER fabricate testimonials/events/posts (PROJECT_RULES 1–4).
- Gallery images through `next/image`, alt text mandatory from content file.
- Parallax: transform-only, disabled under reduced motion.

## FILES ALLOWED
`website/app/{events,gallery,testimonials,faq,blog}/**` · `website/components/pages/**` ·
`content/{events,gallery,testimonials,faq,posts}.ts` · STATUS/CHANGELOG/PLACEHOLDERS.

## FILES FORBIDDEN
Everything else.

## STEPS
Route order as table; validate after each; both themes; mobile.

## VALIDATION
Standard block + Playwright smoke per route + alt-text audit
(`grep -rn "alt=\"\"" website/app website/components/pages` → only decorative images, each
with `aria-hidden` parent justification).

## STOP CONDITION
Green. Auto-continue.

## NEXT
`11_CONTACT_LEGAL.md`
