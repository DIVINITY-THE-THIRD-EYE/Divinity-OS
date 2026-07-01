# Authentication Migration & Rollback Strategy

This document outlines the transition plan for upgrading the Divinity authentication ecosystem from a phone-only model to a multi-provider configurable architecture (supporting Email/Password, Google, Apple, and Phone/OTP).

---

## 1. Migration Plan

### Database Upgrades
1. Apply the migration `025_add_auth_provider.sql` to the production database:
   - This adds the `auth_provider` column to the `public.users` table.
   - It replaces the `handle_new_user()` trigger function to automatically extract the auth provider from the metadata of new signups.
   - It runs a backfill to populate `auth_provider = 'email'` for all existing users who registered before the column was created.
2. In the Supabase project console, enable the required OAuth providers:
   - **Google**: Configure Client ID and Secret under Authentication > Providers.
   - **Apple**: Register App ID, Services ID, Private Key, and Team ID.

### Client-Side Settings
- Enable/disable methods using Firebase Remote Config variables:
  - `auth_enable_email`: `true`
  - `auth_enable_google`: `true`
  - `auth_enable_apple`: `true`
  - `auth_enable_phone`: `true`
  - `auth_enable_anonymous`: `false`

---

## 2. Data Compatibility

- **No Breaking Changes**: Existing users registered via Phone number continue to exist in `auth.users` and `public.users`. Their login methods are untouched.
- **Dynamic Linkage**: Supabase Auth handles linking multiple identities (e.g., if a user signs up with Google using the same email as an existing account, Supabase can link them based on configuration).
- **Triggers**: The trigger function uses `on conflict (id) do update` to ensure that if a user updates their auth method or profile, their record is safely merged without breaking foreign keys (enrollments, attendance, payments, etc.).

---

## 3. Rollback Plan

If any critical auth failures occur in production, execute these steps:

### Step 1: Remote Config Toggle (Fastest)
1. Navigate to the Firebase Remote Config dashboard.
2. Set the flags:
   - `auth_enable_email` = `false`
   - `auth_enable_google` = `false`
   - `auth_enable_apple` = `false`
   - `auth_enable_phone` = `true`
3. Publish changes. The mobile clients will immediately fall back to displaying only the Phone sign-in options, reverting the login experience to the original state without pushing an app store update.

### Step 2: Database Rollback (If needed)
If you need to roll back database changes, run the following SQL statements in the Supabase SQL editor:
```sql
-- 1. Drop trigger and restore previous trigger function
drop trigger if exists on_auth_user_created on auth.users;

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer
set search_path = public as $$
begin
  insert into public.users (id, email, phone, name)
  values (
    new.id,
    new.email,
    new.phone,
    coalesce(
      new.raw_user_meta_data->>'name',
      split_part(coalesce(new.email, ''), '@', 1)
    )
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 2. Drop the column (optional - safe to keep)
alter table public.users drop column if exists auth_provider;
```
