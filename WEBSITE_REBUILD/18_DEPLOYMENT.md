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
