# Audit Status — audit/full-review-loving-einstein

Started: 2026-07-05
Branch: audit/full-review-loving-einstein (audit/full-review was taken by another worktree)

## Phase 0 — Safety: DONE
- git status was clean, nothing to checkpoint-commit
- created branch audit/full-review-loving-einstein

## Phase 1 — Read: IN PROGRESS
Scope discovered:
- flutter-app/lib: 158 dart files, test+integration_test: 32 files
- website: 97 ts/tsx files (app/components/lib/sanity)
- supabase: 45 migration files, 1 edge function (verify-certificate)
- docs: 57 files (PROJECT_BIBLE + top-level audit docs — known stale per prior memory)
- scripts: 2 files
- .github: 16 workflow/config files

Prior context (from persistent memory, dated 2026-07-02, MUST re-verify not trust):
- Last audit found all gates green: flutter analyze+test(262/262), website tsc+lint+test(61/61)+build, supabase pgTAP(117 assertions)
- 20 RLS-enabled tables, 36 migrations then (now 45 — grew), 16 pgTAP files
- Large PRD decision backlog exists (docs/PROJECT_BIBLE + memory) with many CONFIRMED BUT NOT YET BUILT features:
  Plans module (admin-manageable), broadcast notifications, hybrid enrollment w/ pending state,
  admin audit log, support ticket SLA text, screenshot-to-text conversion, drop-off risk alerts,
  trainer certifications (public+approval), i18n Hindi/English, waitlist, self-service renewal,
  renewal reminders (7d/1d), auto certificate issuance, trial-class tracking, lead conversion by trainer/self,
  paid events, admin/trainer reports (4 report types)
- In-repo docs/AUDIT1JULY.MD, IMPLEMENTATION1JULY.MD flagged as STALE/superseded
- git log since last audit: 8b2d926 "fix stale c12 assertion for Trainer report access", 4fa771c dart format, PR #19 merge "post-merge-ci-fixes"

## Next
- Re-run verification gates fresh (ground truth, don't trust 3-day-old memory)
- Then systematic architecture read per surface

## Verification gates — re-run fresh 2026-07-05 (ground truth, this session)
- `flutter analyze` (flutter-app): CLEAN, no issues (158.7s)
- `flutter test` (flutter-app): 262/262 PASS
- `npm install` (website): required — node_modules was NOT present, installed clean (451 packages).
  `npm audit`: 10 vulnerabilities (1 critical, 5 high, 4 moderate) — all in devDependency chains
  (vite/vitest/esbuild) and next@14.2.35 itself (many known Next.js CVEs: SSRF, DoS, cache poisoning,
  XSS-via-CSP-nonce, request smuggling). Next.js is NOT on latest 14.2.x patch — needs version-bump review.
- `npx tsc --noEmit` (website): CLEAN
- `npm run lint` (website): CLEAN
- `npm run test` (website, vitest): 66/66 PASS (grew from 61 in last audit)
- `npm run build` (website): SUCCESS, 36 static/dynamic routes generated cleanly
- `supabase start` + `supabase test db` (pgTAP): 188 total assertions, **2 FAILED** in
  c17_leave_business_rules_test.sql (tests 13-14).

### Investigated: c17 test failures — ROOT CAUSE FOUND, NOT a production bug
- Failing assertions test "a same-day (<24h advance) leave request stays PENDING".
- Root cause: test env's `current_date` (2026-07-05) is a **Sunday** (isodow=7, a week-off day per
  `is_week_off()`). The test inserts `start_date = current_date` directly (supabase/tests/c17_leave_business_rules_test.sql:188-209)
  without walking forward to a guaranteed non-week-off day, unlike its own date1/2/3 fixtures
  (same file lines 50-63) which explicitly do that walk *for this exact reason* (see file's own
  header comment lines 14-17 acknowledging this flakiness class for other tests).
  When start_date is a week-off, `process_leave_request()` (supabase/migrations/039_leave_business_rules.sql:132-137)
  legitimately auto-approves via the (separate, correct) "entire range is week-offs, nothing to
  approve" rule — colliding with the late-request assertion.
