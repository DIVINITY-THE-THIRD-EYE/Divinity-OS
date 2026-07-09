# STATUS — live project state

> Updated after EVERY completed task. Newest entry on top. If you are a model starting a
> session: read the top entry, then open the file named in NEXT.

## Current

| Field | Value |
|---|---|
| Phase | 1 — Foundation (01, 02 complete) |
| Next file | `03_DESIGN_SYSTEM.md` |
| Branch | `rebuild/living-anatomy` (created, checked out) |
| Blockers | none |

## Known repo state (as of 2026-07-09, playbook creation)

- Branch at playbook creation: `docs/session-audit-and-verification`
- Uncommitted diff exists: trainer section removed from `website/app/page.tsx`,
  `framer-motion` bumped `11.5.4 → 11.18.2`, `.gitignore` +`graphify-out/`.
  Precheck decides: commit as-is on current branch, THEN branch. Trainer section
  returns in `04_HOMEPAGE.md` regardless — no content lost.
- Website: Next.js 14, builds green, Vitest + Playwright present.
- Supabase: 36 migrations, production project `divinity-tte` linked.
- No Supabase JS client in website yet (login task adds it).

## Log (append-only, newest first)

### 2026-07-09 — 02_CONTENT_SYSTEM complete
- Phase: 1
- Status: COMPLETE
- Changes: created `website/content/` (18 modules: site, contact, social, founder,
  trainers, programs, pricing, offers, statistics, testimonials, gallery, events,
  posts, faq, schedule, seo, legal, marketing, + index.ts barrel). Moved every
  fallback data constant out of `lib/content.ts` verbatim into the matching module.
  Split the old flat `site` object across `site.ts`/`contact.ts`/`social.ts`/
  `founder.ts`; `lib/content.ts` rewritten as a compat/merge layer that
  reassembles the legacy `site` shape and re-exports every old name — zero
  consumer import changes needed (verified: no `app/`or `components/` file edited).
  Added `content/content.test.ts` (55 tests: every module non-empty, site/contact
  critical fields real not placeholder, every `[PLACEHOLDER:` has a matching
  `TODO(PH-` in the same file). Added `content/**/*.test.ts` to
  `vitest.config.ts` include glob — required for the new test file to actually
  run; without it step 5 would silently be a no-op (documented per charter D011,
  see DECISIONS.md IN-001).
- New/forward-scaffolded modules not yet consumed by any component (wiring lands
  in later phases; creating them now was still in scope — `website/content/**` is
  unrestricted in FILES ALLOWED): `offers.ts` (introOffer/promoBar), `statistics.ts`
  (StatsBand still computes its own counts), `seo.ts` (route overrides table),
  `legal.ts` (privacy/terms/refund — real copy still lives in page JSX, migrates
  in 08/11).
- Hardcode sweep (`grep -rn "₹|+91|wa.me|@gmail|@divinity" app components --include=*.tsx -l`):
  3 hits, all pre-existing `₹99 first week` copy in `app/page.tsx`,
  `components/BreathHero.tsx`, `components/PromoBar.tsx`. NOT fixed here —
  `FILES FORBIDDEN` for this task explicitly excludes "Components' JSX/logic,
  app/ pages"; wiring these three to `content/offers.ts`'s `introOffer` is a
  JSX edit that belongs to `04_HOMEPAGE.md` (which owns that page/component).
  Allowed exception per this task's own VALIDATION clause.
  `components/ui/CtaLink.tsx` hit is a code *comment* mentioning "wa.me" as an
  example, not a real hardcode — no action needed.
- Validation: `npm run lint` clean · `npx tsc --noEmit` clean · `npm test` →
  11 files, 121 tests passed (was 66; +55 new content tests) · `npm run build`
  → 36 routes, same route count/shape as baseline (one `.next` EINVAL cleanup
  needed first — stale OneDrive-locked build dir from before this session,
  unrelated to the code change; `rm -rf .next` then rebuild was clean).
- Tests: 121/121 passed
- Performance: unchanged (no runtime behavior changed, pure data relocation)
- Accessibility: unchanged
- Problems: none blocking. PLACEHOLDERS.md rows already pointed at the exact
  `content/*.ts` files/fields this task created — no table edits needed.
- Next: `03_DESIGN_SYSTEM.md`

### 2026-07-09 — 01_REPO_PRECHECK complete
- Phase: 1
- Status: COMPLETE
- Changes: committed parked pre-rebuild diff on `docs/session-audit-and-verification`
  (`50ecadc` — trainer section removal, framer-motion bump, `.gitignore` graphify-out/);
  `git checkout main` (no network for pull, continued on local main per rule);
  created + checked out `rebuild/living-anatomy`.
- Baseline validation (all green):
  - `node -v` → v26.5.0, `npm -v` → 11.17.0
  - `npm install` → up to date, 452 packages (10 audit vulnerabilities pre-existing,
    unrelated to this task — not fixed here, out of FILES ALLOWED scope)
  - `npm run lint` → No ESLint warnings or errors
  - `npx tsc --noEmit` → clean, no output
  - `npm test` (vitest) → 10 test files, 66 tests, all passed
  - `npm run build` (next build) → Compiled successfully, 36 routes generated
  - route count: `ls website/app` → 25 entries
  - secret scan: `git check-ignore website/.env.local keyfile` → both ignored (exit 0)
- Tests: 66/66 passed
- Performance: baseline unchanged (no app code touched)
- Accessibility: baseline unchanged
- Problems: none
- Next: `02_CONTENT_SYSTEM.md`

### 2026-07-09 — Playbook evolved (autonomy charter + architecture)
- Phase: 0
- Status: COMPLETE (docs only, no application code)
- Changes: D011 autonomy charter (engineering decisions belong to executor; human
  approval only for business rows + launch) · D012 branch-as-flag release (runtime
  flags removed everywhere; E-001) · route-group architecture `(marketing)`/`(portal)`
  (E-002) · per-task deletion rule (no orphans) · phase gates now self-validating
  auto-continue · PLACEHOLDERS gained "Pending business decisions" (BD-001…BD-004) ·
  rebase-at-gate rule for the long-lived branch.
- Problems: none
- Next: `01_REPO_PRECHECK.md` (execution NOT started — awaiting owner's go)

### 2026-07-09 — Playbook authored
- Phase: 0
- Status: COMPLETE
- Files modified: `WEBSITE_REBUILD/*` (created)
- Tests: n/a (no code changed)
- Performance: baseline unchanged
- Accessibility: baseline unchanged
- Problems: none
- Next: `01_REPO_PRECHECK.md`
- ETA to next gate: precheck ≈ 30 min of model time
