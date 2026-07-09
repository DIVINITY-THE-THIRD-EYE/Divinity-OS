# 01 — REPOSITORY PRECHECK

## PURPOSE
Verify the repository is in a known-good state and create the working branch. Nothing is
built here.

## INPUTS
- `STATUS.md` (this playbook) — IF MISSING: STOP, playbook is corrupted.
- Repo root `README.md` — IF MISSING: continue, note in STATUS.

## OUTPUTS
- Branch `rebuild/living-anatomy` created and checked out.
- Clean working tree (prior uncommitted work committed, not discarded).
- Baseline validation recorded in `STATUS.md`.

## FILES ALLOWED
- Git state only. `STATUS.md`, `CHANGELOG.md`.

## FILES FORBIDDEN
- Everything else. No source edits in this task.

## STEPS

1. Run `git status --short` from repo root.
   - IF the working tree has uncommitted changes: inspect with `git diff`.
     Expected leftovers (from 2026-07-09): trainer-section removal in
     `website/app/page.tsx`, framer-motion bump in `website/package*.json`,
     `.gitignore` addition. Commit them on the CURRENT branch:
     `chore(website): park pre-rebuild working tree (trainer section removal + framer-motion bump)`.
   - IF the diff contains anything NOT in that expected list: do not commit it blind —
     record each unexpected file in `STATUS.md` → Problems, then commit only the expected
     files and leave the rest untouched. Continue.
2. Run `git checkout main && git pull` (if pull fails from no network, continue on local main).
3. Create branch: `git checkout -b rebuild/living-anatomy`.
4. Baseline validation (record results in STATUS):
   ```bash
   cd website && npm install && npm run lint && npx tsc --noEmit && npm test && npm run build
   ```
5. Record in `STATUS.md`: node version (`node -v`), route count
   (`ls website/app`), and build result.
6. Secret scan sanity: confirm `.env*` and `keyfile/` are gitignored
   (`git check-ignore website/.env.local keyfile` — both must be ignored;
   if not, add to `.gitignore` and note it).

## VALIDATION
- `git branch --show-current` prints `rebuild/living-anatomy`.
- `git status --short` is empty.
- Step 4 all green.

## IF VALIDATION FAILS
- Baseline build red on an untouched repo → BLOCKED. Paste the shortest decisive error
  into STATUS. Do not "fix" application code in this task.

## STOP CONDITION
Branch created, baseline green, STATUS updated. Auto-continue to `02_CONTENT_SYSTEM.md`
(same phase).

## NEXT
`02_CONTENT_SYSTEM.md`
