# Phase 15 — DevOps & Infrastructure

> Sources: website README (deploy), `Divinity/build_all.ps1`/`.bat`, `Divinity/.github/`, `.claude/launch.json`, ADRs.

## Hosting

| Component | Host |
|---|---|
| Website | **Vercel** (Next.js auto-detected) |
| Backend data/auth/storage | **Supabase** (managed Postgres) |
| Messaging/analytics/crash | **Firebase** |
| App distribution | Play Store / App Store `[Needs Verification]` |
| Edge/CDN | Vercel edge (+ Cloudflare per CLAUDE.md project context) |

## Domains

`[Needs Verification]`: production domain not committed (set `site.url` in `lib/content.ts` before launch — README checklist). Likely a `divinity*`/third-eye domain.

## CDN

Vercel CDN/edge caching for the website (static + SSG). Image optimization served from Vercel. Cloudflare referenced as an option in `Divinity/CLAUDE.md`.

## CI/CD

- **Vercel** builds on push (website). `next lint` runs in the production build.
- `Divinity/.github/` exists — `[Needs Verification]`: confirm workflow contents (the `docs` listing didn't enumerate `.github/workflows`). Recommend documenting any GitHub Actions there.
- **Local unified build:** `Divinity/build_all.ps1` builds website + Flutter APK/AAB (+ iOS on macOS). Caveat: it targets `Divinity/apps/*` (older copies) and a hard-coded path — update to the live trees.

## Monitoring

- App: Firebase Crashlytics + Analytics.
- Web: `[Needs Verification]` (Vercel Analytics likely). See [28_Observability](28_Observability.md).

## Logging

- Web API routes log fallback events server-side; Vercel function logs.
- App: Crashlytics. Centralized log aggregation `[Needs Verification]`.

## Alerting

`[Needs Verification]`: no committed alert rules. Recommend Crashlytics velocity alerts + uptime checks (`Divinity:canary-watch` skill available).

## Secrets Management

`.env` / `.env.local` (gitignored) locally; Vercel env vars for web; app `.env` bundled (anon-safe) — service keys must stay server-side. See [12_Security](12_Security.md).

## Disaster Recovery

Supabase managed backups; redeploy from git. Detailed RPO/RTO: [27_Business_Continuity](27_Business_Continuity.md) (`[Needs Verification]`).

## Dev environment

- `.claude/launch.json` runs `npm --prefix website run dev` on port 3000 (fixed 2026-07-02 —
  previously pointed at the pre-monorepo path `divinity-third-eye/divinity`, which no longer
  exists and would have failed to start).
- `.nvmrc` pins Node for the website. Flutter SDK + Dart for the app.
