# PROJECT RULES (absolute — no task file may override these)

## Never

1. Never invent statistics, member counts, or success numbers.
2. Never invent testimonials or quotes.
3. Never invent founder/trainer credentials, certifications, or biography facts.
4. Never invent pricing, offer terms, or legal text.
5. Never hardcode business data in components — all business data comes from
   `website/content/` (see `02_CONTENT_SYSTEM.md`).
6. Never remove or weaken accessibility (skip link, focus styles, reduced-motion paths,
   aria attributes, semantic landmarks).
7. Never sacrifice the performance budgets (`15_PERFORMANCE.md`) for a visual effect.
   If a feature cannot fit the budget, use its defined fallback — do not ship it broken.
8. Never put indexable content inside WebGL/canvas. All copy is real DOM.
9. Never create a second authentication system. Website login = existing Supabase auth,
   same users, same database (`12_STUDENT_LOGIN.md`).
10. Never duplicate business logic that already exists in the Flutter app or Supabase
    (RLS/RPC are the single enforcement layer).
11. Never commit secrets. `.env*`, keys, tokens stay out of git. Run a staged-diff secret
    scan before every commit (`guard-secrets` skill or manual grep).
12. Never modify `supabase/migrations/` in ordinary website tasks. Only
    `12_STUDENT_LOGIN.md` may touch Supabase config, and only additively.
13. Never modify `flutter-app/lib/` in website tasks. Only `13_FLUTTER_WEB.md` may touch
    `flutter-app/`, and only its `web/` build configuration.
14. Never delete files outside the current task's "FILES ALLOWED" list.
15. Never mark a task complete with failing lint/type/test/build.
16. Never ignore a failing test by skipping/deleting it. Fix the cause.

## Always

0. Always document deviations from the playbook in `DECISIONS.md` → EVOLUTION LOG
   (what changed · why better · what replaced · trade-offs) and update the affected
   task file. Autonomy (D011) never means silent divergence.
1. Always update `STATUS.md` after every completed task.
2. Always update `CHANGELOG.md` with what changed.
3. Always register missing business data in `PLACEHOLDERS.md` with a TODO description.
4. Always check `DECISIONS.md` before asking any question — decided = never re-ask.
5. Always run the full validation block before declaring a task done.
6. Always keep the repository in a buildable state at the end of every work session.
7. Always verify third-party asset licenses BEFORE the asset enters the repo
   (record license + source URL in `DECISIONS.md` → Asset registry).
8. Always honor `prefers-reduced-motion` with a defined non-animated variant.
9. Always keep mobile behavior explicitly defined — mobile is not a shrunken desktop.
10. Always write new UI against the design tokens (`03_DESIGN_SYSTEM.md`), never raw hex
    values in components.

## Git discipline

- Work on branch `rebuild/living-anatomy` (create from `main` in `01_REPO_PRECHECK.md`).
- Commit at the end of every completed task file, message format:
  `feat(rebuild): <task file> — <one-line summary>`.
- Never force-push. Never rewrite history. Never commit directly to `main`.
