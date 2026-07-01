# 08 — Complete Design Token System

Supersedes the design-system sketch in `02-patterns-system-ia.md §4`. Tokens are **additive**: existing
values are preserved verbatim; new tokens formalise de-facto values already used in the codebase so new
components stay consistent. Nothing here changes current rendering until a component opts in.

Source of truth today: `app/globals.css` `:root` + `tailwind.config.ts`.
Status key: ✅ exists · ➕ proposed addition · 🔁 formalises an existing de-facto value.

---

## 1. Color — primitives (✅ exists, keep)
```css
--void:#15161E; --deep:#1E2029; --smoke:#2A2D38;
--bone:#ECE7DB; --bone-2:#E2DCCB;
--ember:#D08A3E; --ember-deep:#A85E2A; --ember-pale:#E8C490; --clay:#9C4A2A;
--mist:#8E93A6; --ink:#20242F; --ink-mute:#5C5F52;
--line-dark:rgba(208,138,62,.16); --line-light:rgba(32,36,47,.14);
```

## 2. Color — semantic tokens (➕ add; map to primitives)
Adds an intent layer so components reference *role*, not hex. Enables future theme swaps without edits.
```css
/* surfaces */
--bg:               var(--void);
--bg-raised:        var(--deep);
--bg-inset:         var(--smoke);
--bg-light:         var(--bone);      /* light sections (About/Membership) */
--bg-light-2:       var(--bone-2);
/* text */
--fg:               var(--bone);      /* on dark */
--fg-muted:         var(--mist);
--fg-on-light:      var(--ink);
--fg-on-light-muted:var(--ink-mute);
/* accent */
--accent:           var(--ember);
--accent-strong:    var(--ember-deep);
--accent-soft:      var(--ember-pale);
--danger:           var(--clay);
/* lines/focus */
--border-on-dark:   var(--line-dark);
--border-on-light:  var(--line-light);
--focus-ring:       var(--ember);
```
**Contrast (WCAG):** `bone (#ECE7DB)` on `void (#15161E)` ≈ 13.7:1 (AAA). `mist (#8E93A6)` on `void`
≈ 5.6:1 (AA for text). `ember (#D08A3E)` on `void` ≈ 6.7:1 (AA). `ink` on `bone` ≈ 12:1 (AAA).
→ **Rule:** never use `ember` for body text on `bone` (fails); use `ember-deep` (`#A85E2A` ≈ 4.7:1) for small text on light. (Already the codebase convention.)

## 3. Typography scale (🔁 formalise; fonts ✅ exist)
Fonts: Cormorant (display), Hanken Grotesk (body), JetBrains Mono (mono) — `next/font`, `swap`.
Modular scale ~1.25 (major third), clamp-based fluid:
```css
--text-xs:  clamp(11px, 0.7rem + 0.1vw, 12px);   /* mono labels/eyebrow */
--text-sm:  clamp(13px, 0.8rem + 0.1vw, 14px);
--text-base:clamp(15px, 0.95rem + 0.2vw, 17px);  /* body */
--text-lg:  clamp(18px, 1.05rem + 0.3vw, 21px);
--text-xl:  clamp(22px, 1.2rem + 0.8vw, 28px);
--text-2xl: clamp(28px, 1.4rem + 1.6vw, 42px);
--text-3xl: clamp(38px, 2rem + 3vw, 78px);        /* section H2 (existing range) */
--text-hero:clamp(72px, 8vw + 1rem, 210px);       /* hero display (existing) */
--leading-tight:1.05; --leading-snug:1.25; --leading-body:1.85;
--tracking-label:0.28em; --tracking-wide:0.18em;
```
Roles (existing): `.eyebrow` = mono 11px / 0.28em / uppercase. Display = Cormorant light + italic accents.

## 4. Spacing — 8-point system (🔁 formalise; Tailwind already 4px-based)
```css
--space-0:0; --space-1:4px; --space-2:8px; --space-3:12px; --space-4:16px;
--space-5:24px; --space-6:32px; --space-7:48px; --space-8:64px;
--space-9:96px; --space-10:128px; --space-11:160px;
/* section rhythm (existing): mobile py-28 (112px) · desktop py-40 (160px) */
--section-y:    clamp(112px, 12vw, 160px);
--gutter:       clamp(24px, 5vw, 40px);   /* px-6 → px-10 today */
--container-max:1152px;                    /* max-w-6xl (existing) */
```

