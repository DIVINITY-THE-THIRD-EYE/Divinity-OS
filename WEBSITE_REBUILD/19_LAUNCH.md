# 19 — LAUNCH (final gate)

## PURPOSE
Flip the site live, delete the legacy code, leave the repo clean and documented.

## PRECONDITIONS (verify each; any FAIL → do not launch)
- [ ] Phases 1–7 COMPLETE in STATUS; Phase 8 preview verified (18).
- [ ] `PLACEHOLDERS.md`: every row is DONE or CONFIRM-accepted by owner, OR its
      placeholder renders acceptably and its page is noindex where required.
      **Owner sign-off required on: PH-004 (stats), PH-005 (₹99 terms), PH-013 (contact).**
- [ ] Budgets green on preview (18 numbers).
- [ ] A11y matrix green (16).
- [ ] Full CI green.
- [ ] Rollback steps tested (18).

## LAUNCH STEPS (order matters — normal prose)
1. Owner gives explicit "launch" approval (BD-001). Without it, stop here. This is the
   ONLY human approval gate in the playbook (D011).
2. Rebase `rebuild/living-anatomy` onto `main` one final time; CI green.
3. Merge to `main` via PR (CI must pass on the PR). Merge = launch (D012): production
   deploys the new site.
4. Production smoke (within 30 min): home renders (both themes), pricing, contact form
   send, login round-trip, app link/embed, sitemap fetch, robots fetch.
5. Cleanup sweep (only after step 4 passes): the per-task deletion rule (04 §7) means
   little should remain — run `npx knip`/import grep once more; anything orphaned plus
   unreferenced `public/` assets from the 15 audit: LIST first, delete in ONE commit.
6. Reset visual-regression baselines if step 5 deleted anything. CI green.
7. Docs close-out: STATUS final entry · CHANGELOG · `sync-project-docs` skill if in
   Claude Code (PROJECT_BIBLE 04/11/13 sections touching the website, DECISION_LOG) ·
   root README website description if changed.

## IF PRODUCTION SMOKE FAILS
Execute the rollback from 18 immediately (promote the previous production deployment).
Diagnose on the branch preview. Never debug live.

## POST-LAUNCH (register, don't do now)
- Commissioned mesh swap (D002 note) · Stage B embed if only A shipped ·
  real content for blog/events/testimonials → flip their noindex ·
  RUM/analytics decision (owner) · A/B on ₹99 CTA copy.

## STOP CONDITION
Production verified, legacy deleted, docs synced. PROJECT COMPLETE per
`00_MASTER_EXECUTION.md` Definition of Done — final report to owner.
