# ADR 0013 — Staging vs Verified Content Policy
Status: Accepted · Date: 2026-07-01

## Context
To complete the public marketing website and ensure proper layout rendering, empty sections (testimonials, blog, and events) needed to be populated. This allows Next.js static site generation (SSG) to pre-render dynamic paths (e.g. `/blog/[slug]`, `/events/[slug]`) during the production build.

## Problem
Inventing or fabricating real-world business facts, customer testimonials, credentials, or events violates operational integrity and results in false public claims.

## Alternatives considered
1. **Keep arrays empty**: Keeps pages clean of fake claims but leaves empty "Coming Soon" sections, and prevents Next.js from pre-rendering dynamic slugs during build.
2. **Fabricate realistic names & experiences**: Creates a complete visual layout but introduces false business facts.
3. **Use clearly-marked Staging Content**: Populate the local models with high-quality staging entries that are explicitly prefixed with `[STAGING CONTENT]` and clearly explain they are placeholders. This maintains the premium layout while making it obvious the content is temporary.

## Decision
Adopt Alternative 3. All unverified content in `lib/content.ts` must be clearly marked as `[STAGING CONTENT]` and `Staging Member`. Verified content (such as the founder Sachin Rajvanshi's bio and the Lucknow studio address) remains untouched. 

Sanity CMS is structured as the override layer. When configured, CMS entries will override local staging content without code modifications.

## Consequences
- 100% stable static site generation (SSG) with pre-rendered paths.
- No fabricated business facts or testimonials are published.
- Transparent separation of verified data from temporary placeholders.

## Risks
- Placeholders might leak to production if the CMS is not populated. → The `[STAGING CONTENT]` prefix serves as an obvious visual reminder on the staging build.
