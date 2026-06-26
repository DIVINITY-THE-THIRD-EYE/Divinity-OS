# 24 — Success Metrics (6-month targets)

Measurable targets to evaluate the upgrade, six months post-launch. Baselines must be captured at launch
(many are currently **unmeasured** — instrument first, `16`). Targets are directional for a single-studio
site and should be re-based once real baseline data exists.

## North-star
**Qualified enquiries per month** (contact + WhatsApp from intent), and **trial→member conversion**.

## Conversion
| Metric | Baseline | 6-mo target | Source |
|---|---|---|---|
| Booking CTA CTR (`cta_book`/sessions) | n/a (new) | ≥ 8% | GA4 (`16`) |
| Enquiry rate (contact+WhatsApp / sessions) | unmeasured | ≥ 3% | GA4 |
| Trial → member conversion | manual/unknown | ≥ 30% | owner CRM + tags |
| Newsletter signup rate (/sessions) | 0 (none today) | ≥ 2% | Brevo + GA4 |
| Plan-calculator completion | unmeasured | ≥ 40% of starters | GA4 |

## Engagement
| Metric | Baseline | 6-mo target |
|---|---|---|
| Avg engaged session duration | unmeasured | ≥ 90 s |
| Scroll depth ≥ 50% | unmeasured | ≥ 55% of sessions |
| Returning visitor rate | unmeasured | ≥ 25% |
| Mobile engaged sessions | unmeasured | ≥ 60% of total (mobile-led audience) |
| Bounce / single-page exits | unmeasured | ≤ 45% |

## Acquisition (SEO)
| Metric | Baseline | 6-mo target |
|---|---|---|
| Organic sessions / mo | baseline at launch | +50% vs launch month |
| Ranking for "yoga Lucknow" + long-tail | baseline | top-10 for ≥ 3 priority terms |
| Indexed pages / rich results | current | Offer/FAQ/Course rich results valid |

## Quality (technical)
| Metric | Target |
|---|---|
| Lighthouse Perf / A11y / SEO / BP | ≥ 95 / ≥ 95 / 100 / ≥ 95 |
| Core Web Vitals (field, GSC) | LCP < 2.0 s · CLS < 0.05 · INP < 150 ms — "good" on ≥ 90% of visits |
| Accessibility | WCAG 2.2 AA, 0 axe criticals; verified keyboard + SR |
| Error rate (Sentry) | < 0.5% of sessions with a handled error; 0 unhandled route errors |
| Uptime | ≥ 99.9% (Vercel) |

## Scoring (dossier `06`)
| Metric | Now | Target |
|---|---|---|
| Divinity weighted score | 7.4 | **≥ 8.4** (leader tier) after Booking/Conversion/Trust upgrades |

## Review cadence
- **Weekly** during rollout: funnels + CWV field data + error rate.
- **Monthly** thereafter: conversion + SEO + engagement vs targets; feed learnings into A/B backlog (`12 §7`).
- **At 6 months:** full readout vs this table; re-base targets; decide on Phase 4 / future-product investment.

> Measurement honesty: most baselines are **0/unmeasured today** because no analytics exist yet. Phase 1
> ships instrumentation (`16`) so these become real numbers rather than guesses.
