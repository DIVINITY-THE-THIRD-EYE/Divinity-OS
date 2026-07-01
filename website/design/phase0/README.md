# Phase 0 — Engineering Baseline

Freeze the app, establish measurable baselines, and make every future change objectively verifiable.
**No user-facing features added.** No app code, `package.json`, or dependencies changed.

> **Status: Phase 0 artifacts complete.** Two items need a live tool run before declaring the baseline
> fully "green" (no headless browser/Chrome bridge in this session — not faked): **Lighthouse** scores
> and the **axe** automated pass. Commands are in the relevant docs.

## Artifacts
| Deliverable | Doc |
|---|---|
| Engineering baseline | [`../../BASELINE.md`](../../BASELINE.md) (repo root) |
| Architecture snapshot (8 diagrams) | [architecture-diagrams.md](architecture-diagrams.md) |
| Quality gates (CI) | [quality-gates.md](quality-gates.md) + [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml) |
| Performance baseline | [performance-baseline.md](performance-baseline.md) |
| Accessibility baseline | [accessibility-baseline.md](accessibility-baseline.md) |
| SEO baseline | [seo-baseline.md](seo-baseline.md) |
| Analytics verification | [analytics-verification.md](analytics-verification.md) |
| Component freeze | [component-freeze.md](component-freeze.md) |
| Design-token freeze | [design-token-freeze.md](design-token-freeze.md) + [tokens.json](tokens.json) (v1.0.0) |
| Motion inventory | [motion-inventory.md](motion-inventory.md) |
| Tech-debt re-score (computed/sorted) | [tech-debt-rescore.md](tech-debt-rescore.md) |
| Release strategy | [release-strategy.md](release-strategy.md) |

## Real baseline highlights (captured 2026-06-26)
- Node **v24.15.0** (⚠️ pin 20 LTS for prod), npm **11.12.1**, **not a git repo yet**.
- Lockfile SHA-256 `a6dc2477…e5e3c`; 110 packages installed.
- First-Load JS `/` = **198 kB** (budget ≤210 kB); shared 87.3 kB.
- 24 components frozen (tags in component-freeze); 22 animations inventoried (all reduced-motion safe).
- Tokens exported & versioned **v1.0.0**.

## Definition of done (gate to Phase 1)
- [x] Baseline, architecture, component/motion/token, tech-debt, release artifacts written.
- [x] CI gate scaffold committed (`ci.yml`) + activation steps documented.
- [ ] `git init` + push; branch protection on (release-strategy step 0).
- [ ] Lighthouse desktop+mobile captured → `performance-baseline.md` + `reports/`.
- [ ] axe automated pass captured → `accessibility-baseline.md` + `reports/`.
- [ ] CI devDeps + scripts added; gates passing on a first PR.

> When the unchecked items are done, the baseline is "green" and **Phase 1 (Conversion & Trust)** begins
> under the final rule: every merge improves UX/a11y/perf, preserves architecture, has rollback + tests +
> docs + analytics, and carries an ADR if a decision changes.
