# ADR 0015 — Day/night theme (semantic token layer)

Status: Accepted · Date: 2026-07-09 · Supersedes: 0012

## Context

D006 (approved) reopens ADR 0012 ("no user dark/light toggle"): the product now wants a
persisted day/night theme, and — as of this task — the site already ships most of it.
`lib/theme/ThemeContext.tsx` was already wired into `app/layout.tsx` and `components/Nav.tsx`
with `localStorage` persistence and a working toggle before this task started. What was
missing: a no-flash init script, a reusable accessible toggle component, a documented
semantic token layer, and a contrast audit.

## Decision

1. **Reuse, don't duplicate, the existing theme system.** `03_DESIGN_SYSTEM.md`'s FILES
   ALLOWED named new files `components/ThemeProvider.tsx` / `components/ThemeToggle.tsx` —
   written without knowledge that `lib/theme/ThemeContext.tsx` already existed and was live.
   Creating a second provider would produce two competing theme systems on one page. Instead:
   kept `lib/theme/ThemeContext.tsx` as the provider, added `components/ThemeToggle.tsx` as
   the new reusable, accessible toggle (extracted from Nav's two duplicated inline buttons),
   and fixed the provider's initial-state flash (see below).
2. **No-flash script**: `next/script` with `strategy="beforeInteractive"` in `app/layout.tsx`,
   reading the same `divinity_theme` localStorage key `ThemeContext` uses, falling back to
   `matchMedia('(prefers-color-scheme: light)')` when nothing is stored (the system-preference
   fallback the original `ThemeContext` never implemented), then setting `data-theme` on
   `<html>` before first paint — CSS reads it immediately, fixing the color flash.
   `ThemeContext`'s React state still starts `"dark"` on both server and the client's first
   render (matching, so no hydration mismatch), and a `useEffect` reads the attribute back
   *after* mount to correct `theme` (icon, `aria-pressed`) — a normal post-mount state update.
   **First attempt reading the attribute inside the `useState` initializer was wrong** and
   was caught in preview: it made the client's first render depend on browser-only state
   (the visitor's system color-scheme), which can differ from the server's fixed "dark"
   render — React detected the mismatch (the toggle icon's text differed) and discarded the
   server HTML entirely, a full remount that is a worse flash than the one being fixed.
   `suppressHydrationWarning` on `<html>` only covers attribute diffs on that element itself,
   not content differences in descendant components like the toggle icon.
3. **Semantic token layer added to `globals.css`, parallel to the existing primitives**
   (`--void`/`--bone`/`--ember`/etc.) — those stay untouched and keep driving unmigrated
   components; the semantic layer is for components rebuilt in later tasks (04+).
4. **`--ink` / `--ink-muted` from the original task spec were renamed `--fg` / `--fg-muted`.**
   `--ink` (and `--ink-mute`) already exist in `globals.css` with a *different* value and are
   live on `About.tsx`, `Faq.tsx`, `Membership.tsx`, `Method.tsx`, `SectionHeading.tsx`,
   `PreviewSection.tsx` (dark text on the site's light "bone" editorial sections — the
   dual-surface art direction from ADR 0012). Redefining `--ink` with the semantic value
   (`#ece7db`/`#20242f` — opposite luminance) would have silently made that text illegible on
   every one of those unmigrated components. `03_DESIGN_SYSTEM.md`'s TOKEN SPEC table has been
   updated in place to `--fg`/`--fg-muted`; no other task file referenced `--ink` by name
   (checked 04–19), so this has no further blast radius. See DECISIONS.md E-003.
5. **Day-mode `--accent` darkened from `#a85e2a` to `#9c4a2a`** (reusing the already-defined
   `--clay` primitive, same rust hue family) — the spec value only reached 4.26:1 against
   day `--surface`, below the 4.5:1 floor. `#9c4a2a` reaches 5.35:1. Per this task's own step 7
   instruction ("darken/lighten, stay in hue family, re-check, update the spec table").

## Token table (as shipped — see globals.css)

| Token | Night (`:root`) | Day (`[data-theme="light"]`) |
|---|---|---|
| `--surface` | `#15161e` | `#f4efe4` |
| `--surface-2` | `#1e2029` | `#e9e2d2` |
| `--surface-3` | `#2a2d38` | `#ddd4bf` |
| `--fg` | `#ece7db` | `#20242f` |
| `--fg-muted` | `#8e93a6` | `#5c6070` |
| `--accent` | `#d08a3e` | `#9c4a2a` (adjusted, see above) |
| `--accent-2` | `#2e5f4f` | `#5f7a5a` |
| `--line` | `rgba(208,138,62,0.16)` | `rgba(32,36,47,0.14)` |
| `--glow` | dark-blue/emerald radial pair | gold/beige radial pair |

`data-theme` values stay `"light"` / absent(dark) — the existing shipped convention (already
wired through `ThemeContext`, `Nav`, and `globals.css`) — rather than introducing a parallel
`"day"`/`"night"` attribute value for the same states. "Day/night" is the product-facing
concept name (D006); the code-level values are unchanged to avoid a repo-wide rename with no
functional benefit.

## Contrast audit (WCAG 2.2 AA — normal text ≥4.5:1, computed via relative-luminance formula)

| Pair | Night ratio | Day ratio |
|---|---|---|
| `--fg` / `--surface` | 14.61:1 | 13.52:1 |
| `--fg-muted` / `--surface` | 5.90:1 | 5.45:1 |
| `--accent` / `--surface` | 6.34:1 | 5.35:1 (post-adjustment; pre-adjustment was 4.26:1, failing) |
| `--fg` / `--surface-2` | 13.16:1 | 12.01:1 |

All eight required pairs pass ≥4.5:1 in both themes.

## Consequences

- Existing components are unaffected (primitives untouched); new/rebuilt components from
  04 onward consume the semantic layer.
- One extra client script (`beforeInteractive`, ~250 bytes) runs before hydration on every page.
- `ThemeToggle.tsx` is now the single toggle implementation; `Nav.tsx`'s two previous inline
  duplicates were replaced with it (desktop nav bar + mobile menu).

## Rollback strategy

Revert the `globals.css` semantic block, `tailwind.config.ts` additions, `ThemeToggle.tsx`,
the `ThemeContext.tsx` initial-state change, and the `layout.tsx` script — the pre-existing
toggle (with its original mount-time flash) keeps working exactly as it did before this ADR.
