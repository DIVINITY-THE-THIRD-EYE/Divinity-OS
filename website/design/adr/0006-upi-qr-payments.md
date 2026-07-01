# ADR 0006 — UPI QR payments (vs Stripe/Razorpay gateway)
Status: Accepted · Date: 2026-06-26

## Context
The Membership section shows a **UPI QR** (`public/payment-qr.png`, UCO Bank) with "scan + screenshot to
confirm." No card gateway is integrated. Audience is local (Lucknow), India.

## Problem
How to accept membership/class payments with **zero fees**, minimal compliance burden, and no PCI scope?

## Alternatives considered
1. **Stripe** — excellent, but limited India domestic UPI ergonomics + per-txn fees + onboarding.
2. **Razorpay** — strong India/UPI, but adds gateway integration, KYC, and per-txn fees.
3. **Static UPI QR + manual confirmation** — chosen for v1 (zero fee, zero PCI scope).

## Decision
Keep the **UPI QR** as the primary method for the marketing site. Treat an automated gateway
(**Razorpay** preferred for India) as a **future** enhancement gated to the product/booking app, not this
static site.

## Consequences
- No payment backend, no PCI scope, no fees on the marketing site.
- Manual reconciliation (owner verifies screenshots) — acceptable at current volume.

## Risks
- Manual flow doesn't scale; no automated receipts. → Acceptable now; Razorpay ADR when booking automates.
- QR must point to the **real** account before launch. → Launch checklist (`23`), risk K5.

## Rollback strategy
Adding Razorpay later is additive (new route + button); the QR remains as a fallback. No rollback needed
for the QR approach.
