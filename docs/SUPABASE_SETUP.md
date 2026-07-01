# Supabase Setup — Single Project, Both Apps

This monorepo has **one** `supabase/` directory at the repo root (migrations,
pgTAP tests, Edge Functions). Both `flutter-app/` and `website/` point at the
**same** Supabase project — there is no "flutter's database" and "website's
database."

## Current state — CONNECTED AND VERIFIED (2026-07-02)

**Project:** `divinity-tte`, ref `ryvilbtrsnjncyfeskqm`, region `ap-south-1`,
status `ACTIVE_HEALTHY`, Postgres 17.6.1.

(An earlier project ref, `wimjviyvtgkfmlesxted`, found in an old `.env`, no
longer resolves over DNS — it's gone. `ryvilbtrsnjncyfeskqm` is the real,
current one. Don't confuse the two if you see the old ref anywhere in
history/docs.)

Everything below was checked **against the live project itself**, not just
locally:

- `supabase link --project-ref ryvilbtrsnjncyfeskqm` — linked successfully.
- `supabase migration list --linked` — **all 36 migrations (001–036) are
  applied and match exactly** between local and remote. `supabase db diff
  --linked` reports "No schema changes found."
- RLS confirmed live: anonymous REST requests to `/rest/v1/users` and
  `/rest/v1/library_books` both return `[]` (blocked, not erroring/leaking).
- `verify-certificate` Edge Function: was **not deployed** — deployed this
  session (`supabase functions deploy verify-certificate --no-verify-jwt`),
  confirmed live at
  `https://ryvilbtrsnjncyfeskqm.supabase.co/functions/v1/verify-certificate`
  with correct responses for bad-format and not-found codes.
- **Fixed a real, live security issue:** the `payment_screenshots` Storage
  bucket was `public: true` on the actual project — migration `031` can only
  add RLS *policies* via SQL, it cannot flip a bucket's public/private flag
  (that's a Management API-only setting). Fixed via
  `PUT /storage/v1/bucket/payment_screenshots` with `{"public": false}`,
  confirmed via a follow-up `GET` that it's now `"public": false`. This was
  LB-5 from the earlier audit — it is now actually resolved, not just coded.
- Only one Storage bucket exists (`payment_screenshots`) — there's no
  separate avatars/other bucket to worry about.

### GitHub Secrets — set on `DIVINITY-THE-THIRD-EYE/Divinity-OS`

| Secret | Status |
|---|---|
| `SUPABASE_URL` | ✅ set — `https://ryvilbtrsnjncyfeskqm.supabase.co` |
| `SUPABASE_ANON_KEY` | ✅ set — the real publishable key |
| `SUPABASE_PROJECT_REF` | ✅ set — `ryvilbtrsnjncyfeskqm` |
| `ANDROID_KEYSTORE_BASE64` | ✅ set — freshly generated this session (previous session's keystore was lost when its source folder was cleaned up; regenerated, safe since this app was never submitted to Play Store) |
| `ANDROID_STORE_PASSWORD` | ✅ set |
| `ANDROID_KEY_PASSWORD` | ✅ set (same value as store password — PKCS12 keystores only support one) |
| `ANDROID_KEY_ALIAS` | ✅ set — `divinity-upload` |
| `SUPABASE_ACCESS_TOKEN` | ✅ set — verified valid (`supabase projects list` succeeds with it), and `supabase-deploy.yml` was manually triggered (`gh workflow run`) and **completed successfully end-to-end**: linked the project, pushed migrations, deployed the Edge Function, all green. |

**All 8 secrets are set and the full CI/CD pipeline is verified working, not just configured.** Every push to `main` touching `supabase/migrations/**` or `supabase/functions/**` now auto-deploys to production.

The local `flutter-app/.env` (gitignored) has been updated to the real
project's URL/anon key, replacing the old dead `wimjviyvtgkfmlesxted` values.

### Website `CERT_VERIFY_ENDPOINT`

Still needs to be set on the website's Vercel project (Settings →
Environment Variables), since that's outside this repo/CI:
```
CERT_VERIFY_ENDPOINT=https://ryvilbtrsnjncyfeskqm.supabase.co/functions/v1/verify-certificate
```

## If you need to re-link from a fresh machine/session

Run from the **repo root** — the Supabase CLI expects to be run from the
directory that *contains* `supabase/`, not from inside it.

```bash
supabase login
supabase link --project-ref ryvilbtrsnjncyfeskqm
```

## Local Docker-based dev stack (separate from the real project)

This is what `pgtap.yml` in CI uses, and what you'd use to test a new
migration before pushing it live:

```bash
# from the repo root
supabase start      # spins up an ephemeral local Postgres in Docker
supabase db reset    # applies 001-036 fresh
supabase test db     # runs all 16 pgTAP files, 117 assertions
supabase stop
```

This never touches the real `ryvilbtrsnjncyfeskqm` project — it's a fully
separate, disposable local instance.

## Deploying a new migration or Edge Function change to production

```bash
# from the repo root, already linked (see above)
supabase db push                                          # migrations
supabase functions deploy verify-certificate --no-verify-jwt  # if the function changed
```

Once `SUPABASE_ACCESS_TOKEN` is added to GitHub Secrets, `supabase-deploy.yml`
does this automatically on every push to `main` that touches
`supabase/migrations/**` or `supabase/functions/**` — manual deploy is only
needed until that secret exists, or if you want to push out-of-band.

## Remaining open items

1. `CERT_VERIFY_ENDPOINT` on Vercel (website project) — value is in the
   table above.
2. A4/A5 (Play Store / App Store signing) — the Android keystore secrets are
   in place and CI can build a signed AAB, but there's still no Play Console
   app / Apple Developer account connected to actually publish it.

Supabase itself is fully wired: real project connected, migrations synced,
RLS verified live, Edge Function deployed, one live security bug (public
storage bucket) fixed, and the deploy pipeline proven working via an actual
GitHub Actions run.
