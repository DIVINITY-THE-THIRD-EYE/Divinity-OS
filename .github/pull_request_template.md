## Summary
<!-- What does this PR do? One paragraph is enough. -->

## Which part(s) does this touch?
- [ ] `flutter-app/` (mobile app)
- [ ] `website/` (Next.js)
- [ ] `supabase/` (migrations / RLS / Edge Functions)
- [ ] `.github/` (CI/CD)
- [ ] `docs/`

## Type of Change
- [ ] 🐛 Bug fix
- [ ] ✨ New feature
- [ ] ♻️ Refactoring (no behavior change)
- [ ] 🗄️ Database migration
- [ ] 🧪 Tests only
- [ ] 📝 Content update
- [ ] 🎨 Design / styling
- [ ] 🔧 CI/CD
- [ ] ⬆️ Dependency update

## Related Issues
Closes #<!-- issue number -->

## Testing
<!-- Check only what applies to the part(s) this PR touches. -->
- [ ] `flutter analyze` passes with 0 issues (`flutter-app/`)
- [ ] `flutter test` passes (`flutter-app/`)
- [ ] `npm run lint` / `npx tsc --noEmit` / `npm run build` pass (`website/`)
- [ ] `npm test` passes — Vitest (`website/`)
- [ ] Database migration applied locally via `supabase db reset` (`supabase/`)
- [ ] pgTAP tests pass — `supabase test db` (`supabase/`)
- [ ] Manually tested on device/emulator or in browser

## Database Changes
<!-- If this PR adds migrations, list them and note any irreversible changes. -->
| Migration | Description | Reversible? |
|---|---|---|
| — | — | — |

## Security Checklist
- [ ] No secrets or credentials committed
- [ ] RLS policies added/verified for new tables
- [ ] New RPCs/Edge Functions have explicit role checks
- [ ] Image uploads validated (MIME type + size)
- [ ] No user-controlled data used in SQL queries without parameterization

## Screenshots / Screen Recording
<!-- For UI changes, paste before/after screenshots or a short recording. -->

## Reviewer Notes
<!-- Anything specific you'd like reviewers to focus on? -->
