# Phase 27 — Business Continuity

> Most operational targets here are not encoded in the repo and are `[Needs Verification]` — this phase defines the framework and recommended defaults to confirm.

## Backup Strategy

- **DB:** Supabase managed backups (automatic). Confirm tier/frequency/PITR window `[Needs Verification]`.
- **Storage:** payment screenshots in Supabase Storage — confirm backup coverage.
- **Code:** GitHub (app + website) + GitLab (legacy archive).
- **Content:** Sanity hosted (if used) + `lib/content.ts` in git.

## Restore Procedures

`[Needs Verification]`: document the steps to (a) restore DB from a Supabase backup/PITR, (b) redeploy web on Vercel, (c) re-provision Firebase. Add to runbooks ([18_Documentation](18_Documentation.md)).

## Disaster Recovery

Multi-vendor reduces blast radius (web/data/messaging separate). Recovery = redeploy from git + restore Supabase. DR drill `[Needs Verification]`.

## Incident Severity Matrix

| Sev | Example | Target response |
|---|---|---|
| SEV1 | Data loss / auth down / payments broken | immediate `[Verify]` |
| SEV2 | Check-in or notifications failing | hours `[Verify]` |
| SEV3 | Website cosmetic / single feature | next business day |

(Proposed — confirm with owner.)

## SLA

`[Needs Verification]`: no formal SLA. Define member-facing availability expectations.

## RPO

`[Needs Verification]`: recommend ≤24h (or Supabase PITR for near-zero). Confirm.

## RTO

`[Needs Verification]`: recommend ≤4h for web (redeploy), ≤ backup-restore time for DB. Confirm.

## Failover

No active-active. Supabase/Vercel/Firebase provide their own regional resilience. Multi-region `[Needs Verification]`.

## Recovery Testing

`[Needs Verification]`: schedule periodic restore tests. (`Divinity:disaster-recovery`, `Divinity:canary-watch` skills can help.)
