-- c15_support_tickets_test.sql (pgTAP)
-- Run with: supabase test db

begin;
select plan(9);

-- ── Fixtures ─────────────────────────────────────────────────────────────────
insert into auth.users (id, email) values
  ('11111111-1111-1111-1111-111111111111', 'student1.c15@test.local'),
  ('22222222-2222-2222-2222-222222222222', 'student2.c15@test.local'),
  ('55555555-5555-5555-5555-555555555555', 'admin.c15@test.local');

update public.users set role = 'STUDENT' where id in ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222');
update public.users set role = 'ADMIN' where id = '55555555-5555-5555-5555-555555555555';

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

-- ── Test 1: Student can insert a ticket with valid fields ─────────────────────
select pg_temp.act_as('11111111-1111-1111-1111-111111111111');

select lives_ok(
  $$ insert into public.support_tickets (id, student_id, subject, description)
     values ('11111111-1111-1111-1111-111111111101', '11111111-1111-1111-1111-111111111111', 'App Crash', 'App crashes when opening schedule') $$,
  'C15.1 student can insert a valid support ticket'
);

-- ── Test 2: Student cannot insert a ticket for another student ───────────────
select throws_ok(
  $$ insert into public.support_tickets (student_id, subject, description)
     values ('22222222-2222-2222-2222-222222222222', 'App Crash 2', 'Another crash description') $$,
  'new row violates row-level security policy for table "support_tickets"',
  'C15.2 student cannot insert support ticket for other student'
);

-- ── Test 3: Constraint check for empty/whitespace subject/description ───────
select throws_ok(
  $$ insert into public.support_tickets (student_id, subject, description)
     values ('11111111-1111-1111-1111-111111111111', '   ', 'Valid description') $$,
  'new row for relation "support_tickets" violates check constraint "support_tickets_subject_check"',
  'C15.3 subject cannot be empty or only spaces'
);

select throws_ok(
  $$ insert into public.support_tickets (student_id, subject, description)
     values ('11111111-1111-1111-1111-111111111111', 'Valid subject', '') $$,
  'new row for relation "support_tickets" violates check constraint "support_tickets_description_check"',
  'C15.4 description cannot be empty or only spaces'
);

-- ── Test 4: Student can read their own tickets but not others'' ──────────────
-- Let student 2 insert a ticket (as service role or by temporarily acting as student 2)
select pg_temp.act_as('22222222-2222-2222-2222-222222222222');
insert into public.support_tickets (id, student_id, subject, description)
  values ('22222222-2222-2222-2222-222222222202', '22222222-2222-2222-2222-222222222222', 'Billing issue', 'I paid but status is unpaid');

select pg_temp.act_as('11111111-1111-1111-1111-111111111111');
select ok(
  (select count(*)::int from public.support_tickets) = 1,
  'C15.5 student can only see their own support tickets'
);

-- ── Test 5: Student can update their own ticket (e.g. subject) ───────────────
select lives_ok(
  $$ update public.support_tickets set subject = 'App Crash Fixed'
     where id = '11111111-1111-1111-1111-111111111101' $$,
  'C15.6 student can update their own support ticket'
);

-- ── Test 6: Student cannot update other student''s ticket ─────────────────────
update public.support_tickets set subject = 'Hacked'
  where id = '22222222-2222-2222-2222-222222222202';

-- Act as admin to verify the ticket subject was NOT changed
select pg_temp.act_as('55555555-5555-5555-5555-555555555555');
select is(
  (select subject from public.support_tickets where id = '22222222-2222-2222-2222-222222222202'),
  'Billing issue',
  'C15.7 student cannot update other student''s support ticket (subject remains unchanged)'
);

-- ── Test 7: Admin can read all tickets ───────────────────────────────────────
select pg_temp.act_as('55555555-5555-5555-5555-555555555555');
select ok(
  (select count(*)::int from public.support_tickets) = 2,
  'C15.8 admin can read all support tickets'
);

-- ── Test 8: Admin can update ticket status to RESOLVED ───────────────────────
select lives_ok(
  $$ update public.support_tickets set status = 'RESOLVED'
     where id = '11111111-1111-1111-1111-111111111101' $$,
  'C15.9 admin can update status of any support ticket to RESOLVED'
);

select * from finish();
rollback;
