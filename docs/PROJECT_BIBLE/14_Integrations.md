# Phase 14 — Integrations

> Sources: `pubspec.yaml`, `firebase_options.dart`, `lib/sanity.ts`, `app/api/`, website README, ADRs 0004/0005/0006/0011.

## Supabase (primary backend)

- **Used by:** Flutter app (`supabase_flutter`). **Not** used by the website (deliberate scope).
- **Surfaces:** Auth (OTP), Postgres (20 tables + RLS + RPC), Storage (payment screenshots, private), realtime.
- **Config:** URL + anon key in app `.env`. Anon key is safe client-side because RLS gates everything.
- See [08_Backend](08_Backend.md), [09_Database](09_Database.md), [10_Auth_Authorization](10_Auth_Authorization.md).

## Firebase

- **Packages:** `firebase_core`, `firebase_analytics`, `firebase_crashlytics`, `firebase_messaging`, `firebase_ai`, `firebase_app_check`, `firebase_remote_config`.
- **Role (ADR-0011):** messaging, analytics, crash reporting, Spark-compatible generative AI features (Gemini Developer API), App Check endpoint security, and Remote Config parameters/A/B experiments. Not primary user database (primary data resides on Supabase).
- **Config:** `lib/firebase_options.dart` (generated). Services: `fcm_service.dart`, `analytics_service.dart`, `app_check_service.dart`, `ai_service.dart`.

## Payment Providers

- **Model:** manual **UPI QR** (ADR-0006). No payment gateway/SDK. Student uploads UPI screenshot; staff verifies. Web shows the UPI QR (`public/payment-qr.png`).
- `[Needs Verification]`: whether a gateway (Razorpay/Stripe) is on the roadmap.

## Email

- **Brevo** (transactional API, ADR-0005) for `/api/contact` and `/api/subscribe`. Graceful fallback (logs) without `BREVO_API_KEY`.

## SMS

`[Needs Verification]`: no SMS provider found. OTP is email-based via Supabase. (If SMS OTP is desired, integrate a provider — see deferred Twilio skills.)

## WhatsApp

- **Conversion channel**, not an API integration: `WhatsAppFab` + `lib/links.ts` `waHref` build pre-filled `wa.me` links. Number set in `lib/content.ts` (`whatsapp`). `[Needs Verification]` for WhatsApp Business API usage (currently click-to-chat only).

## Analytics

- **App:** Firebase Analytics (`analytics_service.dart`).
- **Web:** `[Needs Verification]` (taxonomy exists; provider unconfirmed). See [23_Data_Analytics](23_Data_Analytics.md).

## Maps

- **Web:** Accessible, responsive keyless Google Maps iframe embed on the Contact page showing the studio location at Butler Colony, Lucknow. Configured dynamically from `locationConfig` in `lib/content.ts`. Includes "Open in Google Maps" and "Directions" link triggers.
- **App:** Geolocation via `geolocator` for geofenced check-in (distance calculated server-side via `haversine_m` RPC).

## Open-Meteo Weather & Air Quality

- **Used by:** Both website (`WeatherWidget.tsx`) and mobile app (`weather_widget.dart` / `weather_service.dart`).
- **Endpoints:**
  - Weather: `https://api.open-meteo.com/v1/forecast?latitude=LAT&longitude=LNG&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,uv_index&daily=sunrise,sunset`
  - AQI: `https://air-quality-api.open-meteo.com/v1/air-quality?latitude=LAT&longitude=LNG&current=us_aqi`
- **Cache Strategy:** Responses cached locally (client-side `localStorage` on web, `SharedPreferences` on app) with a **15-minute Time-To-Live (TTL)**. Manual updates (pull-to-refresh) force cache bypass.
- **Graceful Fallback:** If APIs timeout (5s) or fail, previous cached values are rendered alongside an offline notice. If no cache exists, a retry state is shown.
- **Wellness Recommendations:**
  - *Unhealthy AQI (>100):* "Better to practice indoors today."
  - *Extreme Heat (>38°C):* "Consider restorative sessions due to heat."
  - *High Temp (35°C–38°C):* "Stay hydrated during afternoon classes."
  - *Pleasant & Good AQI (18°C–30°C, AQI <= 50):* "Excellent day for outdoor yoga."
  - *Cold (<15°C):* "Warm up dynamically indoors today."
  - *Default/Otherwise:* "Good conditions for pranayama."

## Third-Party APIs

- **Sanity** CMS (optional) — GROQ via `lib/sanity.ts`, schemas in `sanity/schemas/`.
- **Google Fonts** — via `next/font` (web) and `google_fonts` (app).
- ANTIGRAVITY tool clones (`_g1`–`_g5`) are dev tooling, not runtime integrations.

## Integration matrix

| Integration | Web | App | Required? | Cache / Fallback |
|---|---|---|---|---|
| Supabase | — | ✅ | yes (app) | local schemas / offline queues |
| Firebase | — | ✅ | yes (app) | Local cached metrics / FCM fallback |
| Open-Meteo | ✅ | ✅ | no | 15-minute TTL cache / Cached fallback / Retry button |
| Google Maps | ✅ | — | no | Static keyless iframe fallback |
| Sanity | optional | — | no (fallback) | Local JSON fallback |
| Brevo | ✅ | — | no (fallback) | Console logs in dev / Retry |
| UPI/WhatsApp | ✅ links | ✅ | manual | URL-intent anchors |
