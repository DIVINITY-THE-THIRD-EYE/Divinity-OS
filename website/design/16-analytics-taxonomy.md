# 16 — Analytics & Event Taxonomy

Complete spec extending `12 §6`. Tooling: **GA4 + GTM** (free), optional **PostHog** (free) for funnels.
Implemented via a thin `lib/track.ts` wrapper. **No PII** in event properties (no name/email/phone);
respect consent (see `21` security).

## Conventions
- Event names: `snake_case`, `object_action` (e.g. `cta_book`, `newsletter_submit`).
- Properties: `snake_case`; enums fixed; no free text that could contain PII.
- Global user attributes (non-PII): `device` (mobile/tablet/desktop), `returning` (bool), `reduced_motion`
  (bool), `referrer_type` (organic/social/direct/referral), `locale`.
- Funnel stages: `awareness → interest → consideration → intent → conversion`.

## Event catalog

| Event | Trigger | Properties | Funnel stage | KPI |
|---|---|---|---|---|
| `page_view` | route/anchor load | `path`, `referrer_type` | awareness | sessions |
| `section_view` | major section in viewport (sampled) | `section_id` | interest | scroll depth |
| `scroll_depth` | 25/50/75/100% | `percent` | interest | engagement |
| `promo_view` | PromoBar shown | `offer_id` | interest | offer reach |
| `promo_dismiss` | PromoBar dismissed | `offer_id` | interest | dismiss rate |
| `cta_book` | any "Book"/"Begin" CTA | `location` (hero/promo/sticky/nav/membership) | intent | CTA CTR |
| `whatsapp_click` | WhatsApp FAB/sticky/footer | `location` | intent | WA CTR |
| `plan_calculator_start` | PlanCalculator opened | — | consideration | tool usage |
| `plan_calculator_complete` | recommendation shown | `recommended_plan` | consideration | completion rate |
| `plan_select` | plan CTA click | `plan_name` | intent | plan interest |
| `command_palette_open` | ⌘K | — | interest | power-use |
| `gallery_open` | lightbox open | `index` | interest | media engagement |
| `start_here_select` | StartHere intention chosen | `intention` (body/breath/healing) | consideration | onboarding use |
| `contact_start` | contact field focused | — | intent | form start |
| `contact_submit` | enquiry submitted | `intention`, `status` (ok/error), `delivered` | conversion | enquiry rate |
| `newsletter_submit` | subscribe attempt | `status` (ok/error), `source` (section/footer) | conversion | signup rate |
| `sound_toggle` | ambient sound on/off | `state` | interest | feature use |
| `outbound_click` | Instagram/external | `destination` | interest | social CTR |

## Future product events (app, for taxonomy continuity)
`signup_complete`, `login`, `class_booked`, `attendance_marked` (QR), `payment_completed`
(`amount`, `plan`, `method`), `meditation_started`/`completed`, `breathing_session_completed`,
`course_enrolled`/`completed`, `streak_milestone`. Same naming/no-PII rules.

## Funnels (configure in GA4/PostHog)
1. **Booking:** `page_view → cta_book → contact_submit|whatsapp_click`.
2. **Membership:** `section_view{membership} → plan_calculator_complete → plan_select → contact_submit`.
3. **Capture:** `section_view{newsletter} → newsletter_submit`.
4. **Onboarding:** `start_here_select → cta_book`.

## Dashboards & KPIs (tie to `24` success metrics)
- Conversion: `cta_book` CTR, enquiry rate, newsletter rate, WhatsApp CTR.
- Engagement: scroll depth, section views, gallery/palette usage, returning rate.
- Quality: bounce, time-on-page, CWV field data (separate, `11`).

## Implementation notes
- Load GTM **after** idle/interaction (perf budget `11 §3.7`).
- Gate analytics behind consent; provide opt-out; honour DNT/GPC where applicable (`21`).
- `lib/track.ts`: `track(event, props)` no-ops if consent absent or in dev; typed event union to prevent typos.
