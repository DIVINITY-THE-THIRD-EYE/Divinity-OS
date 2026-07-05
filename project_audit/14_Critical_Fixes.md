# 14 — Critical Fixes

**Round 2 update:** both fixes below (`1cb10cf`, `706a2b2`) are merged to `main` via PR #20, confirmed working live (release-please's pipeline was exercised end-to-end by that very merge). No new CRITICAL-severity issue was found in round 2 either — see `PUBLIC_REPOSITORY_SECURITY_AUDIT.md` for the public-repo re-check.

## No CRITICAL-severity issue was found

Per this audit's severity policy (CRITICAL = security holes, exposed secrets, auth bypass, data loss, payment errors, or core-flow crashes), nothing found this session met that bar:
- No committed secrets.
- No confirmed auth bypass (the one historical privilege-escalation bug is verified fixed and unregressed).
- No data loss scenario found.
- No payment-flow error found (the manual UPI + screenshot + admin-verification state machine was traced end-to-end and is internally consistent, with dedicated pgTAP coverage).
- No core-flow crash found (all automated gates pass; the one test failure encountered was proven to be test fragility, not a product defect).

Because of that, **no fix in this session was made unilaterally** — both fixes below were applied only after the user explicitly approved "all localized/low-risk fixes" at the Phase 2 checkpoint.

## Fixes applied (HIGH severity, localized, low-risk — user-approved)

### Fix 1 — pgTAP test fragility (`c17_leave_business_rules_test.sql`)
- **What:** the late-request test fixture inserted a request for `current_date` directly; on Saturdays/Sundays this collided with a separate, correct "entire range is week-offs" auto-approve rule, producing a false test failure.
- **Why:** verified the actual leave-approval business logic was already correct (manually tested a real weekday late-request in a rolled-back transaction: `status=PENDING, is_auto_approved=false`, exactly per spec) — only the test itself needed fixing.
- **How to verify:** `cd supabase && supabase test db` (or from repo root: `supabase test db`) → expect `Files=23, Tests=188... Result: PASS`.
- **Commit:** `1cb10cf`.

### Fix 2 — `release-please` CI repair
- **What:** both `release-flutter.yml` and `release-website.yml` had failed on every single run since 2026-07-01 (confirmed via `gh run list`) because they used v3-era scalar inputs (`release-type`, `path`, `package-name`, `changelog-types`) that `googleapis/release-please-action@v4` rejects.
- **Why:** verified the correct v4 config shape via Context7 documentation lookup (not assumed from training data) before making the change.
- **How to verify:** JSON/YAML syntax already validated locally (`node -e "JSON.parse(...)"`, `js-yaml` parse — both clean). **Full verification requires watching the next real push to `main`** — confirm a release PR is opened rather than the workflow failing in ~10-18 seconds like every prior run.
- **Commit:** `706a2b2`.

## Held for the owner / a dedicated pass (not fixed this session, by explicit scope choice)

These are documented in detail in [05_Security_Audit.md](05_Security_Audit.md) and [13_Roadmap.md](13_Roadmap.md) — listed here only as a pointer, since they were surfaced during the same review pass that found the two fixes above:

1. `payment_screenshots` storage bucket's public/private flag — needs the owner's production Supabase dashboard access to re-verify; cannot be confirmed or changed from this sandboxed environment.
2. `next@14.2.35` CVE exposure — needs its own careful upgrade-and-regression-test pass, not a same-session drive-by fix.
3. Website i18n partial coverage — a product scope decision, not a bug.

## Fix count

**2 fixed and verified, 3 reported and held for a separate pass, 0 remaining that meet this audit's CRITICAL bar.**
