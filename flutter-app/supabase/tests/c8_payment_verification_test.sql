-- c8_payment_verification_test.sql (pgTAP)
-- Run with:  supabase test db
--
-- Verifies:
--   - 5-stage payment verification state machine
--   - Cash auto-approval by admin
--   - Security and update constraints for students and trainers
-- ─────────────────────────────────────────────────────────────────────────────

begin;
select plan(12);

-- ── Fixtures ─────────────────────────────────────────────────────────────────
insert into auth.users (id, email) values
  ('10000000-1000-1000-1000-100000000000', 'student1.c8@test.local'),
  ('20000000-2000-2000-2000-200000000000', 'student2.c8@test.local'),
  ('30000000-3000-3000-3000-300000000000', 'trainer.c8@test.local'),
  ('40000000-4000-4000-4000-400000000000', 'admin.c8@test.local');

-- Update roles
update public.users set role = 'STUDENT' where id in ('10000000-1000-1000-1000-100000000000', '20000000-2000-2000-2000-200000000000');
update public.users set role = 'TRAINER' where id = '30000000-3000-3000-3000-300000000000';
update public.users set role = 'ADMIN' where id = '40000000-4000-4000-4000-400000000000';

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

-- ── Test 1: Student UPI Submission ───────────────────────────────────────────
select pg_temp.act_as('10000000-1000-1000-1000-100000000000');

-- Student inserts their own payment (Stage 2)
select lives_ok(
  $$ insert into public.payments (student_id, amount, payment_method, status, reference_number, screenshot_url)
     values ('10000000-1000-1000-1000-100000000000', 2000.00, 'UPI', 'PENDING', '123456789012', 'http://url/image.jpg') $$,
  'C8.1 Student can insert a pending UPI payment'
);

-- Assert that user's plan_status transitions to PENDING_ADMIN
select is(
  (select plan_status from public.users where id = '10000000-1000-1000-1000-100000000000'),
  'PENDING_ADMIN'::text,
  'C8.2 User plan_status is set to PENDING_ADMIN after payment insertion'
);

-- ── Test 2: Admin Approval (Stage 3) ─────────────────────────────────────────
select pg_temp.act_as('40000000-4000-4000-4000-400000000000');

select lives_ok(
  $$ update public.payments set admin_approved = true, plan_expiration_date = '2026-07-31'::date 
     where student_id = '10000000-1000-1000-1000-100000000000' and status = 'PENDING' $$,
  'C8.3 Admin can approve the payment and set plan expiration'
);

-- Assert user plan_status is now PENDING_TRAINER
select is(
  (select plan_status from public.users where id = '10000000-1000-1000-1000-100000000000'),
  'PENDING_TRAINER'::text,
  'C8.4 User plan_status transitions to PENDING_TRAINER after admin approval'
);

-- ── Test 3: Trainer Receipt Confirmation (Stage 4 & 5) ─────────────────────────
select pg_temp.act_as('30000000-3000-3000-3000-300000000000');

select lives_ok(
  $$ update public.payments set receipt_given_by_trainer = true 
     where student_id = '10000000-1000-1000-1000-100000000000' and status = 'PENDING' $$,
  'C8.5 Trainer can confirm receipt'
);

-- Assert user plan_status is now ACTIVE and expiration_date is set
select is(
  (select plan_status from public.users where id = '10000000-1000-1000-1000-100000000000'),
  'ACTIVE'::text,
  'C8.6 User plan_status transitions to ACTIVE after trainer confirmation'
);

select is(
  (select expiration_date from public.users where id = '10000000-1000-1000-1000-100000000000'),
  '2026-07-31'::date,
  'C8.7 User expiration_date is set to plan_expiration_date'
);

-- Assert payment status is now PAID
select is(
  (select status from public.payments where student_id = '10000000-1000-1000-1000-100000000000' limit 1),
  'PAID'::text,
  'C8.8 Payment status transitions to PAID'
);

-- ── Test 4: Cash Auto-Approval by Admin (Stage 1) ────────────────────────────
select pg_temp.act_as('40000000-4000-4000-4000-400000000000');

-- Admin inserts a cash payment
select lives_ok(
  $$ insert into public.payments (student_id, amount, payment_method, status, plan_expiration_date)
     values ('20000000-2000-2000-2000-200000000000', 3000.00, 'CASH', 'PENDING', '2026-08-15'::date) $$,
  'C8.9 Admin can record a pending CASH payment'
);

-- Assert cash payment is auto-approved and student plan_status becomes PENDING_TRAINER
select is(
  (select admin_approved from public.payments where student_id = '20000000-2000-2000-2000-200000000000' limit 1),
  true,
  'C8.10 CASH payment recorded by admin is auto-approved'
);

select is(
  (select plan_status from public.users where id = '20000000-2000-2000-2000-200000000000'),
  'PENDING_TRAINER'::text,
  'C8.11 User plan_status transitions to PENDING_TRAINER after CASH payment creation'
);

-- ── Test 5: Security Lock Checks ─────────────────────────────────────────────
select pg_temp.act_as('30000000-3000-3000-3000-300000000000');

-- Trainer tries to change payment amount (should throw)
select throws_ok(
  $$ update public.payments set amount = 100.00 where student_id = '10000000-1000-1000-1000-100000000000' $$,
  '42501',
  null,
  'C8.12 Trainer cannot modify payment amount'
);

select * from finish();
rollback;
