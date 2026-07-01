# Module Index

## Flutter app feature modules (`lib/features/`)

Each module = `data/` (repositories ↔ Supabase) + `domain/` (models) + `presentation/` (Riverpod providers + screens).

| Module | Responsibility | Key tables/RPCs |
|---|---|---|
| `auth` | OTP login, onboarding, role gating | `users`, Supabase Auth, JWT sync |
| `admissions` | leads CRM | `leads`, `convert_lead_to_member` |
| `batches` | class batches + enrollment | `batches`, `enrollments` |
| `attendance` | geofenced check-in + history | `attendance`, `check_in`, streak triggers |
| `leave` | leave requests + approval | `leave_requests` |
| `payments` | UPI payment + verification | `payments`, payment triggers, Storage |
| `notifications` | in-app inbox + push | `notifications`, FCM |
| `holidays` | academy calendar | `holidays` |
| `home` | student home dashboard | aggregate reads |
| `dashboard` | admin dashboard/KPIs | `dashboard_stats` (queries) |
| `profile` | profile edit | `users` (non-privileged) |
| `therapeutic_logs` | diet/therapeutic notes | `therapeutic_logs` |
| `transformation` | "Third Eye" progress | `transformation_scores` |
| `trainer` | trainer dashboard + check-in | scoped student data |
| `shells` | role navigation containers | — |

## App shared/infra

| Module | Responsibility |
|---|---|
| `core/router` | GoRouter, transitions, redirects |
| `core/theme` | theme, motion, constants |
| `services` | `fcm_service`, `fcm_provider`, `analytics_service` |
| `shared/widgets` | reusable UI (shimmer, spring_tap, third_eye_icon, notification_bell, ...) |

## Website modules (`lib/`)

| Module | Responsibility |
|---|---|
| `content` | content source of truth + CMS fallback + slug helpers |
| `sanity` | Sanity client + `fetchOrFallback` |
| `seo` | per-page metadata (`pageMeta`) |
| `nav` | navigation single source of truth |
| `rate-limit` | API abuse guard |
| `validation` / `form-error` | input validation + error shaping |
| `recommend` | plan recommendation logic |
| `links` | WhatsApp `waHref` + link helpers |
| `focus-trap` | a11y focus management |

## Prisma website modules (Reference)

| Module | Responsibility |
|---|---|
| `server` | Standalone Express server simulating database operations with Excel sheet |
| `prisma` | Database schema for Postgres integration |
| `tRPC Router` | tRPC router definitions for type-safe backend integration |
| `aura-canvas` | Three.js shader components for WebGL visuals |

## Backend "modules" (Postgres)

| Module | Responsibility |
|---|---|
| Auth/role | `is_admin`/`is_trainer` helpers, `sync_user_role_to_auth` |
| Attendance | `haversine_m`, `check_in`, streak functions |
| Payments | `process_payment_transitions`, `propagate_payment_status`, `lock_payment_fields`, `handle_payment_notification` |
| Admissions | `convert_lead_to_member` |
| Integrity | `lock_privileged_fields`, `lock_onboarded_fields`, `set_updated_at`, `handle_new_user` |
