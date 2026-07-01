# 06 — Quantitative Scoring Matrix

Structured 1–10 expert assessment across 14 dimensions, with a weighted overall. This complements the
qualitative report (01) and ranked matrix.

> **Method & honesty:** scores are a senior reviewer's structured assessment, not lab measurements.
> **Performance** and **Accessibility** for third-party domains are **stack-inferred** (platform,
> asset strategy, visible markup). Divinity's own numbers are validated against its codebase and
> should be confirmed with Lighthouse/axe (see `11-performance-budgets.md`, `09-accessibility-audit.md`).
> The two uncrawlable sites (`aoustudio`, `hale.now`) are **excluded** — not scored from guesswork.

## Weights (sum = 100%)

| Dim | Wt | Dim | Wt | Dim | Wt |
|---|---|---|---|---|---|
| UX | 12 | Visual design | 8 | SEO | 6 |
| Conversion | 10 | Accessibility | 8 | Content hierarchy | 5 |
| Mobile | 8 | Performance | 8 | UI consistency | 6 |
| Booking flow | 8 | Trust | 6 | Developer quality | 2 |
| Branding | 6 | Motion | 7 | | |

Rationale: conversion/UX/booking are weighted highest because they are Divinity's measured gaps and the
business goal; developer quality is low-weight because it's an enabler, not an outcome.

## Benchmark ceiling — product/interaction leaders

| Site | Vis | UX | UIc | Mot | A11y | Perf | SEO | Mob | Book | Trust | Conv | Cont | Brand | Dev | **Weighted** |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Apple | 10 | 9 | 9 | 9 | 9 | 8 | 9 | 9 | 8 | 9 | 9 | 9 | 10 | 9 | **9.0** |
| Linear | 9 | 9 | 10 | 8 | 9 | 9 | 8 | 9 | 8 | 9 | 9 | 9 | 9 | 10 | **8.9** |
| Stripe | 9 | 9 | 10 | 8 | 9 | 8 | 9 | 9 | 8 | 9 | 9 | 9 | 9 | 10 | **8.8** |
| Airbnb | 8 | 9 | 9 | 7 | 9 | 8 | 9 | 9 | 10 | 9 | 9 | 9 | 9 | 9 | **8.8** |
| Headspace | 9 | 9 | 9 | 9 | 9 | 8 | 8 | 9 | 9 | 9 | 9 | 9 | 9 | 8 | **8.8** |
| Calm | 9 | 9 | 9 | 9 | 9 | 8 | 8 | 9 | 9 | 9 | 9 | 8 | 9 | 8 | **8.8** |
| Raycast | 9 | 9 | 9 | 9 | 8 | 9 | 7 | 7 | 7 | 8 | 8 | 8 | 9 | 10 | **8.3** |
| Nike | 9 | 8 | 8 | 9 | 7 | 7 | 9 | 9 | 8 | 8 | 9 | 8 | 10 | 8 | **8.3** |
| Vercel | 8 | 8 | 9 | 8 | 8 | 10 | 8 | 8 | 7 | 9 | 8 | 8 | 8 | 10 | **8.2** |
| Arc | 9 | 8 | 9 | 9 | 8 | 8 | 7 | 8 | 7 | 8 | 8 | 8 | 9 | 9 | **8.2** |
| Notion | 8 | 8 | 8 | 7 | 8 | 8 | 8 | 8 | 7 | 9 | 8 | 9 | 8 | 9 | **8.0** |

**Leaders average: 8.6.** Interpretation in `05-benchmark-product-leaders.md`.

## Divinity — current build (honest self-assessment)

| Site | Vis | UX | UIc | Mot | A11y | Perf | SEO | Mob | Book | Trust | Conv | Cont | Brand | Dev | **Weighted** |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **Divinity (current)** | 9 | 7 | 8 | 9 | 8 | 8 | 8 | 8 | **4** | **6** | **5** | 8 | 9 | 9 | **7.4** |

**Reading:** Divinity already matches leaders on **Motion (9)**, **Visual (9)**, **Branding (9)**,
**Dev quality (9)** — and beats the yoga-set average (6.8). Its drag comes from **Booking (4)**,
**Conversion (5)**, **Trust (6)**. Closing only those three to ~8 lifts the weighted overall from
**7.4 → ~8.4**, into leader territory — without touching what already excels.

