-- 025_add_auth_provider.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- Add auth_provider column to users table and update new user trigger.
-- ─────────────────────────────────────────────────────────────────────────────

-- 1. Add column to public.users
alter table public.users add column if not exists auth_provider text;

-- 2. Update the handle_new_user trigger function
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer
set search_path = public as $$
begin
  insert into public.users (id, email, phone, name, auth_provider)
  values (
    new.id,
    new.email,
    new.phone,
    coalesce(
      new.raw_user_meta_data->>'name',
      split_part(coalesce(new.email, ''), '@', 1)
    ),
    coalesce(new.raw_app_meta_data->>'provider', 'email')
  )
  on conflict (id) do update
  set auth_provider = coalesce(new.raw_app_meta_data->>'provider', 'email'),
      email = coalesce(new.email, public.users.email),
      phone = coalesce(new.phone, public.users.phone);
  return new;
end;
$$;

-- 3. Backfill existing users using their auth metadata
update public.users u
set auth_provider = coalesce(
  (select raw_app_meta_data->>'provider' from auth.users where id = u.id),
  'email'
)
where auth_provider is null;
