# 09 — Accessibility Audit (WCAG 2.2 AA)

Scope: the existing Divinity site + every new component in the upgrade. Method: heuristic review against
WCAG 2.2 AA + manual keyboard reasoning over the current code. **Action:** confirm with free tools —
axe DevTools, Lighthouse a11y, WAVE, and a manual keyboard + VoiceOver/NVDA pass — and gate each phase
on **zero axe criticals**.

Severity: 🔴 must-fix before ship · 🟡 should-fix in-phase · 🟢 enhancement.

---

## 1. Current posture (already good — preserve)
- ✅ `:focus-visible` ember outline (2px, offset 3px) globally — `globals.css`.
- ✅ `prefers-reduced-motion` honoured globally (animations/scroll) and per-component (BreathHero, Manifesto, Ambient).
- ✅ Semantic landmarks: `<main>`, `<nav>`, `<footer>`, `<section>` with ids.
- ✅ Custom cursor gated to `(hover:hover) and (pointer:fine)` — never hides cursor on touch.
- ✅ Meaningful `alt` on gallery; decorative images use `alt=""`.
- ✅ Real `<label>`s in Contact; keyboard-operable command palette (arrows/enter/esc).

## 2. Findings & required fixes

| # | Guideline | Sev | Issue | Fix (ships with) |
|---|---|---|---|---|
| A1 | 2.4.1 Bypass Blocks | 🟡 | No skip link. | Add visually-hidden "Skip to content" → `#top`, first focusable in `layout.tsx`. (Phase 1) |
| A2 | 4.1.3 Status Messages | 🔴 | Contact success/error not announced; Newsletter (new) same risk. | `role="status"`/`aria-live="polite"` for success, `role="alert"` for error. (R3/R9, Phase 1) |
| A3 | 3.3.1 / 3.3.3 Error ID | 🟡 | No per-field error association. | `aria-invalid`, `aria-describedby` → error id; inline messages. (R9) |
| A4 | 1.4.1 Use of Color | 🟡 | Intensity tags (new) risk colour-only meaning. | Always pair dot with text ("Vigorous"). (R5) |
| A5 | 2.5.8 Target Size (2.2 AA) | 🟡 | Promo dismiss, sticky CTA, nav dots, gallery dots must be ≥24×24 (aim ≥44). | Min hit-area on all new controls + existing `Voices` dots. (Phase 1–2) |
| A6 | 2.4.3 Focus Order / 2.1.2 No Trap | 🔴 | Lightbox (new) and mobile menu must trap+restore focus correctly. | Focus-trap, ESC, return focus to trigger; `role="dialog"` `aria-modal`. (R6) |
| A7 | 2.4.7 Focus Visible | 🟡 | New interactive els must not suppress the ring (custom-cursor `cursor:none` context). | Verify `:focus-visible` present on every new control. |
| A8 | 1.3.1 Info & Relationships | 🟡 | Heading order as sections are added. | One `<h1>` (hero); one `<h2>` per new section; `<blockquote>/<cite>` for Quote. |
| A9 | 2.2.2 Pause/Stop/Hide | 🟡 | Marquee + promo marquee auto-move. | Already paused under reduced-motion; ensure promo text is static or pausable; not the only copy of the info. |
| A10 | 1.4.12 Text Spacing / 1.4.4 Resize | 🟢 | Verify 200% zoom + text-spacing overrides don't clip. | Use rem/clamp (tokens); test at 200%. |
| A11 | 4.1.2 Name/Role/Value | 🟡 | Icon-only controls (sound toggle, WhatsApp, dismiss) need names. | `aria-label` on all icon buttons (WhatsApp FAB ✅; audit new ones). |
| A12 | 1.4.13 Content on Hover | 🟢 | Gallery hover caption must be dismissable/persistent & not the only access to info. | Caption also available via the `alt`/lightbox; works on focus, not just hover. |
| A13 | 2.5.7 Dragging (2.2) | 🟢 | Disciplines horizontal scroll must have a non-drag path. | Provide keyboard/trackpad + visible affordance (no drag-only). |

## 3. Keyboard navigation map (target)
```
Tab order: SkipLink → Nav(logo→links→⌘K→Begin) → [PromoBar dismiss] → main content in DOM order
           → StickyCta (mobile) → Footer.
⌘K / Ctrl+K: open palette (✅). Esc: close palette/menu/lightbox. Arrows: palette + gallery nav.
Every control reachable, visible focus, logical order matching visual order.
```

## 4. Screen-reader checklist (VoiceOver / NVDA)
- Landmarks announced (banner/nav/main/contentinfo) — add `role`/labels where multiple `nav`s exist.
- Form: label + state + error all read; success announced via live region.
- Images: descriptive `alt` (done in gallery); decorative `alt=""`.
- Buttons vs links: actions = `<button>`, navigation = `<a>` (audit new comps).
- Lightbox: `role="dialog"`, `aria-label`, focus moves in/out correctly.

## 5. Reduced motion & vestibular safety
- Global media query ✅. Extend explicitly to **every new** animated component: PromoBar entrance,
  Stats count-up (render final value statically), StickyCta, gallery hover/lightbox transitions,
  celebration burst (skip entirely), SoundToggle.
- Parallax/large transforms: none added that can't be disabled.

## 6. High-contrast / forced colors
- Add `@media (forced-colors: active)`: borders → `CanvasText`, focus → `Highlight`, ensure ember-on-
  custom backgrounds don't vanish; never rely on background images for essential meaning.
- Test Windows High Contrast + `prefers-contrast: more`.

## 7. Touch targets & mobile
- All interactive ≥44×44 effective area below `md`; spacing between adjacent targets ≥8px.
- Sticky CTA must not overlap the WhatsApp FAB (z-index + offset, see `08-design-tokens §10`).

## 8. RTL readiness (not required now; make future-proof)
- Use **logical properties** (`margin-inline`, `padding-inline`, `inset-inline`, `text-align:start`)
  in **new** components instead of left/right, so an Arabic/Hebrew/Urdu locale is a config flip, not a refactor.
- Avoid hard-coded left/right in new CSS; mirror-safe icons.
- *Note:* the site is currently en/Sanskrit; RTL is a readiness goal, not a Phase 1 task.

## 9. Internationalisation readiness
- All visible strings already centralised in `lib/content.ts` → a clean seam for future locale files.
- Keep copy out of components; avoid concatenated sentences (breaks translation/plurals).
- `lang` set on `<html>` (✅ `en`); set per-locale when i18n lands. Format dates/numbers with `Intl`.
- Fonts: Cormorant/Hanken cover Latin; Devanagari accents already render — verify a webfont fallback if expanded.

## 10. Acceptance criteria (per phase)
1. axe DevTools: **0 critical / 0 serious** on changed pages.
2. Lighthouse Accessibility **≥ 95**.
3. Manual: full keyboard pass (no traps, visible focus, logical order) + one screen-reader smoke test.
4. Contrast: all text ≥ AA (4.5:1 body / 3:1 large) — verified against tokens in `08 §2`.
5. Reduced-motion: every animation has a static/none equivalent.