- VERIFIED the actual late-request business logic IS correct: manually inserted a leave request
  for a real weekday (current_date+1, Monday, isodow=1) in a rolled-back transaction ->
  status=PENDING, is_auto_approved=false, exactly as the PRD requires. See conversation for the
  live psql proof (docker exec supabase_db_Divinity_TTE).
- Classification: MEDIUM — test suite fragility (day-of-week-dependent flakiness), not a
  business-logic defect. Localized, low-risk one-file fix available (mirror the date1/2/3
  forward-walk pattern for the late-request fixture). NOT applying yet — not CRITICAL, holding
  for Phase 2 checkpoint approval per ground rules.

## Task list (this session)
- [x] Phase 0 safety
- [x] Re-run all verification gates
- [ ] Architecture map per surface (flutter-app, website, supabase) — IN PROGRESS
- [ ] Feature inventory cross-check vs docs/PROJECT_BIBLE confirmed-decisions memory
- [ ] Security audit (RLS, auth, secrets, input validation)
- [ ] DB schema / ER diagram
- [ ] Code quality / dead code
- [ ] UI/UX per surface
- [ ] Testing coverage gaps
- [ ] DevOps/CI review
- [ ] Skills & tools section
- [ ] Roadmap
- [ ] Phase 2 checkpoint — present findings, wait for approval

## Website architecture map (Explore agent, completed)
- App Router, 16 pages + 3 API routes. Sanity CMS optional w/ local lib/content.ts fallback (fetchOrFallback pattern).
- Theme: --void/--bone/--ember tokens in app/globals.css, dark/light toggle EXISTS (ThemeContext.tsx),
  correctly overrides ADR-0012 per decision #3, wired in Nav.tsx (desktop+mobile).
- i18n: lib/i18n/translations.ts — Hindi+English, but ONLY 17 UI strings (nav/footer/homepage hero).
  NOT full page-by-page translation. GAP vs decision #18 ("all user-facing screens... in scope").
- Security: CSP+HSTS+X-Frame-Options all present (next.config.mjs), contact/subscribe routes have
  rate-limit (in-memory, 5/min/IP), honeypot, HTML-escaping, length guards. verify-certificate has
  regex validation + graceful env-var fallback. No secrets hardcoded (all via process.env, all with
  safe fallbacks). No dead code/TODOs found in website/.
- CONFIRMED (my own read): in-memory rate limiter is a real, if minor, concern on serverless/Vercel
  multi-instance deployments — each cold instance gets its own Map, so the "5/min/IP" limit is
  weaker in practice than the single-instance comment implies. MEDIUM, report only.

## Manual security spot-checks (me, not agents)
- No committed secrets: .env* gitignored, only .example files tracked. Firebase apiKeys in
  firebase_options.dart/google-services.json/GoogleService-Info.plist are public client IDs by
  design (not secret) — no private_key/client_secret fields found.
- supabase/migrations/009_lock_privileged_fields.sql: verified server-side trigger correctly blocks
  self-promotion (role/plan_status/expiration_date/streak fields), matches client-side defense-in-depth
  in flutter-app/lib/features/auth/data/auth_repository.dart:141-155. GOOD, no bug.
- CI: release-please broken on EVERY run since introduction — confirmed via `gh run list`
  (release-flutter.yml and release-website.yml both fail in ~10-18s every single push to main since
  2026-07-01). Root cause: passes package-name/changelog-types inputs that
  googleapis/release-please-action@v4 rejects (needs manifest-config format instead). Still broken,
  matches prior memory. HIGH, localized+low-risk fix available, holding for checkpoint.
- i18n IS implemented on flutter-app too: lib/l10n/app_en.arb + app_hi.arb + generated
  AppLocalizations, locale_provider.dart, switcher wired in profile_screen.dart. Need agent's
  Flutter report to confirm coverage depth (full vs partial like website).
