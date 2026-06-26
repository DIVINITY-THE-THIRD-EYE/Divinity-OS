# 04 — Mobile (Android/iOS) Roadmap & Interaction/Motion Spec

> **Scope boundary.** Native Student/Trainer/Admin apps with auth, attendance/QR, wearables, chat
> and payments are a **separate product** with their own backend — exactly as the current README
> already states. This document is a **forward roadmap**, not part of the approved incremental
> website upgrade. The one mobile improvement achievable **now, free, on the existing site** is a
> **PWA layer** (§6.0). Everything else is staged for when the product is greenlit.

---

## 6. Android UX upgrade plan  &  7. iOS UX upgrade plan

### 6.0 PWA layer — achievable now (free, additive to the current Next.js site)
Turns the existing site into an installable, offline-capable app with **no native project**:
- **Manifest** (`app/manifest.ts`) — name, theme `#15161E`, ember accent, the lotus icons we already generated (`icon.png`, `apple-icon.png`), `display:standalone`.
- **Service worker** — offline shell + cache the static pages and studio imagery (use `@serwist/next`, free/MIT; or `next-pwa`). Respect data-saver.
- **Install prompt** — subtle "Add to home screen" affordance (dismissible).
- **iOS notes:** add `apple-mobile-web-app-*` meta + the apple-icon (present). Standalone status bar styling.
- **Why now:** ~0.5–1 dev-day, zero app-store cost, gives "app on the home screen" for both platforms.
- **Out of PWA scope:** push on iOS needs iOS 16.4+ PWA push; fine to defer.

### Native app (future product) — platform-tailored UX
Shared IA (both platforms): **Today → Book → Practice (on-demand) → Progress → Profile** bottom nav.

| Surface | Android (Material You / M3) | iOS (HIG) |
|---|---|---|
| Auth | Credential Manager, Passkeys, Google one-tap | Sign in with Apple, Passkeys, Face ID |
| Navigation | Bottom nav bar + nav rail on tablet/landscape | Tab bar + sidebar on iPad |
| Theming | **Material You** dynamic color seeded from ember; full dark mode | Semantic colors; Dynamic Type; dark mode |
| Home | Resizable **widgets** (next class, streak) | **Home-screen + Lock-screen widgets**; **Live Activity / Dynamic Island** for an in-progress class/breath timer |
| Attendance | **QR check-in** (ML Kit) | QR via VisionKit; Wallet pass for membership |
| Health | **Health Connect** sync (mindful minutes, workouts) | **Apple Health / HealthKit** (mindful minutes, heart rate) |
| Wearables | Wear OS tile for breath timer | Apple Watch app: breath haptics, session control |
| Notifications | Channels per type; reminders | Notification categories; time-sensitive for class start |
| Calendar | Google Calendar 2-way | EventKit / Apple Calendar |
| Payments | Google Pay / UPI intent (India) | Apple Pay; StoreKit only if selling digital |
| Offline | Downloaded sessions; offline queue | Same; background refresh |
| Accessibility | TalkBack, large text, contrast, reduce-motion | VoiceOver, Dynamic Type, Reduce Motion, AssistiveTouch |
| Adaptive | Compact/medium/expanded window classes; landscape & foldables | Size classes; iPad multitasking; landscape |

**Recommended stack if/when built (free):** Flutter (single codebase, Material + Cupertino) **or**
Capacitor wrapping the existing React UI (maximum reuse). Backend: Supabase free tier (auth, Postgres,
RLS, storage) — matches the README's "own auth + database" note. Emergency-contact, reports, downloads,
achievements, community/chat become standard product modules on that backend.

### App screen set (future — for reference)
Auth · Onboarding · Today/Dashboard · Schedule/Book · Class detail · QR check-in · On-demand library ·
Player (audio/video) · Breathwork timer · Meditation · Progress/streaks · Health sync · Membership/Wallet ·
Payments · Profile · Settings · Notifications · Community/Chat · Events · Achievements · Offline/Downloads.
Each needs: empty / loading / error / offline / success / permission states (see `10-motion-spec.md §8`).

### 6.1 Platform capabilities deep-dive

