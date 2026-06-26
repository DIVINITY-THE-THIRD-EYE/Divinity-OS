# Design Token Freeze (Phase 0)

The current token set is exported and versioned as **`tokens.json` v1.0.0** (machine-readable, this
folder). It captures what's live today (`app/globals.css :root`, `tailwind.config.ts`) plus the
formalised scales from `design/08-design-tokens.md`. **Future token changes require a changelog entry +
semver bump.**

## Versioning policy (semver for tokens)
- **MAJOR** — remove/rename a token, or change a primitive value that alters existing UI (needs an ADR).
- **MINOR** — add a new token (additive; safe). e.g. adding `--z-promobar`.
- **PATCH** — docs/aliases/non-visual corrections.

## What's frozen at v1.0.0
- **Primitives** (12 colors + 2 lines) — exact current values; **MAJOR** to change.
- **Semantic layer, type scale, 8pt space, radius, border, elevation, blur, opacity, z-index, motion,
  breakpoints** — formalised; additions are MINOR.
- Contrast notes encoded so no one introduces ember body-text on bone (fails AA).

## Changelog
```
## tokens v1.0.0 — 2026-06-26
- Initial freeze. Primitives mirror app/globals.css; scales formalised from design/08.
- No runtime change to the app (export/doc only).
```
(Append future entries here; mirror in Figma Variables if used — collections per `08 §15`.)

## Rules
1. Components reference **semantic** tokens, not raw hex, going forward (existing usages migrate opportunistically — not a freeze-breaking rewrite).
2. Adding a token = MINOR bump + changelog line; it must not change any existing rendered pixel.
3. Changing a primitive = MAJOR + ADR + visual-regression review (`design/20`).
4. `tokens.json` is the source for any future codegen (CSS vars / Tailwind / Figma) to keep parity.
