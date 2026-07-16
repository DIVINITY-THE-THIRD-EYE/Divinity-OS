# 18 — DEPLOYMENT

## PURPOSE
Repeatable deploy of website (+ Flutter Web artifact) with correct env, preview → production.

## INPUTS
Phase 7 gate passed · hosting: Vercel assumed (existing `design/` docs reference it) —
IF the owner uses different hosting: STATUS-note, this file's steps map 1:1 to any
Node host; do not improvise infra.

## ENVIRONMENT VARIABLES (the complete list — no others)
| Var | Scope | Source |
|---|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | public | docs/SUPABASE_SETUP.md |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | public | Supabase dashboard (anon, NOT service) |
| `SANITY_*` (existing, optional) | server | unchanged |
| `BREVO_API_KEY` (existing) | server | unchanged |

Secret rules: only `NEXT_PUBLIC_*` values are public by design; everything else server-side.
Service-role key: NEVER present anywhere in this deployment.

## STEPS
1. Preview deployment from `rebuild/living-anatomy` (branch-as-flag, D012 — the preview
   IS the complete new site). Verify: all routes,
   login round-trip against production Supabase (it's the same shared project — read-only
   usage; do NOT run destructive actions), Flutter app link/embed.
2. Flutter Web artifact: build + deploy per the DECISIONS choice from 13
   (subdomain project or static copy). Document the exact commands in this file (append).
3. Domain/DNS: no changes in this task (launch flips traffic, not DNS).
4. Rollback rehearsal: confirm the previous production deployment can be restored in one
   action (Vercel: promote previous). Write the exact rollback steps into `19_LAUNCH.md` inputs.
5. Run Lighthouse against the PREVIEW URL (real network) — record vs budgets.

## FILES ALLOWED
`vercel.json`/deploy config if needed · `.github/workflows/**` · this file (append
commands) · STATUS/CHANGELOG. NO application code.

## VALIDATION
Preview URL fully functional (route sweep script from 14 re-run against preview) ·
preview Lighthouse within budgets · rollback path documented and tested.

## IF VALIDATION FAILS
Env mismatch is the usual cause — diff preview env vs the table above before touching code.

## STOP CONDITION
Preview verified. Auto-continue to launch checklist.

## NEXT
`19_LAUNCH.md`

## AMENDMENT (executed 2026-07-10)
This task requires an authenticated Vercel deployment, a real preview URL,
and production Supabase credentials to test a login round-trip — none of
which this sandboxed session has (no Vercel OAuth available here; this
session is non-interactive, matching the standing note in this
environment's own instructions that Vercel needs authorization via
`claude mcp`/`/mcp` in an interactive session). What's real vs. blocked:

**Done (real, verifiable from this environment):**
- Confirmed no `vercel.json` exists anywhere in the repo, and none is
  needed — this is a standard Next.js 14 App Router app with zero custom
  Vercel routing/build requirements; redirects/headers/rewrites already
  live in `next.config.mjs`, and `middleware.ts` (12_STUDENT_LOGIN) handles
  the one routing concern (`/portal/**` auth guard) Vercel's zero-config
  detection doesn't need help with. Deliberately did not create one just
  to have one.
- `ENVIRONMENT VARIABLES` table (above) verified accurate against
  `website/.env.local.example` and `docs/SUPABASE_SETUP.md` — no changes
  needed.
- Rollback procedure documented below (Step 4) — standard Vercel platform
  behavior, not specific to this app, so it's correct without needing a
  live rehearsal — but genuinely NOT rehearsed live (no deployment access).

**Rollback procedure (documented, not live-tested — Step 4):**
1. Vercel dashboard → Project → Deployments tab → find the last known-good
   production deployment → "⋯" menu → **Promote to Production**.
   (CLI equivalent: `vercel promote <deployment-url> --scope=<team>`, or
   `vercel rollback` for the immediately-previous one.)
2. This repoints the production domain's alias to the already-built
   deployment — no rebuild happens, so it takes effect at Vercel's CDN
   edge within seconds, not minutes.
3. Confirm via a smoke check (home loads, correct git SHA in a deployment
   marker) before considering the rollback complete.

**Blocked, not attempted (documented, not faked):**
- Step 1 (preview deployment + full route/login/Flutter-embed verification
  against it): no Vercel access from this session.
- Step 2 (Flutter Web artifact build+deploy): nothing to deploy yet —
  13_FLUTTER_WEB.md already documented the Flutter SDK isn't available
  here either.
- Step 5 (Lighthouse against the real preview URL): no preview URL exists
  to point it at. 15_PERFORMANCE.md's local Lighthouse numbers (via a
  Playwright-launched Chromium over CDP) are the best measurement this
  session could produce; a real preview re-measurement is still owed.

**STOP CONDITION reinterpreted honestly:** this file's own STOP CONDITION
("Preview verified. Auto-continue") cannot be literally satisfied without
deployment access. Per the autonomy charter (D011) and the same precedent
as E-008/E-012 (tooling-blocked, not effort-blocked), continuing to
`19_LAUNCH.md` is still correct: 19's own PRECONDITIONS checklist and its
step 1 human-approval gate (BD-001) are the natural place these blocked
items surface for the owner — not a gate this session can silently skip
past by fabricating a deployment that didn't happen.