| Capability | Android | iOS | Notes |
|---|---|---|---|
| **Design language** | **Material 3** (dynamic color seeded from ember; tonal surfaces; M3 components) | **HIG** (semantic colors, SF symbols, Dynamic Type, large titles) | One product, two idiomatic skins — Flutter Material/Cupertino or platform-native. |
| **Foldables** | Hinge-aware layouts (Jetpack WindowManager): list/detail across the fold, tabletop mode for the breath timer | iPad/Stage Manager multitasking | Use window size classes, not device checks. |
| **Tablets / landscape** | Nav rail + two-pane (list↔detail); expanded window class | Sidebar + split view | Reflow, never letterbox. |
| **Dynamic Island / Live Activities** | (n/a) — use **ongoing notification** + **Wear tile** for an in-progress session | **Live Activity** for class countdown / breath timer; **Dynamic Island** compact + expanded states | Great for "class starts in 10 min" and live breath pacing. |
| **Widgets** | Resizable home-screen widgets (next class, streak) via Glance | Home + **Lock-screen** widgets (WidgetKit); StandBy | Deep-link into the relevant screen. |
| **Offline-first** | Local store (Room/Drift) as source of truth; UI reads cache, syncs in background | Same (SwiftData/Core Data) | Downloaded classes playable offline; booking queued. |
| **Background sync** | WorkManager (periodic + constrained: wifi/charging) for schedule, downloads, health | BGTaskScheduler / Background App Refresh | Reconcile booking queue + content library; respect battery/data. |
| **Deep links** | App Links (`https://` verified) + custom scheme | **Universal Links** (AASA) + custom scheme | One link map → class/booking/profile; share + push open the right screen. |
| **App shortcuts** | Static + dynamic shortcuts (long-press launcher): "Book", "Breathe", "Today" | Home-screen **Quick Actions** + Siri Shortcuts/App Intents | Mirror the bottom-nav top tasks. |
| **Biometric auth** | BiometricPrompt + Credential Manager **Passkeys** | Face ID / Touch ID + **Passkeys**, Sign in with Apple | Biometric to unlock; passkeys as primary credential. |
| **Wearables** | Wear OS tile + complication for breath timer | Apple Watch app: breath haptics, session control, HR | Haptic breath pacing is a signature carry-over from the web hero. |
| **Payments** | Google Pay / UPI intent (India) | Apple Pay; StoreKit only for digital goods | UPI stays primary for India (zero fee). |
| **Notifications** | Channels per type; time-sensitive for class start | Categories; Time-Sensitive interruption level | Reminders, streak nudges, waitlist promotion. |

---

## 8. Interaction & motion specification

> **Moved & expanded** to a dedicated doc: see **[`10-motion-spec.md`](10-motion-spec.md)** for the full
> spec (durations, easing, stagger, springs, scroll speed, triggers, exit animations, shared-element
> transitions, mobile alternatives, reduced-motion behaviour). Summary retained below for context.

Applies to the **website now** (and is forward-compatible with the app). Built on the tokens in
`08-design-tokens.md §11`. Golden rule: **every interaction has a reduced-motion equivalent.**

### 8.1 Motion tokens
```
--ease-out:  cubic-bezier(0.22, 1, 0.36, 1)   /* primary, already used */
--ease-inout: cubic-bezier(0.65, 0, 0.35, 1)
--dur-fast: 200ms   --dur-base: 600ms   --dur-slow: 900ms
breath cadence: inhale 4s · hold 4s · exhale 6s  (hero — keep)
```

### 8.2 States (every interactive element)
| State | Web spec | Reduced-motion |
|---|---|---|
| Hover | ember tint / underline grow / 1.02–1.04 scale, `--dur-fast` | color only, no transform |
| Focus-visible | 2px ember outline, offset 3px (existing) | identical (no motion) |
| Pressed | scale 0.98, `--dur-fast` | none |
| Disabled | opacity .6, `cursor:not-allowed` | same |
| Loading | spinner/skeleton + `aria-busy` | static skeleton |
| Magnetic (CTAs) | existing `Magnetic` pull ≤ 8px | disabled |

### 8.3 Web gestures / scroll
- **Smooth scroll** via Lenis (existing); disabled under reduced-motion (existing).
- **Scroll-reveal** via `Reveal` (existing) — reuse for all new sections; `once:true`.
- **Horizontal scroll** (Disciplines, GSAP) — keep; ensure keyboard + trackpad parity.
- **Sticky CTA** entrance: fade+rise 12px, `--dur-base`; exit reverse.
- **Promo bar:** height/opacity in, `--dur-base`; collapse on dismiss.

### 8.4 App gestures (future)
Swipe (tab/back), pull-to-refresh, long-press (quick actions), pinch (player/images), shared-element
transition (card → detail), gesture back (iOS edge), physics-based list overscroll, haptics on
check-in success and breath phase change.

### 8.5 Signature / celebratory
- **Breath sync** (hero canvas) — the brand signature; preserve.
- **Streak / first-booking** (app or web confirmation): subtle ember particle burst (Lottie or canvas),
  ≤ 1.2s, **skipped under reduced-motion**; never blocks the success message.
- **No confetti spam** — one quiet celebration per meaningful milestone.

### 8.6 State diagrams (per interactive surface)
```
Button:    idle → hover → pressed → (loading → success | error) → idle
Form:      empty → focused → validating → (error→focused | success)
Newsletter: idle → submitting → subscribed | error(retry)
Lightbox:  closed → opening(focus-trap on) → open → closing(focus-return) → closed
PromoBar:  shown → dismissed(session)        (never re-show same session)
StickyCta: hidden → (scrollY>hero) shown → hidden
Async data: idle → loading(skeleton) → loaded | empty | error(retry) | offline(queued)
```

### 8.7 Empty / error / offline / permission (web + app)
- **Empty:** quiet line + one action ("No classes today — view the full schedule").
- **Error:** human copy + retry; never a raw stack; `role="alert"`.
- **Offline (PWA/app):** cached shell + "You're offline — showing saved content."
- **Permission (app):** pre-permission priming screen explaining *why* before the OS prompt (camera for QR, notifications, Health).
- **Success:** inline confirmation + clear next step (matches current Contact "Thank you" pattern).

---

## Summary
- **Now (free, in-scope-adjacent):** add a **PWA layer** (§6.0) — installable + offline, ~1 day, reuses existing icons.
- **Later (separate product):** native apps per the platform matrix, on a Supabase backend, when greenlit.
- **Interaction/motion spec** (§8) governs the website upgrade immediately and the app later — one language, reduced-motion-first.