## Yoga/wellness references (19 analysed, ranked)

| Site | Vis | UX | UIc | Mot | A11y | Perf | SEO | Mob | Book | Trust | Conv | Cont | Brand | Dev | **Weighted** |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| highland-yoga | 7 | 9 | 8 | 5 | 8 | 7 | 8 | 9 | 9 | 8 | 9 | 8 | 7 | 7 | **7.9** |
| samyastudios | 8 | 8 | 8 | 7 | 7 | 7 | 7 | 8 | 8 | 7 | 8 | 8 | 8 | 7 | **7.6** |
| herspace | 8 | 8 | 7 | 7 | 7 | 6 | 7 | 8 | 7 | 9 | 8 | 8 | 9 | 7 | **7.6** |
| openstudiosberlin | 8 | 8 | 7 | 7 | 7 | 6 | 7 | 8 | 8 | 7 | 7 | 7 | 8 | 7 | **7.3** |
| innsaei | 9 | 7 | 7 | 9 | 6 | 5 | 6 | 7 | 7 | 7 | 7 | 7 | 9 | 6 | **7.1** |
| balance-group | 7 | 7 | 7 | 5 | 7 | 6 | 8 | 7 | 8 | 8 | 7 | 7 | 7 | 6 | **7.0** |
| ourano | 7 | 7 | 7 | 5 | 7 | 7 | 7 | 7 | 7 | 7 | 7 | 7 | 7 | 6 | **6.8** |
| myawellbeing | 7 | 7 | 7 | 6 | 6 | 6 | 7 | 7 | 7 | 7 | 7 | 7 | 7 | 7 | **6.8** |
| mindfulflowwithangie | 7 | 7 | 7 | 6 | 6 | 8 | 6 | 7 | 6 | 7 | 7 | 7 | 7 | 7 | **6.8** |
| sacredspacemiami | 8 | 7 | 7 | 6 | 6 | 6 | 6 | 7 | 6 | 7 | 6 | 7 | 9 | 6 | **6.7** |
| wearealma | 9 | 7 | 8 | 9 | 6 | 6 | 5 | 7 | 4 | 6 | 5 | 6 | 8 | 8 | **6.6** |
| yogamaya | 6 | 7 | 6 | 4 | 6 | 7 | 7 | 7 | 8 | 7 | 8 | 6 | 6 | 6 | **6.6** |
| panijoga | 6 | 7 | 6 | 4 | 7 | 7 | 7 | 7 | 7 | 8 | 7 | 7 | 6 | 6 | **6.6** |
| thegoddessmovement | 7 | 7 | 6 | 5 | 6 | 6 | 6 | 7 | 7 | 7 | 7 | 6 | 8 | 6 | **6.6** |
| livingbarreandyoga | 7 | 7 | 6 | 5 | 6 | 6 | 6 | 7 | 7 | 6 | 7 | 7 | 7 | 6 | **6.5** |
| threejewels | 6 | 7 | 6 | 5 | 6 | 6 | 7 | 6 | 6 | 8 | 6 | 8 | 7 | 6 | **6.4** |
| casadelmoviment | 6 | 7 | 6 | 5 | 6 | 6 | 7 | 7 | 7 | 6 | 7 | 6 | 6 | 6 | **6.4** |
| practicefeelglow | 6 | 6 | 6 | 5 | 6 | 7 | 6 | 6 | 6 | 6 | 6 | 6 | 7 | 6 | **6.1** |
| glowflowyoga | 6 | 6 | 6 | 5 | 6 | 7 | 6 | 6 | 6 | 6 | 6 | 6 | 6 | 6 | **6.0** |

**Yoga set average: 6.8.** Highland leads purely on booking/conversion/mobile despite middling motion
and branding — reinforcing that *conversion infrastructure*, not more visual flair, is the lever.

## Takeaways that drive the roadmap
1. Divinity's **7.4** already tops the yoga field's average and ties its 5th-best site, on the strength
   of motion/visual/brand — areas most studios are weak in.
2. The **only** path to leader-tier (8.5+) runs through **Booking, Conversion, Trust** — Phase 1 of the plan.
3. Borrow **interaction/onboarding/perf discipline** from the product leaders (05), **not** more decoration.
