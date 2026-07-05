# 09 — UI/UX Report

*Scope note: the website was checked live (dev server, accessibility snapshot, mobile viewport resize). The Flutter app's UI/UX was assessed from code structure only — no emulator/simulator session was run this pass, so anything below about the Flutter app's actual on-screen behavior should be treated as inferred from code, not observed.*

## Website (verified live this session)

- **Structure:** skip-to-content link present and is the first focusable element (`app/layout.tsx:96-101`) — a real accessibility feature, not just a decorative pattern.
- **Responsiveness:** confirmed live — resizing the preview to a 375×812 mobile viewport correctly collapsed the desktop nav (About/Services/Schedule/Pricing/Trainers links) into a single "MENU" hamburger button. Content re-flowed correctly; no overlap or clipping observed in the accessibility tree.
- **Motion/accessibility:** the browser's `prefers-reduced-motion` setting was honored — the console logged an explicit notice ("You have Reduced Motion enabled... Animations may not appear as expected"), meaning the animation libraries (Framer Motion/GSAP/Lenis) are checking this media feature rather than ignoring it.
- **Console:** clean — only informational React DevTools and reduced-motion messages, no errors or warnings from the app itself.
- **Loading/empty states:** `lib/content.ts`'s `fetchOrFallback` pattern means every content section has a guaranteed non-empty fallback even if Sanity CMS is unreachable — pages don't have a "blank if CMS is down" failure mode. Explicit empty states exist for `/blog` and `/events` list pages when no posts/events are present (confirmed via architecture-mapping read).
- **i18n/theme controls:** language toggle (हिं/EN) and theme toggle (☀/☾) both present and wired in the nav on both desktop and mobile, per the architecture map.
- **Forms:** contact form has real client-adjacent validation feedback via the API's structured error responses (422 for invalid email/selection, 413 for oversized payloads, 429 for rate-limited) — not independently confirmed that the *frontend* surfaces each of these distinctly to the user (only that the API contract supports it).

## Flutter app (code-level inference, not observed live)

- **Error surfacing:** consistent pattern of domain exception → snackbar with a human-readable message (verified via `check_in_screen.dart:189-195` and the auth/payment/leave providers) — this is a genuinely good pattern for a mobile app, since it means errors aren't silently swallowed or shown as raw exception text in the areas reviewed.
- **Loading states:** the `AsyncNotifier` pattern used everywhere gives `AsyncValue.loading()`/`.error()`/`.data()` states for free — this strongly suggests consistent loading/error/data UI handling across features, since the state machine itself forces a decision at each screen, but this wasn't visually confirmed against every screen.
- **Theme:** single shared token source (`app_theme.dart`) with explicit light/dark variants — consistent theming is a code-level guarantee here, not just a convention, since there's no per-feature color duplication to drift from it.
- **Localization:** the language switcher lives in the profile screen (a reasonable, discoverable location) as a `SegmentedButton` with clear EN/HI labels.

## Not assessed this session

- Actual on-device Flutter UI (no emulator/simulator run) — loading skeletons, animation smoothness, gesture responsiveness, and real accessibility properties (screen-reader labels, contrast ratios) were not visually verified.
- Full accessibility audit (WCAG contrast ratios, focus order beyond the skip-link, ARIA labeling depth) on either surface — only structural signals (skip-link presence, semantic headings/articles, reduced-motion handling) were checked.
- Cross-browser testing (only the default preview browser engine was used for the website check).

**Recommendation:** if UI/UX is a stated priority for the next work cycle, budget a dedicated pass with an actual Android/iOS simulator session for the Flutter app (screenshots per role-shell, per light/dark mode) and a proper axe-core/Lighthouse accessibility run for the website — this report only rules out the most obvious failure modes (broken responsive layout, missing empty states, ignored reduced-motion), not deep accessibility or polish issues.
