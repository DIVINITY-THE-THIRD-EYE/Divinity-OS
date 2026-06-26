# Accessibility Baseline (Phase 0)

Captured 2026-06-26. Heuristic review against WCAG 2.2 AA from source. **Automated axe + manual
keyboard/SR pass are TO RUN** before Phase 1 (commands below) — results recorded here become the floor
that future work must never breach.

## Automated audit — TO RUN
```bash
npm run build && npm run start
npx @axe-core/cli http://localhost:3000 --save ./design/phase0/reports/axe-home.json
# or in-suite: @axe-core/playwright (see quality-gates.md)
```
Record: violations (id, impact, nodes), incomplete/warnings, and the pass count.

## Heuristic findings (from code review — confirm with axe)

### Strengths already in place (the floor to preserve)
- `:focus-visible` ember outline (2px, offset 3px), global.
- `prefers-reduced-motion` honoured globally + per-component (BreathHero, Manifesto, Ambient).
- Semantic `<main>/<nav>/<footer>/<section>`; one `<h1>` (hero).
- Custom cursor gated to fine-pointer (never hides cursor on touch).
- Meaningful `alt` on gallery; decorative `alt=""`; real `<label>`s in Contact; keyboard-operable ⌘K palette.

### Baseline issues to record as the starting violation set (fixed during Phase 1/2, never increased)
| ID | WCAG | Severity | Where |
|---|---|---|---|
| A2 | 4.1.3 Status Messages | serious | Contact success/error not announced (no live region) |
| A1 | 2.4.1 Bypass Blocks | moderate | No skip link |
| A3 | 3.3.1/3.3.3 | moderate | No per-field error association in Contact |
| A5 | 2.5.8 Target Size | moderate | `Voices` nav dots / future controls < 24px |
| A11 | 4.1.2 | moderate | Some icon-only controls need `aria-label` audit |
| A8 | 1.3.1 | minor | Heading order to maintain as sections are added |
(Full audit + fixes: `design/09-accessibility-audit.md`.)

## Manual review checklist — TO RUN
- [ ] Keyboard pass: tab order matches visual; no traps; ESC closes palette/menu; visible focus everywhere.
- [ ] Screen reader (VoiceOver + NVDA) smoke: hero, nav, Contact, gallery.
- [ ] 200% zoom + text-spacing override: no clipping.
- [ ] `prefers-contrast: more` / forced-colors render check.
- [ ] Contrast spot-check against tokens (`design/08 §2`): bone/void AAA, mist/void AA, ember-deep on bone AA.

## Non-regression rule
The recorded violation count is the **maximum**. Any PR that increases axe violations or fails the
manual keyboard pass is blocked (`quality-gates.md`). Target end-state: **0 critical/serious**.
