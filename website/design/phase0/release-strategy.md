# Release Strategy (Phase 0)

Defines environments and the deployment requirements for each. The project is **not a git repo yet** —
step 0 is to initialise version control; everything else is free-tier (Vercel + GitHub).

## Step 0 — version control (prerequisite)
```bash
git init && git add -A && git commit -m "chore: baseline freeze (Phase 0)"
# push to GitHub; enable branch protection on main requiring CI checks (quality-gates.md)
```
Record the resulting commit hash in `BASELINE.md`.

## Environments
| Env | Branch / trigger | URL | Data / keys | Purpose | Deploy requirement |
|---|---|---|---|---|---|
| **development** | local `next dev` | localhost:3000 | no keys (graceful fallback) | build features | lint/typecheck clean locally |
| **preview** | every PR (Vercel Preview) | auto per-PR URL | test Brevo/Sanity keys; **test** analytics stream | review + QA + stakeholder check | **all CI gates green** (quality-gates) |
| **staging** | `staging` branch | staging.<domain> | prod-like keys, test analytics | pre-prod soak, content QA | CI green + Lighthouse/axe + VRT baselines approved |
| **production** | `main` (tagged release) | <real domain> | prod keys, prod analytics, **real UPI QR** | live | launch-readiness checklist (`23`) fully ✅ |

## Promotion flow
```
feature/* ──PR──> preview (CI gates) ──merge──> main ─tag─> production
                              └─ optional: staging branch for soak before main
```
- **PR → preview:** must pass all gates (`quality-gates.md`). Stakeholders review the Preview URL.
- **main → production:** Vercel auto-deploys tagged `main`; gated by the launch checklist (`23`) for the
  first launch and major releases.

## Deployment requirements per env
- **Preview:** CI green; no secrets in client; feature flags default-off for risky items (`offer.enabled`).
- **Staging:** + VRT baselines current; Lighthouse ≥95; axe 0 critical; content QA on test data.
- **Production:** + real content/QR verified (TD9/TD10); analytics + consent live; Sentry on; security
  headers deployed; **rollback tested**.

## Rollback (per `12 §5`)
- **Vercel:** "Promote previous deployment" → instant rollback. Verify this works during staging.
- **Feature flags:** toggle `offer.enabled` / `features.sound` in `lib/content.ts` to disable a feature
  without a deploy.
- **Trigger:** perf-budget breach, axe critical, or contact/subscribe error spike → rollback + fix forward.

## Release cadence
- Phase-based, independently shippable (Phase 1 → 2 → 3 → 4). Tag each (`v1.1`, `v1.2`…).
- Hotfixes branch from `main`, fast-track through the same gates.
- Record metrics snapshot (`24`) at each release for the 6-month review.