- Migrations grew from 36 (last audit) to 45. New migrations 037-045 map directly onto PRD decisions
  previously flagged "not yet built": 037 remove_razorpay (decision #2), 038 plans_module (#4),
  039 leave_business_rules (#1, see c17 test analysis above), 040 enrollment_waitlist (#24),
  041 trials_and_lead_conversion (#31/#32), 042 certificate_automation (#33),
  043 notifications_and_admin_ops (audit log #14 + broadcast #43 — need to verify depth),
  044 trainer_surfaces (#40), 045 event_payments (#37/#38). MAJOR positive finding: codebase has
  advanced substantially since 2026-07-02 audit; most previously-open PRD items now appear built.
  Must verify each individually before crediting as "complete" in feature table.

## Flutter architecture map (Explore agent, completed)
- main.dart:36-92 entry point; Supabase+Firebase init clean; go_router + role_shell.dart:40 dispatches
  Admin/Trainer/Student shells. State mgmt: consistent AsyncNotifier pattern across all 22 features,
  no mixed StateNotifier/Notifier inconsistency. 24 repos, all Supabase-backed except WeatherRepository
  (external API). Error handling consistent (repo throws -> notifier catches -> UI snackbar).
  Theme: single source lib/core/theme/app_theme.dart, explicitly cites website tokens in a comment
  (cross-surface consistency confirmed, matches decision #3). i18n: FULLY wired (arb files, generated
  delegates, StateNotifier, persistence, switcher in profile_screen.dart:392-397) — fuller than the
  website's i18n (only 17 chrome strings). Only 1 TODO found repo-wide: fcm_service.dart (in-app
  banner missing, low impact, FCM push itself works).

## Supabase architecture map (Explore agent, completed) — DEFINITIVE current counts
- 25 tables (not 12/19/20 as stale docs claim), all RLS enabled, every table has >=1 policy, none
  fully locked. 45 migrations, gapless, no reverts/contradictions.
- 40+ functions, 35+ triggers, mostly SECURITY DEFINER (correct pattern to avoid RLS recursion,
  matches is_admin()/is_trainer() helper pattern from the 012 recursion fix).
- audit_log table (043) EXISTS: logs PAYMENT_VERIFIED, ROLE_CHANGED, STUDENT_SUSPENDED/REACTIVATED,
  PLAN_PRICE_CHANGED — matches decision #14 scope exactly (sensitive actions only, not full activity log).
- send_broadcast() RPC exists (043) — matches decision #43.
- send_renewal_reminders() exists AND is scheduled via pg_cron (daily 08:00 IST) with a graceful
  raise-notice fallback if pg_cron unavailable in-env — matches decision #36, well engineered.
- 23 pgTAP files, 176 assertions (not 117 as stale docs claim — grew with the new migrations).
- verify-certificate edge function: validates code regex, uses service_role key server-side (never
  exposed to client), returns ONLY masked name (first name + last initial) + programme + issued date
  — good PII hygiene, matches "PII-safe" design intent.

## Additional confirmed-decision cross-checks (me, direct verification)
- Self-service renewal (#29): CONFIRMED built — payments_screen.dart has _RenewSoonCard/_UnpaidRenewalCard.
- Screenshot-to-text conversion (#10): NOT built — no OCR/conversion code anywhere in repo. Expected
  per decision #10's own text ("not yet specified... needs follow-up"), not urgent, just not done yet.
- Trainer certifications (#12): built per migration 044 (users.certifications, published flag,
  admin-approval-required publish gate, auto-unpublish-on-edit trigger) — matches decision #12 exactly.

## SECURITY FINDING — payment_screenshots bucket public flag (HIGH, needs owner action, cannot self-verify prod)
- Migration 031's OWN comment states: "Supabase does not expose bucket-level public/private as SQL;
  it is configured via the Management API or the Studio UI... uncheck 'Public bucket'" — i.e. NO
  migration or code ever flips the bucket's public flag to false. It only adds RLS policies on
  storage.objects (which govern the *_authenticated_* access path, not the *_public_* URL path).
- VERIFIED locally: replaying all 45 migrations on a fresh local Supabase instance leaves
  `storage.buckets.payment_screenshots.public = true` (queried directly: see conversation).
- Prior memory claimed production was "confirmed private" via live check on 2026-07-02 — that
  was a one-time manual verification, NOT enforced by any committed artifact. There is no CI/cron
  check that would catch this drifting back to public (e.g. bucket recreation, project migration,
  accidental toggle). Since payment screenshots may contain UPI IDs/bank details (per decision #10),
  this is a real, if currently-mitigated, risk: sole protection is a manual dashboard setting nobody
  is watching. Recommend: (a) re-verify production bucket is still private via Supabase dashboard/
  Management API, (b) add an automated check (nightly cron or CI step hitting the Management API)
  that fails loudly if the flag ever flips back to public.
- NOT fixing directly: no production Supabase credentials/access from this sandboxed environment,
  and flipping production infra settings without explicit authorization would violate the "no
  irreversible action without confirmation" rule regardless.

## Ready for Phase 2 checkpoint
All gates re-run, 3 architecture maps complete, security spot-checks done, feature-decision
cross-check done for the highest-value items. Presenting findings to user now, holding all
non-critical fixes for approval. No CRITICAL-severity issue found (no exposed secrets, no confirmed
auth bypass, no data loss, no payment error, no core-flow crash) — so no immediate autonomous fix
was required this phase.

## Phase 3 — Implemented (user-approved: "all localized/low-risk fixes")
1. Fixed c17 pgTAP test fragility (supabase/tests/c17_leave_business_rules_test.sql) —
   commit 1cb10cf. Verified: `supabase test db` now 188/188 (was 186/188).
2. Fixed release-please CI (both workflows) — commit 706a2b2. Moved to v4 manifest-config
   pattern (release-please-config.json + .release-please-manifest.json per surface),
   verified against current googleapis/release-please-action + release-please docs via
   Context7 (not guessed from training data). Validated JSON parses (node) and YAML parses
   (js-yaml) for both workflow files. Could NOT verify end-to-end (would require an actual
   push to main to trigger the workflow, which is out of scope without explicit push
   authorization) — this is the limit of what's locally verifiable.
Held per user's explicit scope choice: payment_screenshots bucket re-verification (needs
owner's Supabase dashboard access), Next.js CVE version-bump (needs its own careful pass),
website i18n expansion (product scope decision).

## Phase 4 — Verify
- pgTAP: 188/188 PASS (re-run after fix)
- No Flutter or website app code was touched in Phase 3, so flutter analyze/test and
  website tsc/lint/test/build results from the earlier fresh run still hold (all green,
  see gates section above).

## Phase 5 — Reports: IN PROGRESS
Writing to /project_audit/

## Phase 5 — Reports: DONE
Wrote all 17 files to /project_audit/. Also created root CLAUDE.md (none existed) per the
audit brief's instruction to leave future sessions with accurate project state.

## Final counts
- 2 fixes applied and verified (pgTAP test fragility, release-please CI).
- 3 findings reported and explicitly held for the owner/a dedicated pass (bucket privacy
  re-verification, Next.js CVE upgrade, website i18n scope decision).
- 0 CRITICAL-severity issues remaining or found.
- Progress: 100% of this session's planned scope complete.

## Audit complete

## Round 2 — Complete audit redo (2026-07-05, post-merge, triggered by /goal)

Triggered by user's `/goal redo the complete audit and automerge when ready`. PR #20 (round 1) had
already merged to main. Repo is now public.

### Approach
Checked `git diff` between pre-audit baseline (1fcd93a) and current main (5fab127): only CI config
files and one pgTAP test changed — zero application code changed. This meant round 1's architecture/
feature/database/UI-UX findings are still valid without re-deriving from scratch. Focused round 2 on:
1. Re-running all verification gates fresh against current main (all green).
2. Refreshing the reports that were genuinely stale: 05_Security_Audit.md, 11_DevOps_Report.md,
   16_Executive_Summary.md, 17_Project_Health_Score.md, 01_Project_Overview.md, 14_Critical_Fixes.md
   — all updated in place with round-2 notes rather than duplicated into parallel files.

### Gates re-verified (branch: audit/full-review-round2, off updated main)
- flutter analyze: clean
- flutter test: 262/262
- website lint: clean, tsc: clean, test: 66/66, build: success
- supabase test db (pgTAP): 188/188 (c17 fix holds even though today is still the same Sunday date
  in this environment — confirms the fix, not just luck)

### No new CRITICAL or HIGH issues found
Nothing in the codebase changed since round 1, and round 1 already found no CRITICAL issues. The
public-repo re-audit (already committed to main via docs from the prior conversation turn) covered
the only genuinely new surface (GitHub-native security tooling).

### Health score updated
8.1/10 -> 8.5/10 (DevOps 7->9, Security code-score unchanged at 8 but tooling gap closed). See
17_Project_Health_Score.md for full reasoning.

## Round 2 complete
