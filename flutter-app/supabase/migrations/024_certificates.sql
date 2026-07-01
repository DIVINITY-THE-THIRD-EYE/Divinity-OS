-- 024_certificates.sql
-- Student completion certificates ("trust certificates").
-- Issued by trainers/admins; read by the owning student; publicly verifiable
-- by a short code (DIV-XXXX-XXXX). RLS uses the SECURITY DEFINER role helpers
-- (is_admin / is_trainer) introduced in 012/017 — never inline-subquery users.

-- ── Verification-code generator ──────────────────────────────────────────────
-- Crockford-ish alphabet (no I/O/0/1 to avoid confusion). 8 chars => 32^8 space;
-- the unique constraint guards the astronomically rare collision.
create or replace function public.gen_certificate_code()
returns text
language plpgsql
volatile
as $$
declare
  alphabet text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  p1 text := '';
  p2 text := '';
  i int;
begin
  for i in 1..4 loop
    p1 := p1 || substr(alphabet, floor(random() * length(alphabet))::int + 1, 1);
    p2 := p2 || substr(alphabet, floor(random() * length(alphabet))::int + 1, 1);
  end loop;
  return 'DIV-' || p1 || '-' || p2;
end;
$$;

-- ── Table ────────────────────────────────────────────────────────────────────
create table if not exists public.certificates (
  id          uuid primary key default gen_random_uuid(),
  student_id  uuid not null references public.users(id) on delete cascade,
  issued_by   uuid references public.users(id) on delete set null,
  code        text not null unique default public.gen_certificate_code(),
  title       text not null default 'Certificate of Completion',
  programme   text not null,
  issued_on   date not null default current_date,
  notes       text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists certificates_student_id_idx on public.certificates(student_id);
create index if not exists certificates_code_idx on public.certificates(code);

create or replace trigger certificates_updated_at
  before update on public.certificates
  for each row execute procedure public.set_updated_at();

-- Table-level privileges. The blanket grant in 012 only covered tables that
-- existed then, so tables added later must grant explicitly (RLS below still
-- governs which *rows* each role may touch).
grant select, insert, update, delete on public.certificates to authenticated, service_role;

-- ── Row-Level Security ───────────────────────────────────────────────────────
alter table public.certificates enable row level security;

-- Students may read (only) their own certificates.
create policy "students_read_own_certificates"
  on public.certificates for select
  using (auth.uid() = student_id);

-- Trainers may issue and manage certificates.
create policy "trainers_all_certificates"
  on public.certificates for all
  using (public.is_trainer(auth.uid()))
  with check (public.is_trainer(auth.uid()));

-- Admins may do everything.
create policy "admins_all_certificates"
  on public.certificates for all
  using (public.is_admin(auth.uid()))
  with check (public.is_admin(auth.uid()));
