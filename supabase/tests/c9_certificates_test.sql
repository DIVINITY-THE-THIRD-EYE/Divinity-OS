-- c9_certificates_test.sql (pgTAP)
-- Run with:  supabase test db
--
-- Verifies the certificates feature (migration 024):
--   - trainers/admins can issue certificates
--   - the verification code is auto-generated in DIV-XXXX-XXXX format
--   - students can read ONLY their own certificate (RLS)
--   - students cannot forge a certificate for themselves
-- ─────────────────────────────────────────────────────────────────────────────

begin;
select plan(8);

-- ── Fixtures ─────────────────────────────────────────────────────────────────
insert into auth.users (id, email) values
  ('11111111-1111-1111-1111-111111111111', 'student1.c9@test.local'),
  ('22222222-2222-2222-2222-222222222222', 'student2.c9@test.local'),
  ('33333333-3333-3333-3333-333333333333', 'trainer.c9@test.local'),
  ('44444444-4444-4444-4444-444444444444', 'admin.c9@test.local');

update public.users set role = 'STUDENT' where id in ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222');
update public.users set role = 'TRAINER' where id = '33333333-3333-3333-3333-333333333333';
update public.users set role = 'ADMIN'   where id = '44444444-4444-4444-4444-444444444444';

-- ── Helper to act as user ────────────────────────────────────────────────────
create or replace function pg_temp.act_as(uid uuid) returns void
language plpgsql as $$
begin
  perform set_config('role', 'authenticated', true);
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', uid::text, 'role', 'authenticated')::text,
    true
  );
end; $$;

-- ── Test 1: Trainer issues a certificate ─────────────────────────────────────
select pg_temp.act_as('33333333-3333-3333-3333-333333333333');

select lives_ok(
  $$ insert into public.certificates (student_id, issued_by, programme)
     values ('11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333', '200-Hour Foundation') $$,
  'C9.1 Trainer can issue a certificate to a student'
);

-- ── Test 2: Code auto-generated in DIV-XXXX-XXXX format ───────────────────────
select matches(
  (select code from public.certificates where student_id = '11111111-1111-1111-1111-111111111111' limit 1),
  '^DIV-[A-Z0-9]{4}-[A-Z0-9]{4}$',
  'C9.2 Verification code is auto-generated in DIV-XXXX-XXXX format'
);

-- ── Test 3: Default title applied ────────────────────────────────────────────
select is(
  (select title from public.certificates where student_id = '11111111-1111-1111-1111-111111111111' limit 1),
  'Certificate of Completion'::text,
  'C9.3 Default certificate title is applied'
);

-- ── Test 4: Owning student can read their certificate ────────────────────────
select pg_temp.act_as('11111111-1111-1111-1111-111111111111');

select is(
  (select count(*)::int from public.certificates where student_id = '11111111-1111-1111-1111-111111111111'),
  1,
  'C9.4 Student can read their own certificate'
);

-- ── Test 5: Student cannot read another student''s certificate (RLS) ──────────
select pg_temp.act_as('22222222-2222-2222-2222-222222222222');

select is(
  (select count(*)::int from public.certificates where student_id = '11111111-1111-1111-1111-111111111111'),
  0,
  'C9.5 Student cannot read another student''s certificate'
);

-- ── Test 6: Student cannot forge a certificate for themselves ────────────────
select pg_temp.act_as('22222222-2222-2222-2222-222222222222');

select throws_ok(
  $$ insert into public.certificates (student_id, programme)
     values ('22222222-2222-2222-2222-222222222222', 'Self-issued (should fail)') $$,
  '42501',
  null,
  'C9.6 Student cannot issue a certificate to themselves'
);

-- ── Test 7: Admin can read all certificates ──────────────────────────────────
select pg_temp.act_as('44444444-4444-4444-4444-444444444444');

select is(
  (select count(*)::int from public.certificates where student_id = '11111111-1111-1111-1111-111111111111'),
  1,
  'C9.7 Admin can read any certificate'
);

-- ── Test 8: Admin can revoke (delete) a certificate ──────────────────────────
select lives_ok(
  $$ delete from public.certificates where student_id = '11111111-1111-1111-1111-111111111111' $$,
  'C9.8 Admin can revoke (delete) a certificate'
);

select * from finish();
rollback;
