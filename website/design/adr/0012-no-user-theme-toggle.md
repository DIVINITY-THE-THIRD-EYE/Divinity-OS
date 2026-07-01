# ADR 0012 — No user dark/light toggle (dual-surface art direction)
Status: Accepted · Date: 2026-06-26

## Context
The design is a deliberate **dual-surface** system: dark `void` chrome with light `bone` editorial
sections. Colours are tokenised (`globals.css`, `08-design-tokens`).

## Problem
The brief mentions dark/light mode. Should the site expose a user theme toggle?

## Alternatives considered
1. **User dark/light toggle** — doubles QA surface, fights the curated art direction, and there's no
   evidenced user demand for a short marketing page.
2. **Auto by `prefers-color-scheme`** — would override the intentional section rhythm.
3. **Keep the fixed dual-surface system** — chosen.

## Decision
No user-facing theme toggle. Maintain the dual-surface art direction. The **semantic token layer**
(`08 §2`) keeps a future re-theme (e.g. a product app) a token remap, not a refactor.

## Consequences
- Consistent, intentional visuals; less QA/maintenance; brand integrity preserved.

## Risks
- A future product surface may need true theming. → Semantic tokens already enable it without touching components.

## Rollback strategy
If product needs theming later, introduce a theme provider that swaps the semantic token values; the
primitive palette and components remain unchanged. Reversible and isolated.
