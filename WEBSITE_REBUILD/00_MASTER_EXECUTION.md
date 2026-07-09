# 00 — MASTER EXECUTION

## PURPOSE
Defines the order of work, the gates between phases, and when a model may auto-continue
to the next file versus stop for approval.

## PHASE PLAN

| Phase | Task files | Gate to pass |
|---|---|---|
| 1 — Foundation | 01, 02, 03 | Validation green + content system live + both themes AA-verified |
| 2 — Homepage DOM | 04 | Homepage rebuilt in place as fast DOM site (no 3D); route groups live; old routes still render |
| 3 — Motion & cursor | 05, 06 | Scroll story + cursor working; reduced-motion paths verified; **mobile experience complete** |
| 4 — 3D scene | 07 | Desktop scene live with full fallback matrix; Lighthouse budgets still green |
| 5 — All pages | 08, 09, 10, 11 | Every route rebuilt on the design system |
| 6 — Portal | 12, 13 | Student login + Flutter Web dashboard working end-to-end |
| 7 — Hardening | 14, 15, 16, 17 | SEO/perf/a11y/testing gates all green |
| 8 — Ship | 18, 19 | Deployed, flag flipped, launch checklist signed |

## EXECUTION RULES

1. Files execute in numeric order. A file may only start when every file in the previous
   phase reports COMPLETE in `STATUS.md`.
2. **Auto-continue is the default** — within phases AND across phase gates. A gate is a
   self-validating checkpoint: write the gate report into `STATUS.md`, verify every gate
   criterion honestly, then continue. Do not wait for human approval at gates.
3. **Human approval is required ONLY at business checkpoints:**
   - `19_LAUNCH.md` step 1 (the launch itself), and
   - any `PLACEHOLDERS.md` § Pending-business-decision row that blocks user-visible value.
   Everything else is engineering and belongs to the executor
   (see 99 → Autonomy charter).
4. Within a task file: never skip validation. Step ORDER may be improved via the
   charter's deviation protocol (document in EVOLUTION LOG + update the task file);
   validation content may be strengthened, never weakened.
5. Parallel work is forbidden (single writer). Exception: `07_SCENE_3D.md` Step 1
   (mesh sourcing) may start any time after Phase 1 because it is research-only.
6. Precedence on conflict: `PROJECT_RULES.md` > `99_MODEL_INSTRUCTIONS.md` (charter) >
   task files > model habit. The charter lets you REPLACE a task-file approach with a
   documented better one; it never lets you break a PROJECT_RULE.
7. Long-lived branch hygiene: rebase `rebuild/living-anatomy` onto `main` at every phase
   gate (main may receive hotfixes). Conflicts → resolve favoring main's fixes, re-run
   validation.

## FAILURE PROTOCOL

- Validation fails and cannot be fixed within the task's FILES ALLOWED scope →
  set STATUS = BLOCKED, write the exact failing command + shortest decisive error line
  into `STATUS.md` → Problems, stop.
- A required INPUT file is missing → follow that task file's IF MISSING rule; default:
  create the minimal missing artifact if the task file says so, else BLOCKED.
- Business data missing → `PLACEHOLDERS.md` entry + labeled placeholder + continue
  (never invent, never silently stop).
- Environment broken (npm install fails, node version wrong) → BLOCKED with the exact
  error; do not attempt system-level installs without approval.

## RELEASE STRATEGY (branch-as-flag — no runtime flags)

- The rebuild happens IN PLACE on branch `rebuild/living-anatomy`. No
  `NEXT_PUBLIC_NEW_HOME` runtime flag, no dual homepage in the bundle, no
  `home-legacy/` directory: the old homepage lives in git history, the branch preview
  deployment IS the review surface, **merge to main = launch**, rollback = promote the
  previous production deployment (rehearsed in 18).
  _Why (EVOLUTION LOG E-001): a runtime flag ships two homepages in one bundle, keeps
  legacy imports alive for months, and adds a flag-drift failure mode — for zero benefit
  over branch previews, which Vercel/CI provide free._
- Replaced components (old Cursor, Marquee, StatsBand…) are deleted in the SAME task
  that replaces them — on this branch nothing orphaned survives a task's validation
  (`knip`/import-grep check per task). Git history is the archive.
- Portal (login + dashboard) dark-launches structurally: routes exist but the nav link
  appears only after `13_FLUTTER_WEB.md` validation passes (a content-level condition,
  not an env flag).

## ARCHITECTURE BASELINE (route groups — set up in 03/04)

```
app/
  layout.tsx          # root: fonts, ThemeProvider, JsonLd — nothing heavy
  (marketing)/
    layout.tsx        # Lenis, ScrollProgress, YogaCursor, Nav, Footer, WhatsApp/StickyCta
    page.tsx          # homepage (Living Anatomy)
    about/ founder/ trainers/ programs/ pricing/ membership/ schedule/
    events/ gallery/ testimonials/ faq/ blog/ contact/ verify/
    privacy/ terms/ refund/
  (portal)/
    layout.tsx        # minimal: no Lenis, no cursor, no scene — fast app chrome
    login/ portal/ logout/
  api/                # unchanged
```
Route groups don't change URLs. The portal never pays for marketing JS; the marketing
layout owns all experience providers. This replaces v1's "mount everything in root
layout" inherited from the old site (EVOLUTION LOG E-002).

## DEFINITION OF DONE (project level — from the approved brief)

- Every page implemented on the design system (D008 list).
- Student login works (existing Supabase auth, students only).
- Flutter Web integration works from the student dashboard.
- Centralized content system: zero hardcoded business data
  (`grep` gate in `02_CONTENT_SYSTEM.md` VALIDATION).
- `PLACEHOLDERS.md` complete and every placeholder labeled in content files.
- Fully responsive; no overflow, no CLS from any breakpoint.
- Performance: Lighthouse desktop ≥95, mobile ≥90, LCP <2.0s, CLS <0.05, INP <150ms.
- Accessibility: WCAG 2.2 AA (16_ACCESSIBILITY gates).
- SEO complete (14_SEO gates).
- Docs updated: STATUS, CHANGELOG, DECISIONS, ADRs 0015/0016 written.
