# 22 — Technical Debt Register

Each: **Issue · Impact · Risk · Proposed solution · Effort · Target milestone.** Grounded in the current
codebase. Severity: 🔴 high · 🟡 med · 🟢 low.

| ID | Issue | Impact | Risk | Solution | Effort | Target |
|---|---|---|---|---|---|---|
| TD1 🔴 | No rate-limit/honeypot on `/api/contact` | Spam, abuse, Brevo quota burn | Med–High | IP token-bucket + honeypot + origin check (`21 §5`) | 0.5d | Phase 1 |
| TD2 🟡 | Form lacks `aria-live`/field error association | A11y (4.1.3/3.3.1) | Med | Add live region + `aria-invalid`/`describedby` (R9) | 0.5d | Phase 1 |
| TD3 🟡 | No skip link | A11y (2.4.1) | Low | Visually-hidden skip-to-content in layout | 0.1d | Phase 1 |
| TD4 🟡 | No security headers / CSP | XSS/clickjacking hardening missing | Med | Next `headers()` / Vercel config (`21 §6`) | 0.5d | Phase 1 |
| TD5 🟡 | ESLint `ignoreDuringBuilds: true` | Lint issues can slip in | Low–Med | Run ESLint/Biome in **CI** (not build) so build stays fast but quality gated | 0.3d | Phase 1 |
| TD6 🟡 | Motion easing/duration duplicated per component | Inconsistency, maintenance | Low | Tokenise (`08 §11`), adopt incrementally | 0.5d | Phase 2–3 |
| TD7 🟡 | No shared `Button`/`Field`/`Tag` atoms | Divergent styles/a11y across forms & CTAs | Med | Extract atoms; refactor Contact to use them; reuse in new comps | 1d | Phase 1–2 |
| TD8 🟡 | Repeated reduced-motion/in-view logic | Duplication | Low | `useReducedMotion` + `useInView` hooks | 0.3d | Phase 2 |
| TD9 🟢 | Placeholder content (prices, phone, WhatsApp `919000000000`, `site.url`, instagram) | Wrong info if launched as-is | High if shipped | Owner provides real values; pre-launch checklist (`23`) | — | Pre-launch |
| TD10 🟢 | UPI QR is a sample (UCO Bank) | Payments to wrong account | High if shipped | Replace with real QR; verify (`23`, K5) | — | Pre-launch |
| TD11 🟢 | No automated tests (unit/e2e/VRT) | Regressions undetected | Med | Add Playwright (VRT `20`) + Vitest smoke + Lighthouse CI | 1d | Phase 1 (scaffold) |
| TD12 🟢 | No error monitoring | Blind to runtime/route errors | Med | Sentry/GlitchTip free (`12 §8`) | 0.3d | Phase 1 |
| TD13 🟢 | No analytics/consent | Can't measure; compliance gap | Med | `track()` + GA4/GTM gated by consent (`16`,`21`) | 0.5d | Phase 1 |
| TD14 🟢 | Sanity schemas exist but Studio not wired; schedule/settings schemas unused | Owner can't self-edit yet | Low | Wire Studio + register schemas when desired (ADR-0004) | 0.5d | Phase 3 (optional) |
| TD15 🟢 | Gallery sources very large (up to 6000px) | Over-fetch if `sizes` missing | Low | Enforce `sizes`; lightbox full-res on open only (`11`) | 0.2d | Phase 2 |
| TD16 🟢 | No `.env` validation | Misconfig fails silently | Low | Validate required envs at boot (zod) for prod | 0.2d | Phase 1 |

## Servicing approach
- **Phase 1 absorbs the security/a11y/measurement debt** (TD1–5, TD11–13, TD16) alongside the conversion
  features — these are cheap and de-risk everything after.
- **Content/QR placeholders (TD9–10) are launch-blocking** and need the owner, not code.
- Track each as a GitHub issue; close with the PR that resolves it; review this register each phase.
