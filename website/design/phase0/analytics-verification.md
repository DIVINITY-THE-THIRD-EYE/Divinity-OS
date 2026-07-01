# Analytics Verification (Phase 0)

Verify the measurement foundation **before** any event is added (Phase 1 ships instrumentation).

## Current state (honest)
- **Provider:** none installed. No GA4, no GTM, no PostHog in the codebase today.
- **Consent:** none (no cookie/consent banner).
- **Events:** none.
- Implication: all baselines in `design/24-success-metrics.md` are **0 / unmeasured** until this is set up.

## Decisions to confirm before instrumentation
| Item | Decision | Notes |
|---|---|---|
| Provider | **GA4 + GTM** (free); optional **PostHog** (free) for funnels; **Umami** (FOSS) if cookieless preferred | `design/16` |
| Consent | Consent banner gating analytics; honour DNT/GPC; opt-out | required (`21 §10`) |
| Privacy | Privacy policy published; no PII in events; IP anonymisation | `21` |
| Naming convention | `snake_case`, `object_action`; fixed enums; no free-text props | `design/16` |
| Test environment | Use GA4 **DebugView** + a non-prod stream/ID; `track()` no-ops in dev | — |
| Loading | GTM loads **after** idle/interaction (perf budget) | `11 §3` |

## Pre-instrumentation checklist
- [ ] GA4 property + GTM container created; **separate test stream** for staging/preview.
- [ ] Consent banner chosen (free, e.g. a minimal self-built or Klaro FOSS) and wired to gate tags.
- [ ] Privacy policy + cookie notice drafted (`19` tone) and linked in footer.
- [ ] `lib/track.ts` contract agreed: typed event union (prevents typos), no-op without consent/in dev.
- [ ] Event taxonomy (`design/16`) reviewed; funnels defined in GA4/PostHog.
- [ ] Verify a test event end-to-end in DebugView before shipping real events.

## Non-regression rule
Once live: events must follow the taxonomy; no PII; consent respected. New features that add events must
register them in `design/16` (per the "updates analytics where applicable" final rule).
