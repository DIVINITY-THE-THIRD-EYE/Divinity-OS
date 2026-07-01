-- 030_library_books_rls_fix.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- LB-9 fix: The student UPDATE policy in migration 013 allowed any
-- authenticated user to update any library_books row. Replace it with a
-- policy scoped to the student's own borrow/request records only.
-- ─────────────────────────────────────────────────────────────────────────────

-- Drop the over-broad policy from migration 013.
DROP POLICY IF EXISTS "library_books_update_student" ON public.library_books;

-- Students may only update rows where they are the borrower or requester.
-- Admins are already covered by the "library_books_all_admin" FOR ALL policy.
CREATE POLICY "library_books_update_own" ON public.library_books
  FOR UPDATE
  USING (
    borrower_student_id  = auth.uid()
    OR requested_student_id = auth.uid()
  )
  WITH CHECK (
    borrower_student_id  = auth.uid()
    OR requested_student_id = auth.uid()
  );
