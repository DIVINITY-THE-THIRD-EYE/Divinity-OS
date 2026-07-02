-- 037_remove_razorpay.sql
-- Razorpay was never wired to a real payment gateway; manual UPI QR +
-- screenshot + staff verification is the only payment method going forward.
-- Drop the unused columns and reject the RAZORPAY method going forward.

alter table public.payments drop column if exists razorpay_order_id;
alter table public.payments drop column if exists razorpay_payment_id;

update public.payments set payment_method = 'UPI' where payment_method = 'RAZORPAY';

alter table public.payments
  add constraint payments_payment_method_check
  check (payment_method in ('CASH', 'UPI', 'BANK_TRANSFER'));

comment on column public.payments.payment_method is 'CASH | UPI | BANK_TRANSFER';