## 5. Radius (➕; current UI mostly sharp — keep sharp as default)
```css
--r-none:0;        /* default for editorial blocks */
--r-sm:2px; --r-md:4px; --r-lg:8px; --r-xl:14px; --r-pill:999px;
/* usage: chips/QR card --r-md..lg; pills for tags; sharp for sections */
```

## 6. Border / line (🔁)
```css
--border-w:1px; --border-w-2:2px;
--border-dark:1px solid var(--line-dark);
--border-light:1px solid var(--line-light);
```

## 7. Elevation / shadow (➕ — light surfaces only; dark stays shadowless)
```css
--e0:none;
--e1:0 1px 2px rgba(32,36,47,.06), 0 1px 1px rgba(32,36,47,.04);   /* card on bone */
--e2:0 6px 20px rgba(32,36,47,.10);                                 /* raised */
--e3:0 18px 50px rgba(21,22,30,.30);                                /* overlay/lightbox */
```

## 8. Blur / glass (🔁 — one recipe, used by Nav & CommandPalette)
```css
--blur-sm:6px; --blur-md:12px; --blur-lg:18px;
/* glass recipe (existing): */
--glass-dark: { background: rgba(21,22,30,.85); backdrop-filter: blur(var(--blur-md)); }
--glass-panel:{ background: rgba(30,32,41,.95); backdrop-filter: blur(var(--blur-lg)); }
```
Rule: don't proliferate blur — overlays only (nav, palette, lightbox, mobile menu).

## 9. Opacity (🔁)
```css
--o-faint:0.04;   /* watermarks, grain, hero photo wash (hero bg = .28) */
--o-muted:0.6;    /* disabled */
--o-hover:0.85;
--hero-photo:0.28;
```

## 10. Z-index system (🔁 — documents existing scale + new slots)
```css
--z-base:0; --z-raised:10;
--z-promobar:200;     /* ➕ new */
--z-nav:300;          /* ✅ */
--z-stickycta:310;    /* ➕ new */
--z-fab:320;          /* ✅ WhatsApp */
--z-scrollbar:350;    /* ✅ */
--z-mobilemenu:400;   /* ✅ */
--z-palette:450;      /* ✅ command palette */
--z-lightbox:460;     /* ➕ new, above palette when open */
```

## 11. Motion tokens (🔁 — see `10-motion-spec.md` for full spec)
```css
--ease-out:cubic-bezier(0.22,1,0.36,1);    /* primary (Reveal/Nav use this) */
--ease-inout:cubic-bezier(0.65,0,0.35,1);
--spring-soft:{stiffness:260,damping:20};   /* framer (WhatsApp FAB uses this) */
--dur-fast:200ms; --dur-base:600ms; --dur-slow:900ms;
/* breath cadence (hero): inhale 4s · hold 4s · exhale 6s */
```

## 12. Breakpoints (🔁 — Tailwind defaults, document usage)
```
sm 640  md 768  lg 1024  xl 1280  2xl 1536
mobile-first; primary desktop switch at md (768). Touch targets ≥44px below md.
```

## 13. Theme variables & modes
- **Current site is dark-by-design** (void base) with **light editorial sections** (bone). This is an
  intentional *dual-surface* system, not a user-toggled dark/light mode.
- **Recommendation:** keep dual-surface; **do not** add a user dark/light toggle (it would fight the
  art direction and double the QA surface for no user demand). If a future product/app needs it, the
  semantic layer (§2) already makes it a token remap, not a refactor.
- **High-contrast / forced-colors:** add a `@media (forced-colors: active)` pass so borders/focus use
  `CanvasText`/`Highlight` (see `09-accessibility-audit.md`).

## 14. Atomic structure & component naming
- **Atoms:** Button, Tag/Chip, Input, Label, Icon, Eyebrow, Stat.
- **Molecules:** Field (label+input+status), PlanCard, GalleryTile, NavLink, PromoBar, StatItem.
- **Organisms:** Nav, Footer, Hero, Membership, Gallery, Newsletter, StartHere, Contact, CommandPalette.
- **Naming:** PascalCase components; section organisms map 1:1 to page anchors; props typed in the
  component file; **all visible copy in `lib/content.ts`** (CMS-or-fallback).

## 15. Implementation note
These can live as: (a) CSS custom properties in `app/globals.css` (`:root`) for runtime tokens, plus
(b) `tailwind.config.ts` `theme.extend` references so utilities map to the same values. Add incrementally
**alongside** existing tokens — do not rename or remove current ones. Figma Variables (free) can mirror
this exact set for design parity (collections: color/primitive, color/semantic, space, type, radius,
elevation, motion, z-index).
