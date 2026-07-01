-- 023_payment_notifications.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- Track C1: Automatically generate student notifications on payment events
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function public.handle_payment_notification()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  -- 1. Admin approved payment (status transition from PENDING_ADMIN to PENDING_TRAINER)
  if (old.admin_approved = false and new.admin_approved = true) 
     and new.receipt_given_by_trainer = false then
     
    insert into public.notifications (user_id, kind, title, body, metadata)
    values (
      new.student_id,
      'GENERAL',
      '💳 Payment Verified by Admin',
      'Your payment of ₹' || to_char(new.amount, 'FM99,999') || ' has been approved by the admin. Please request your trainer to confirm receipt on-site to activate your membership.',
      jsonb_build_object(
        'payment_id', new.id,
        'reference_number', new.reference_number,
        'plan_name', new.plan_name,
        'action', 'request_trainer_confirmation'
      )
    );
  end if;

  -- 2. Trainer confirmed receipt (status transition to ACTIVE / PAID)
  if (old.receipt_given_by_trainer = false and new.receipt_given_by_trainer = true) 
     and new.admin_approved = true then
     
    insert into public.notifications (user_id, kind, title, body, metadata)
    values (
      new.student_id,
      'GENERAL',
      '✨ Membership Activated',
      'Your trainer has confirmed receipt for your ' || new.plan_name || '. Your account is now ACTIVE. Enjoy your practice!',
      jsonb_build_object(
        'payment_id', new.id,
        'reference_number', new.reference_number,
        'plan_name', new.plan_name,
        'action', 'membership_active'
      )
    );
  end if;

  -- 3. Payment rejected (status transition to FAILED)
  if (old.status is distinct from new.status and new.status = 'FAILED') then
    insert into public.notifications (user_id, kind, title, body, metadata)
    values (
      new.student_id,
      'GENERAL',
      '❌ Payment Verification Failed',
      'The verification request for your payment of ' || new.plan_name || ' was rejected. Please review your reference number and upload your receipt screenshot again.',
      jsonb_build_object(
        'payment_id', new.id,
        'reference_number', new.reference_number,
        'plan_name', new.plan_name,
        'action', 'payment_rejected'
      )
    );
  end if;

  return new;
end;
$$;

drop trigger if exists payments_notification_trigger on public.payments;
create trigger payments_notification_trigger
  after update on public.payments
  for each row execute function public.handle_payment_notification();
