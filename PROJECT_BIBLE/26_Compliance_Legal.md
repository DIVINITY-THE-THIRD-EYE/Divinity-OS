# Phase 26 — Compliance & Legal

> India-based academy → **DPDP Act 2023** is the primary regime. Sources: `app/privacy/page.tsx`, `app/terms/page.tsx`, RLS model. Many items here are `[Needs Verification]` (legal content not fully in repo).

## Privacy Policy

Page exists: `app/privacy/page.tsx`. `[Needs Verification]`: confirm it reflects actual data practices (PII collected: name, email, phone, age/gender, **health info**, emergency contact, location for check-in, payment screenshots).

## Terms

Page exists: `app/terms/page.tsx`. `[Needs Verification]`: review for membership/refund/liability terms.

## Consent Flow

Onboarding collects health + emergency data; `[Needs Verification]`: explicit consent capture/recording for sensitive (health, location) data. Location used only at check-in.

## Cookie Policy

`[Needs Verification]`: static site uses minimal cookies; document analytics cookies if a provider is added.

## DPDP (India)

Key obligations to verify: notice + consent for personal data, purpose limitation, data-principal rights (access/correction/erasure), children's data (if minors train — **parental consent** likely needed), grievance officer. **`[Needs Verification]`** — none explicitly implemented; health + minor data make this important.

## GDPR (future)

Only relevant if serving EU users. Current scope is local (Lucknow). RLS + data minimization help. `[Needs Verification]`.

## Data Retention

`[Needs Verification]`: no retention policy/automation found (e.g., how long payment screenshots, attendance, ex-member data are kept). Recommend a documented schedule + deletion process.

## Audit Trail

Partial: privileged-field + payment locks resist tampering, but **no general audit-log table**. Gap flagged in [07_Admin_Panel](07_Admin_Panel.md), [12_Security](12_Security.md).

## Compliance Checklist

- [ ] DPDP notice + consent (esp. health, location, minors) `[Needs Verification]`
- [ ] Data-principal rights process
- [ ] Retention + deletion schedule
- [ ] Privacy/terms reviewed by counsel
- [ ] Grievance officer named
- [ ] Audit logging for admin actions

## Legal Risks

Sensitive **health data** + possible **minors** + **payment data** raise the compliance bar. Treat as high-priority pre-scale. `[Needs Verification]` for legal entity, jurisdiction clauses, insurance.
