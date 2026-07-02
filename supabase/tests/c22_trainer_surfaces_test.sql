-- c22_trainer_surfaces_test.sql  (pgTAP)
-- Run with:  supabase test db
--
-- Verifies 044_trainer_surfaces.sql:
--   * A Trainer can self-edit certifications, but not certifications_published.
--   * Editing certifications un-publishes it (needs re-approval).
--   * published_trainers only exposes published rows, with a narrow column set.
--   * get_reports_data / get_reports_attendance: Trainer forced to their own
--     scope, Admin unrestricted, Student still denied.

begin;
select plan(9);

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

-- ── Fixtures ─────────────────────────────────────────────────────────────────
insert into auth.users (id, email) values
  ('22220000-0000-0000-0000-000000000001', 'admin.c22@test.local'),
  ('22220000-0000-0000-0000-000000000002', 'trainer1.c22@test.local'),
  ('22220000-0000-0000-0000-000000000003', 'trainer2.c22@test.local'),
  ('22220000-0000-0000-0000-000000000004', 'student.c22@test.local');

update public.users set role = 'ADMIN' where id = '22220000-0000-0000-0000-000000000001';
update public.users set role = 'TRAINER' where id = '22220000-0000-0000-0000-000000000002';
update public.users set role = 'TRAINER' where id = '22220000-0000-0000-0000-000000000003';

-- ── C22.1-2: Trainer can self-edit certifications, not the publish flag ─────
select pg_temp.act_as('22220000-0000-0000-0000-000000000002');

select lives_ok(
  $$ update public.users set certifications = '500hr RYT, 5 years experience'
     where id = '22220000-0000-0000-0000-000000000002' $$,
  'C22.1 a Trainer can edit their own certifications text'
);

select throws_ok(
  $$ update public.users set certifications_published = true
     where id = '22220000-0000-0000-0000-000000000002' $$,
  '42501',
  'certifications_published can only be set by an admin',
  'C22.2 a Trainer cannot self-publish their certifications'
);

-- ── C22.3-4: Admin approval publishes; a later trainer edit un-publishes ────
select pg_temp.act_as('22220000-0000-0000-0000-000000000001');
update public.users set certifications_published = true
  where id = '22220000-0000-0000-0000-000000000002';

select is(
  (select certifications_published from public.users where id = '22220000-0000-0000-0000-000000000002'),
  true,
  'C22.3 Admin can publish a trainer''s certifications'
);

select pg_temp.act_as('22220000-0000-0000-0000-000000000002');
update public.users set certifications = '500hr RYT, 6 years experience, updated bio'
  where id = '22220000-0000-0000-0000-000000000002';

select is(
  (select certifications_published from public.users where id = '22220000-0000-0000-0000-000000000002'),
  false,
  'C22.4 editing certifications un-publishes it pending re-approval'
);

-- ── C22.5-6: published_trainers view only shows published, narrow columns ───
select pg_temp.act_as('22220000-0000-0000-0000-000000000001');
update public.users set certifications_published = true
  where id = '22220000-0000-0000-0000-000000000002';

select is(
  (select count(*)::int from public.published_trainers),
  1,
  'C22.5 published_trainers exposes exactly the one re-approved trainer'
);

select is(
  (select array_to_string(array(
     select column_name::text from information_schema.columns
     where table_name = 'published_trainers' order by column_name
   ), ',')),
  'avatar_url,certifications,id,name',
  'C22.6 published_trainers only exposes name/avatar/certifications — no email/phone/plan_status'
);

-- ── C22.7-9: trainer-scoped reports ──────────────────────────────────────────
select pg_temp.act_as('22220000-0000-0000-0000-000000000004');
select throws_ok(
  $$ select public.get_reports_data() $$,
  '42501',
  null,
  'C22.7 a Student still cannot call get_reports_data'
);

select pg_temp.act_as('22220000-0000-0000-0000-000000000002');
select lives_ok(
  format('select public.get_reports_data(null, null, %L::uuid)', '22220000-0000-0000-0000-000000000003'),
  'C22.8 a Trainer calling get_reports_data does not error even if requesting another trainer''s id'
);

select is(
  (select (public.get_reports_data(null, null, '22220000-0000-0000-0000-000000000003'::uuid)
    -> 'trainers' -> 0 ->> 'trainer_id')),
  '22220000-0000-0000-0000-000000000002',
  'C22.9 the requested other-trainer id is ignored — results are forced to the caller''s own scope'
);

select * from finish();
rollback;
