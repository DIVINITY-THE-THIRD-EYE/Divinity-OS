# FAQ

**Q: What are the live projects vs. the duplicates?**
The live products are `flutter-app/` (app) and `website/` (website) at the workspace root. `Divinity/apps/*` holds older copies; old snapshots and strays were quarantined to `EXTRA_FILES/`. See [02_Repository_Discovery](02_Repository_Discovery.md) and [EXTRA_FILES/MIGRATION_REPORT.md](../EXTRA_FILES/MIGRATION_REPORT.md).

**Q: Where does business data live?**
Supabase Postgres (20 tables, RLS). Firebase is only for push/analytics/crash. The website has no Supabase SDK dependency (it calls the `verify-certificate` Edge Function over plain HTTP). ([03_System_Architecture](03_System_Architecture.md))

**Q: How does login work?**
Passwordless OTP via Supabase Auth; role travels in the JWT `app_metadata` and is synced from `users.role` by a trigger. ([10_Auth_Authorization](10_Auth_Authorization.md))

**Q: How are payments handled?**
Manual UPI: student uploads a payment screenshot, staff verify; a DB state machine + triggers manage status, expiry, and notifications. No payment gateway (ADR-0006). ([05_Student_Mobile_App](05_Student_Mobile_App.md), [09_Database](09_Database.md))

**Q: How does attendance prevent cheating?**
Check-in is a geofenced RPC (`check_in` + `haversine_m`) validated against the batch's coordinates and `radius_meters`. Tested by `c2_geofence_test`.

**Q: Can I run the website without any API keys?**
Yes — zero-config with graceful fallbacks. Sanity (CMS) and Brevo (email) are optional. ([04_Public_Website](04_Public_Website.md))

**Q: What must never be broken?**
RLS + privileged-field locks, the payment state machine, the zero-config web guarantee, and the brand tokens/"Breathe" concept. ([AI_CONTEXT §8](AI_CONTEXT.md))

**Q: What's the biggest known tech debt?**
In-memory rate limiter (not multi-instance safe), no committed web E2E/CI a11y, no audit-log table, no scheduled expiry reminders, unconfirmed web analytics provider. ([20_Project_History](20_Project_History.md))

**Q: What does `[Needs Verification]` mean?**
The repository didn't contain that fact, so it's flagged for a human to confirm rather than guessed (e.g., real pricing, infra tiers, legal entity).

**Q: Where do I record a new architectural decision?**
Web → `design/adr/`; cross-cutting → [DECISION_LOG.md](DECISION_LOG.md). Then update the affected phase doc.

**Q: Who is the academy?**
Divinity — The Third Eye, Lucknow, guided by Sachin Rajvanshi. ([Appendix/Brand_and_Content_Library](Appendix/Brand_and_Content_Library.md))
