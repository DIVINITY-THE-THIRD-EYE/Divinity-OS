# Glossary

| Term | Definition |
|---|---|
| **Divinity — The Third Eye** | The brand: a yoga/fitness/wellness academy in Lucknow, guided by Sachin Rajvanshi. |
| **Academy OS** | The Flutter app ("Academy Operating System") serving Student/Trainer/Admin. |
| **The Third Eye** | Brand motif; also the student-progress dashboard (`third_eye_dashboard_screen`). |
| **Breathe** | The product's organizing concept (pranayama); drives motion + UX cadence (inhale 4s · hold 4s · exhale 6s). |
| **Method** | The signature sequence: **Align → Awaken → Ascend** (the only numbered content on the site). |
| **Disciplines** | The academy's offerings, grouped by *intention* (for the body / for the breath / for healing), not numbered. |
| **Batch** | A scheduled class group with a location (lat/long + `radius_meters`) and time. |
| **Enrollment** | A student↔batch membership row; created by staff. |
| **Geofenced check-in** | Attendance via the `check_in` RPC; valid only within a batch's radius (`haversine_m`). |
| **Streak** | Consecutive attendance count, maintained by DB triggers. |
| **Transformation Score** | A student's progress metric (`transformation_scores` table). |
| **Therapeutic log** | Diet/therapeutic note for a student, with trainer comments. |
| **Lead** | A prospective student in the admissions CRM (`leads`); converted via `convert_lead_to_member`. |
| **RLS** | Row-Level Security — Postgres per-row authorization; enabled on every table. |
| **Privileged fields** | Columns (role, approval/payment status) locked by triggers against self-edit. |
| **JWT role sync** | Trigger (`sync_user_role_to_auth`) mirroring `users.role` into auth `app_metadata` for RLS. |
| **Role shell** | The app's per-role navigation container (student/trainer/admin). |
| **Plan / Membership** | A paid membership tier; tracked on `payments` (`plan_name`, `plan_expiration_date`). |
| **UPI QR payment** | Manual payment model: pay via UPI, upload screenshot, staff verify (ADR-0006). |
| **Brevo** | Transactional email provider for the website forms (ADR-0005). |
| **Sanity** | Optional headless CMS for marketing content (disciplines/plans/testimonials). |
| **Fallback content** | `lib/content.ts` values used when Sanity isn't configured (zero-config guarantee). |
| **RSC island** | A client component embedded in an otherwise server-rendered page (ADR-0008). |
| **Lenis / GSAP / Framer Motion** | The web motion stack (smooth scroll / scroll-tied / micro-animation). |
| **ADR** | Architecture Decision Record (`design/adr/`). |
| **`[Needs Verification]`** | A fact not evidenced in the repo; must be confirmed by a human, not guessed. |
| **EXTRA_FILES** | Quarantine folder for duplicates/junk produced by the cleanup (never deleted). |
| **ANTIGRAVITY** | The monorepo's AI tool-library folder (third-party skill clones `_g1`–`_g5`). |
