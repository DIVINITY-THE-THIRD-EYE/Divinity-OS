# 06 — YOGA CURSOR (Surya Namaskar morph)

## PURPOSE
Replace the dot+ring cursor with a single SVG silhouette that morphs through the 12
Surya Namaskar poses as the user scrolls. Zero dependencies, ~3 kB.

## INPUTS
- `05_MOTION_SCROLLSTORY.md` COMPLETE (`useScrollProgress()` exists).
- Existing `website/components/Cursor.tsx` (position/hover mechanics to reuse).

## OUTPUTS
- `website/components/YogaCursor.tsx` (replaces Cursor mount in `layout.tsx`).
- `website/components/cursor-poses.ts` — 12 pose paths as string constants.

## POSE DATA RULES (critical for a weak model — follow exactly)
- 12 poses: Pranamasana, Hasta Uttanasana, Padahastasana, Ashwa Sanchalanasana,
  Dandasana, Ashtanga Namaskara, Bhujangasana, Adho Mukha Svanasana,
  Ashwa Sanchalanasana, Padahastasana, Hasta Uttanasana, Pranamasana.
- Every path MUST have the IDENTICAL command sequence and point count (author pose 1,
  then move points only). Single `<path>`, viewBox `0 0 100 100`, stroke-only silhouette.
- Do NOT add a morphing library. Interpolation: `pose = floor(progress*11)`,
  `t = fract(progress*11)`, lerp numeric tokens of path pose→pose+1.
  Parse paths ONCE on mount into number arrays; per-frame work = lerp + join.
- IF authoring equal-point-count paths proves infeasible → FALLBACK (do not stop):
  crossfade between pose SVGs (opacity swap over 120ms at segment boundaries). Record
  fallback choice in DECISIONS Implementation notes.

## BEHAVIOR
- Position: reuse existing lerp-follow (dot logic) — silhouette follows at ease 0.16.
- Scroll drives pose via `useScrollProgress()`; on non-home routes (no provider) hold pose 1.
- Hover on `a, button, [data-hover]`: scale 1.4 + accent color (reuse existing grow logic).
- Render ONLY when `(hover:hover) and (pointer:fine)` and NOT reduced-motion — otherwise
  native cursor (never hide native cursor without the replacement active — existing
  `has-custom-cursor` class mechanism stays).
- `aria-hidden`, `pointer-events:none`, z-index above content, `mix-blend-difference` kept.

## FILES ALLOWED
- `website/components/YogaCursor.tsx`, `website/components/cursor-poses.ts`
- `website/app/layout.tsx` (swap mount), `website/app/globals.css` (cursor rules only)
- Old `Cursor.tsx`: keep file (legacy home unaffected paths) — delete at launch (19).
- STATUS/CHANGELOG.

> **Amended (E-007 in DECISIONS.md):** swap happened in
> `app/(marketing)/layout.tsx`, not `app/layout.tsx` — Cursor.tsx has lived in
> the marketing layout since 04's route-group restructure, which predates
> this task file. Root layout was never touched. Also: no path-parity unit
> test (crossfade fallback taken — see below); added
> `components/cursor-poses.test.ts` instead, and
> `components/cursor-poses.test.ts`/`components/YogaCursor.tsx` needed
> `vitest.config.ts` and `e2e/yoga-cursor.spec.ts` touched too (IN-004).

## FILES FORBIDDEN
Everything else.

## STEPS
1. Author `cursor-poses.ts` (pose 1 first, derive others). Add a dev-only route or
   Storybook-less test page? NO — instead add a Vitest unit: all 12 paths parse to the
   same command/point count.
2. Build `YogaCursor` per BEHAVIOR. One rAF loop total (position + morph in same frame).
3. Swap mount in `layout.tsx`.
4. Manual check: move mouse, scroll full page (pose cycles 1→12), hover links (grows),
   touch emulation (native cursor, component absent), reduced motion (native cursor).

## VALIDATION
- Standard block + the path-parity unit test.
- Preview at 6x CPU throttle: no visible lag on scroll (single rAF, no per-frame parsing).

## IF VALIDATION FAILS
- Jank → confirm paths pre-parsed; confirm no React state per frame (DOM refs only).
- Morph looks broken → point counts differ; fix data, or take documented crossfade fallback.

## CHECKPOINT
Commit: `feat(rebuild): 06 yoga cursor — Surya Namaskar scroll morph`

## STOP CONDITION
Phase 3 gate (mobile experience complete). Gate report + rebase → auto-continue (D011).

## NEXT
`07_SCENE_3D.md`
