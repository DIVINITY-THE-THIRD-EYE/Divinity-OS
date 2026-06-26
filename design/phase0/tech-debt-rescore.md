# Technical-Debt Re-Score (Phase 0)

Re-scores the 16 items from `design/22-tech-debt-register.md` by **business impact · user impact · risk ·
effort · dependencies**, then sorts by a WSJF-style priority. Computed (not hand-ranked).

**Formula:** `Priority = (Business + User + Risk) / Effort` — each dimension 1–5; effort 1 (trivial) → 5
(large). Higher = sooner. `LAUNCH` = launch-blocking, owner-dependent.

| Rank | ID | Item | Biz | User | Risk | Effort | Priority | Deps | Flag |
|---|---|---|---|---|---|---|---|---|---|
| 1 | TD9 | Placeholder content (prices/phone/WA/url/IG) | 5 | 5 | 5 | 1 | **15.0** | owner input | LAUNCH |
| 2 | TD10 | UPI QR is a sample (UCO Bank) | 5 | 5 | 5 | 1 | **15.0** | owner input | LAUNCH |
| 3 | TD12 | No error monitoring (Sentry) | 3 | 2 | 3 | 1 | **8.0** | — | |
| 4 | TD15 | Gallery sources very large | 2 | 3 | 2 | 1 | **7.0** | — | |
| 5 | TD3 | No skip link | 1 | 3 | 2 | 1 | **6.0** | — | |
| 6 | TD8 | Repeated reduced-motion/in-view logic | 2 | 2 | 2 | 1 | **6.0** | — | |
| 7 | TD5 | ESLint ignored in build | 2 | 1 | 3 | 1 | **6.0** | CI setup | |
| 8 | TD1 | No rate-limit/honeypot on /api/contact | 3 | 2 | 5 | 2 | **5.0** | — | |
| 9 | TD16 | No `.env` validation | 2 | 1 | 2 | 1 | **5.0** | — | |
| 10 | TD2 | Form lacks aria-live / error assoc | 2 | 4 | 3 | 2 | **4.5** | — | |
| 11 | TD13 | No analytics/consent | 4 | 2 | 3 | 2 | **4.5** | consent UI | |
| 12 | TD4 | No security headers / CSP | 3 | 2 | 4 | 2 | **4.5** | — | |
| 13 | TD7 | No shared Button/Field/Tag atoms | 3 | 3 | 3 | 3 | **3.0** | — | |
| 14 | TD11 | No automated tests / VRT | 3 | 2 | 4 | 3 | **3.0** | CI setup | |
| 15 | TD6 | Motion easing/duration duplicated | 2 | 1 | 2 | 2 | **2.5** | tokens | |
| 16 | TD14 | Sanity Studio not wired | 2 | 1 | 1 | 2 | **2.0** | — | |

## Reading the ranking
- **TD9 / TD10 (15.0) are owner-gated, not engineering** — high impact, trivial eng effort, but *cannot
  ship without real values*. They block **launch**, not Phase-1 development.
- **High-priority cheap wins (TD12, TD15, TD3, TD8, TD5 — score ≥6, effort 1)** fold into Phase 1's
  baseline/setup with negligible cost.
- **TD7 / TD11 score lower only because effort is higher**, but TD7 (shared atoms) is a **dependency
  enabler** for several Phase-1 components — schedule it early despite the 3.0 score (dependency-aware
  override).
- Dependencies (`CI setup`, `consent UI`, `tokens`) gate TD5/TD11, TD13, TD6 respectively — sequence accordingly.

## Phase-1 debt slice (recommended)
Take in Phase 1 alongside features: **TD3, TD5, TD8, TD12, TD15, TD16** (cheap, high/again), **TD1, TD2,
TD4** (security/a11y), **TD7** (enabler), **TD13** (measurement). Defer **TD6, TD11 (deepen), TD14** to
Phase 2–3. **TD9/TD10** → pre-launch owner task.
