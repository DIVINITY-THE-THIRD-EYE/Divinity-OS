-- ── Next.js Compatibility Migration ───────────────────────────────────────────

-- 1. Add compatibility columns to public.batches
ALTER TABLE public.batches ADD COLUMN IF NOT EXISTS end_time text;
ALTER TABLE public.batches ADD COLUMN IF NOT EXISTS created_by_id uuid REFERENCES public.users(id) ON DELETE SET NULL;

-- 2. Add compatibility columns to public.payments
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS plan_name text;
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS admin_approved boolean DEFAULT false;
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS receipt_given_by_trainer boolean DEFAULT false;

-- 3. Add compatibility columns to public.therapeutic_logs
ALTER TABLE public.therapeutic_logs ADD COLUMN IF NOT EXISTS trainer_comment text;
ALTER TABLE public.therapeutic_logs ADD COLUMN IF NOT EXISTS comment_timestamp timestamptz;

-- 4. Create library_books table
CREATE TABLE IF NOT EXISTS public.library_books (
  id                   uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  book_title           text NOT NULL,
  author               text NOT NULL,
  description          text,
  status               text NOT NULL DEFAULT 'AVAILABLE' CHECK (status IN ('AVAILABLE', 'REQUESTED', 'BORROWED')),
  borrower_student_id  uuid REFERENCES public.users(id) ON DELETE SET NULL,
  requested_student_id uuid REFERENCES public.users(id) ON DELETE SET NULL,
  borrowed_date        timestamptz
);

-- Enable RLS on library_books
ALTER TABLE public.library_books ENABLE ROW LEVEL SECURITY;

-- Select policy: all authenticated users
CREATE POLICY "library_books_select" ON public.library_books
  FOR SELECT USING (auth.uid() IS NOT NULL);

-- All policy: admins only
CREATE POLICY "library_books_all_admin" ON public.library_books
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.users u
      WHERE u.id = auth.uid() AND u.role = 'ADMIN'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.users u
      WHERE u.id = auth.uid() AND u.role = 'ADMIN'
    )
  );

-- Update policy: students can request/return books
CREATE POLICY "library_books_update_student" ON public.library_books
  FOR UPDATE USING (
    auth.uid() IS NOT NULL
  );
