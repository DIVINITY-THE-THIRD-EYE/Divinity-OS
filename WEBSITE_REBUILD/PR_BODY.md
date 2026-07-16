# Website rebuild — living-anatomy

Full marketing-site rebuild on a semantic design system. 23 commits, 170 files, +9,253 / −1,736.

## What changed
- **Design system** — semantic tokens, day/night themes, opacity-modifier support for surface tokens.
- **Content system** — single source of truth in `website/content/` (statistics, pricing, offers, legal, contact, trainers, gallery, social).
- **Homepage** — 9-section DOM, scroll story (master timeline + motion grammar), Surya Namaskar scroll-morph cursor, living-anatomy scene (SilhouetteTier + breath clock).
- **Pages** — About/Founder/Trainers/Programs, Membership/Pricing/Schedule, Events/Gallery/Testimonials/FAQ/Blog, Contact + legal (`/refund`, real legal text migration).
- **Student login** — Supabase SSR auth, role-gated `/portal/**` via `middleware.ts`.
- **Flutter web** — Nav login link-out (artifact build still tooling-blocked, per commit 13).
- **SEO** — per-page schema, matrix sweep.
- **Performance** — Lighthouse measurement + gate, LCP fix.
- **Accessibility** — axe sweep, contrast + target-size fixes.
- **Testing** — visual regression, CI Playwright job.
- **Deletion sweep** — removed orphaned Marquee/TrustBadges; route-group architecture.

## Gates — local (all green)
- tsc: clean · ESLint: clean · vitest: 145/145 · `next build`: clean
- `flutter analyze`: no issues · `flutter test`: pass

CI runs the remaining two: pgTAP, CodeQL (×2).

## Merge = launch (D012)
Merging deploys production via Vercel git integration. Before merge, confirm:
- [ ] 8 CI checks green
- [ ] Vercel env vars set: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY` (+ existing `SANITY_*`, `BREVO_API_KEY`). No service-role key anywhere.
- [ ] Owner sign-off on placeholders: **PH-004** stats · **PH-005** ₹99 terms · **PH-009** refund text · **PH-010** privacy/terms (DPDP Act 2023) · **PH-013** contact set

## Post-merge smoke (within 30 min)
Home (both themes), pricing, contact-form send, login round-trip, sitemap + robots fetch.
Rollback: Vercel → Deployments → previous → Promote.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
