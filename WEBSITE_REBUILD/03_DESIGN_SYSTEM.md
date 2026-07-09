# 03 — DESIGN SYSTEM (tokens, day/night, typography)

## PURPOSE
Install the two-theme token system and typography scale every later task builds on.
Day/night is approved (D006). Both themes must pass WCAG AA before this task closes.

## INPUTS
- `website/app/globals.css` (current tokens) — IF MISSING: STOP.
- `website/tailwind.config.ts` — IF MISSING: STOP.
- `website/design/08-design-tokens.md` (reference spec) — IF MISSING: continue, tokens below are self-sufficient.
- `DECISIONS.md` D006, D009.

## REFERENCES (optional — never block on these)
If the environment has web access, study interaction/typography/pacing principles (do
NOT copy layouts) from: motionsites.ai · awwwards.com · cssdesignawards.com ·
webdesignawards.io/winners · winners.webbyawards.com · dribbble.com/tags/award-winning-website.
No web access → use `website/design/01/05/06/07` (principles already extracted there).

## OUTPUTS
- Semantic token layer in `globals.css` (`:root` = night, `[data-theme="day"]` = day).
- `ThemeProvider` + `ThemeToggle` components.
- Typography scale utilities.
- Tailwind mapped to semantic tokens (no raw hex in future components).

## TOKEN SPEC (exact values — do not improvise)

| Token | Night (default) | Day |
|---|---|---|
| `--surface` | `#15161e` | `#f4efe4` |
| `--surface-2` | `#1e2029` | `#e9e2d2` |
| `--surface-3` | `#2a2d38` | `#ddd4bf` |
| `--ink` | `#ece7db` | `#20242f` |
| `--ink-muted` | `#8e93a6` | `#5c6070` |
| `--accent` | `#d08a3e` | `#a85e2a` |
| `--accent-2` | `#2e5f4f` | `#5f7a5a` |
| `--line` | `rgba(208,138,62,0.16)` | `rgba(32,36,47,0.14)` |
| `--glow` | dark-blue/emerald radial set | gold/beige radial set |

Primitive palette (void/bone/ember…) stays defined but components use SEMANTIC tokens only.

Type scale (utilities or Tailwind theme entries):
`display-xl clamp(72px,16vw,210px)` (hero only) · `display-l clamp(40px,8vw,104px)` ·
`display-m clamp(36px,6vw,72px)` · `lead 18px/1.6` · `body 16px/1.6` · `caption 14px` ·
`eyebrow mono 11px/0.28em uppercase`. Add `text-wrap: balance` to display classes.

## FILES ALLOWED
- `website/app/globals.css`, `website/tailwind.config.ts`
- `website/components/ThemeProvider.tsx`, `website/components/ThemeToggle.tsx` (new)
- `website/app/layout.tsx` (mount provider + toggle; inline no-flash script)
- `website/components/Nav.tsx` (toggle placement only)
- `website/design/adr/0015-day-night-theme.md` (new ADR superseding 0012)
- STATUS/CHANGELOG.

## FILES FORBIDDEN
- Page files, other components (they get re-skinned in their own tasks), `content/`.

## STEPS

1. Add semantic tokens to `globals.css` exactly per spec. Keep all existing primitive
   variables so old components keep rendering (they migrate per-task later).
2. Map Tailwind colors to semantic tokens (e.g. `surface: "var(--surface)"`).
3. `ThemeProvider.tsx`:
   - Reads `localStorage("theme")`; absent → `matchMedia("(prefers-color-scheme: light)")`
     ? day : night (night is brand default when no light preference).
   - Sets `data-theme` on `<html>`. Exposes `useTheme()`.
   - Theme switch: if `document.startViewTransition` exists, wrap the attribute change in
     it; else plain swap with a 400ms CSS transition on color/background properties.
4. Inline `<script>` in `layout.tsx` `<head>` applying the stored theme before paint
   (no flash). Keep it under 15 lines, no dependencies.
5. `ThemeToggle.tsx`: real `<button>`, `aria-pressed`, visible focus, 24px+ target,
   labelled "Switch to day/night mode". Mount in `Nav`.
6. Write ADR `0015-day-night-theme.md`: status Accepted, supersedes 0012, records D006.
7. Contrast audit (mandatory): for BOTH themes check pairs ink/surface, ink-muted/surface,
   accent/surface, ink/surface-2 with an APCA/WCAG tool (or manual ratio calc). Record the
   ratios in the ADR. Every text pair ≥4.5:1 (normal) / ≥3:1 (large). If a pair fails →
   darken/lighten that token (stay in hue family), re-check, update the spec table in this file.

## VALIDATION
- Standard block (lint/tsc/test/build).
- Manual/preview check: toggle switches both directions, persists across reload, no
  flash-of-wrong-theme on hard reload, keyboard operable.
- Contrast table written into ADR 0015.

## IF VALIDATION FAILS
- No-flash script races hydration → ensure it's inline in head, reads the SAME key as provider.
- View Transitions unsupported in test env → feature-detect, fallback path must work headless.

## CHECKPOINT
Commit: `feat(rebuild): 03 design system — semantic tokens + day/night themes`

## STOP CONDITION
Phase 1 gate: 01+02+03 all COMPLETE → write gate report in STATUS, verify every gate
criterion, rebase onto main → auto-continue (D011: gates are checkpoints, not approvals).

## NEXT
`04_HOMEPAGE.md`
