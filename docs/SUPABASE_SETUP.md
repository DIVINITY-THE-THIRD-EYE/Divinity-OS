# Supabase Setup — Single Project, Both Apps

This monorepo has **one** `supabase/` directory at the repo root (migrations,
pgTAP tests, Edge Functions). Both `flutter-app/` and `website/` are meant to
point at the **same** Supabase project — there is no "flutter's database" and
"website's database."

## Current state (as of this writing)

- `flutter-app/.env` (gitignored, not committed) contains:
  ```
  SUPABASE_URL=https://wimjviyvtgkfmlesxted.supabase.co
  SUPABASE_ANON_KEY=sb_publishable_XFUNQgaTZKV0XM0F2CSviQ_5Rn9jHN7
  ```
- **This project does not currently resolve.** `wimjviyvtgkfmlesxted.supabase.co`
  returns `NXDOMAIN` (non-existent domain) — confirmed with `nslookup` and `curl`
  from a network that can otherwise reach `supabase.com` and other hosts fine.
  This means the project referenced by that URL has been deleted, paused in a
  way that also drops DNS (unusual), or was never actually created and the
  value is a placeholder someone typed in.
- `supabase/config.toml` does not exist in this repo — the project has never
  been `supabase link`-ed from a development machine that committed the link.
- A `.supabase_db_password.txt` (gitignored, repo root) appeared during this
  session containing a database password. On its own this doesn't unblock
  anything — the CLI's `supabase link`/`db push` auth path needs an **access
  token** (`supabase login` or `SUPABASE_ACCESS_TOKEN`), not just a DB
  password, and regardless the project still doesn't resolve over DNS (see
  above). Keep it for when the project situation is resolved.
- No `SUPABASE_ACCESS_TOKEN` or project ref was available in this session, so
  none of the following could be done against a real cloud project:
  - Applying `supabase/migrations/*.sql` to production (`supabase db push`)
  - Verifying RLS policies via the Supabase dashboard/API on the real project
  - Deploying `supabase/functions/verify-certificate`
  - Confirming Storage bucket configuration (`payment_screenshots` private +
    signed URLs, per migration `031_payment_screenshots_bucket_private.sql`)

Everything below **has** been verified against a local Supabase stack (Docker)
via `supabase db reset` + `supabase test db` — 36 migrations apply cleanly, all
16 pgTAP files (117 assertions) pass, and the `verify-certificate` Edge
Function was smoke-tested with `supabase functions serve`. None of that proves
the *production* project is in this state — only that the code is correct.

## What you need to do to actually finish this

### 1. Confirm or create the production Supabase project

Log into https://supabase.com/dashboard and check whether a project already
exists for Divinity. If `wimjviyvtgkfmlesxted` is genuinely gone, either:
- restore it if it was deleted by mistake (Supabase support, within their
  retention window), or
- create a new project — **do not** do this without telling whoever's
  coordinating this work, since the instruction was explicitly not to spin up
  a new project without being asked.

Once you have a real project, get from **Project Settings → API**:
- Project URL (`https://<ref>.supabase.co`)
- `anon`/`publishable` key
- `service_role`/`secret` key (server-only, never client-side)
- Project ref (the `<ref>` part of the URL)

And from **Project Settings → Database**: the database password (needed for
`supabase link` in some flows).

### 2. Link this repo to the project locally

Run from the **repo root** — the Supabase CLI expects to be run from the
directory that *contains* `supabase/`, not from inside it.

```bash
supabase login
supabase link --project-ref <your-project-ref>
```

### 3. Apply all migrations

```bash
supabase db push
```

This applies `supabase/migrations/001_users_rls.sql` through
`036_batch_enrollment_capacity.sql` in order. They're all idempotent
(`create table if not exists`, `create or replace function`, etc.) so this is
safe to re-run.

### 4. Verify RLS policies on the real project

Run the same pgTAP suite against the *linked* remote project instead of local:

```bash
supabase test db --linked
```

If that flag/flow isn't available in your CLI version, at minimum manually spot
check the high-risk tables in the dashboard's SQL editor:
- `payment_screenshots` storage bucket is **private** (not public), matches
  migration `031`
- `library_books` UPDATE policy is scoped to the student's own rows, not
  everyone (migration `030`)
- `users.is_active` can only be changed by an admin (migration `032`)

### 5. Deploy the Edge Function

```bash
supabase functions deploy verify-certificate --no-verify-jwt
```

Then set on the **website's** Vercel project (Settings → Environment
Variables): `CERT_VERIFY_ENDPOINT` = `https://<project-ref>.supabase.co/functions/v1/verify-certificate`

### 6. Configure environment variables everywhere that needs them

| Where | Variable(s) | Value |
|---|---|---|
| `flutter-app/dart_defines.json` (local, gitignored — copy from `.example`) | `SUPABASE_URL`, `SUPABASE_ANON_KEY` | from step 1 |
| GitHub Secrets on this repo (`.github/workflows/flutter.yml`, `release-flutter.yml`) | `SUPABASE_URL`, `SUPABASE_ANON_KEY` | same values, for CI release builds |
| GitHub Secrets on this repo (`supabase-deploy.yml`) | `SUPABASE_ACCESS_TOKEN`, `SUPABASE_PROJECT_REF` | personal access token from https://supabase.com/dashboard/account/tokens + the project ref |
| Vercel project settings (website) | `CERT_VERIFY_ENDPOINT` | from step 5 |
| Vercel project settings (website) | `BREVO_*`, `NEXT_PUBLIC_SANITY_*` | unrelated to Supabase — see `website/.env.local.example` |

Both `flutter-app` and `website` now read from the **same** project once these
are all filled in with the same URL/ref — there is no separate project for
either app, by design.

### 7. Confirm CI is green end to end

Once GitHub Secrets are set, push to `main` and check:
- `flutter.yml` → `build-android` job succeeds (needs Android keystore secrets too — see `STATUS.md`)
- `website.yml` → `build` job succeeds
- `pgtap.yml` → runs `supabase start` + `supabase test db` against an **ephemeral** local stack in the CI runner (not your production project — this is intentional, it never touches prod)
- `supabase-deploy.yml` → pushes migrations + deploys the Edge Function to production on every push to `main` that touches `supabase/migrations/**` or `supabase/functions/**`
