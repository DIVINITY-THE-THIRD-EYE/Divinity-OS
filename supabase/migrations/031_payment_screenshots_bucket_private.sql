-- 031_payment_screenshots_bucket_private.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- LB-5: Switch payment_screenshots bucket from public to private.
--
-- The Flutter app now calls createSignedUrl() instead of getPublicUrl()
-- (see payment_repository.dart uploadScreenshot).  The bucket itself must
-- be marked private in Supabase Storage to complete the fix.
--
-- Supabase does not expose bucket-level public/private as SQL; it is
-- configured via the Management API or the Studio UI:
--   Storage → payment_screenshots → Settings → uncheck "Public bucket"
--
-- This migration adds a storage policy that enforces the same constraint
-- at the row level: only authenticated users who own the file path prefix
-- can read/write, plus admins can read all.
-- ─────────────────────────────────────────────────────────────────────────────

-- Authenticated users can upload to their own path prefix (userId/filename).
CREATE POLICY "payment_screenshots_upload_own"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'payment_screenshots'
    AND auth.uid()::text = (string_to_array(name, '/'))[1]
  );

-- Owners can read their own screenshots.
CREATE POLICY "payment_screenshots_read_own"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'payment_screenshots'
    AND auth.uid()::text = (string_to_array(name, '/'))[1]
  );

-- Admins can read all payment screenshots.
CREATE POLICY "payment_screenshots_read_admin"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'payment_screenshots'
    AND EXISTS (
      SELECT 1 FROM public.users u
      WHERE u.id = auth.uid() AND u.role = 'ADMIN'
    )
  );

-- Trainers can read all payment screenshots (to verify receipts).
CREATE POLICY "payment_screenshots_read_trainer"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'payment_screenshots'
    AND EXISTS (
      SELECT 1 FROM public.users u
      WHERE u.id = auth.uid() AND u.role = 'TRAINER'
    )
  );
