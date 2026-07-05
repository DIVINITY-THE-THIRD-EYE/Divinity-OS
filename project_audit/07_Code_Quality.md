# 07 — Code Quality

## Naming & structure

Both surfaces follow a clear, consistent feature-first structure: Flutter uses `lib/features/<feature>/{data,domain,presentation}/`, the website uses Next.js App Router conventions (`app/<route>/page.tsx`) plus a flat `lib/` for shared logic. No structural inconsistency was found across the 22 Flutter feature folders or the website's route tree.

## Consistency

- **Flutter:** the repository-interface + Supabase-implementation pattern (`abstract interface class XRepository` + `class SupabaseXRepository implements XRepository`) is applied uniformly across all 24 repository implementations — this is what makes the codebase testable (mocktail is a dev dependency, used for exactly this).
- **Supabase migrations:** every table gets a `set_updated_at()` trigger, every RLS-guarded table uses the shared `is_admin()`/`is_trainer()` helpers rather than ad hoc inline checks — a real, maintained convention, not just an initial pattern that later migrations abandoned.
- **Website:** the `fetchOrFallback<T>()` pattern in `lib/sanity.ts` is applied consistently everywhere content could come from Sanity, so every content-consuming page degrades the same way if the CMS is unreachable or unconfigured.

## Dead code & duplication

- **Flutter:** one repo-wide TODO (`lib/services/fcm_service.dart` — in-app notification banner). `feedback` and `support` features each have two repository files (an abstract interface + a `supabase_*` implementation) where most other features only need one — likely just an earlier naming convention that wasn't retrofitted, not a functional duplication. Low priority to unify.
- **Website:** no TODOs, no unused components (all 41 components in `website/components/` are referenced), no duplicated logic found.
- **Supabase:** no revert migrations, no contradictory later migrations — the 45-file history reads as a clean, linear progression with no "fix the fix" churn.

## Magic numbers / hardcoded values

- `website/app/api/contact/route.ts:78-81` hardcodes fallback email addresses (`hello@staging.divinitytte.com`, etc.) when `BREVO_TO_EMAIL`/`BREVO_FROM_EMAIL` env vars are unset — reasonable as a documented staging fallback, but worth confirming these are never accidentally live in production (should always be overridden by real env vars there).
- Leave cap default of `4` appears both as a literal in `process_leave_request()` (`coalesce(v_cap, 4)`, migration 039) and is documented in the migration's own header comment — acceptable since the per-plan override (`plans.max_leave_days_per_month`) is the actual governing value in practice; the `4` is only a fallback for students with no plan.

## Documentation

- Migrations are unusually well-commented for a project this size — nearly every non-trivial migration includes a header block explaining the "why," not just the "what" (e.g. `009_lock_privileged_fields.sql`'s full vulnerability writeup, `031`'s explicit admission that the bucket-privacy fix is incomplete without a manual dashboard step, `039`'s documented "simplification" for advance-notice timing).
- In-repo `docs/PROJECT_BIBLE/` (44 files) is comprehensive but has known internal contradictions on specific counts/rules (see [03_Feature_Status.md](03_Feature_Status.md) for the doc-authority order) — this audit does not attempt to reconcile every PROJECT_BIBLE contradiction; that was already catalogued in a prior session's memory and is unchanged.

## Maintainability score: 8/10

**Justification:** the consistent architectural patterns (repository interfaces, AsyncNotifier, RLS-helper-function reuse, migration-header documentation) mean a new engineer can predict where to find things and how a new feature should be structured, which is the single biggest maintainability lever in a codebase this size. Points held back for: the PROJECT_BIBLE doc-contradiction backlog (not this session's code, but it actively confuses anyone who reads docs before code), and the one process gap (storage bucket privacy) that isn't visible from reading the code alone — a new engineer could easily assume migration 031 fully solved the problem it's named after.
