# Project History

> Narrative history of the **product**. The structured changelog/migration history is in [20_Project_History](20_Project_History.md); decisions in [DECISION_LOG](DECISION_LOG.md).

## Origins

Divinity — The Third Eye began as a **marketing website** for a Lucknow yoga/wellness academy guided by Sachin Rajvanshi, built on the "Breathe" concept (Next.js + GSAP/Lenis, Sanity-optional, Brevo). The site was deliberately scoped to exclude the member portal/app to stay fast, static, and secure (website README "Deliberately out of scope").

## The app ("Academy OS")

The member-facing product was then built separately as a Flutter app on Supabase + Firebase, in a sequence of build "sessions" (visible in git history):

- **Session 0** — scaffold (Riverpod + GoRouter + Supabase + theme).
- **Session 1** — OTP auth, role shells, users RLS.
- **Sessions 2–3** — onboarding, batches, CRM leads, attendance check-in, leave, admin activation.
- **Session 4** — payments, notifications, trainer dashboard.
- **Session 5** — Firebase/FCM, admin dashboard (charts), profile.
- **Session 6** — Firebase cleanup, student home, admin CSV export, FCM deep-linking.

The data model matured across **23 Supabase migrations**, including a notable RLS-recursion fix (012), JWT role sync (017), and a full payment-verification flow (022–023). A standing **c1–c8 security test suite** locks the security model.

## Workspace evolution

The project accreted **multiple copies** (a monorepo consolidation under `Divinity/`, plus working copies at the root and old snapshots in `ANTIGRAVITY/`). On 2026-06-30 a migration-style cleanup proved canonical copies via git/hash and quarantined provable duplicates into `EXTRA_FILES/` (nothing deleted) — establishing the current clean root and this Bible.

## Where it's headed

Closed beta → store release; richer programs (diet/workout), possible self-booking and a payment gateway, web analytics, and hardening (audit log, scheduled reminders). See [21_Future_Roadmap](21_Future_Roadmap.md).

> Founding dates, team, and milestones with calendar dates are `[Needs Verification]` (not in repo; git history is "session"-based, not dated here).
