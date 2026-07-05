# Next.js 15 Migration Report — PR #23

Tests PR #23 (`chore(deps): bump next from 14.2.35 to 15.5.18 in /website`) directly, on its own branch, rather than trusting the CI check summary alone.

## What was run

Checked out PR #23's branch locally (`git fetch origin pull/23/head`) and ran the full gate suite plus Playwright, which this project's CI doesn't even run yet:

| Step | Result |
|---|---|
| `npm install` | Succeeds. Still 10 vulnerabilities (1 critical, 4 high, 5 moderate) — Next 15 alone doesn't touch the `vite`/`vitest`/`glob`/`esbuild` chain (that's PR #22's job). |
| `npm run lint` (ESLint) | **Clean.** One informational deprecation notice: `next lint` itself will be removed in Next.js 16 (separate from this PR, a future migration item). |
| `npx tsc --noEmit` | **Clean.** No standalone type errors. |
| `npm test` (Vitest) | **66/66 pass.** Unaffected — unit tests don't exercise the App Router's build-time page-type validation. |
| `npm run build` | **FAILS.** Real, reproducible break — see below. |
| `npm run test:e2e` (Playwright) | **Cannot start.** Its `webServer` config runs `next build && next start`; since the build fails, Playwright never gets past startup. This is not a Playwright-specific issue — it's downstream of the same build failure. |

## The actual breaking change

Next.js 15 made route `params` (and `searchParams`, `cookies()`, `headers()`, `draftMode()`) **asynchronous** — they're now `Promise`s that must be awaited, instead of plain synchronous objects (this is Next's documented "Async Request APIs" change, confirmed against the official Next.js 15 upgrade guide, not assumed). The build fails at the type-checking stage:

```
app/blog/[slug]/page.tsx
Type error: Type '{ params: { slug: string; }; }' does not satisfy the constraint 'PageProps'.
  Types of property 'params' are incompatible.
    Type '{ slug: string; }' is missing the following properties from type 'Promise<any>': then, catch, finally, [Symbol.toStringTag]
```

**Scope confirmed exhaustively** — searched every route in `website/app/` for the two Next 15 gotchas that matter here:
- `params:` usage: exactly **3 files**, all with the identical pattern — `app/blog/[slug]/page.tsx`, `app/events/[slug]/page.tsx`, `app/services/[slug]/page.tsx`.
- `searchParams` usage: **0 files** — not a concern for this codebase.

## Risks checked and ruled out (matter for *why*, not just *whether*, this breaks)

Next.js 15 also changed two other defaults that are easy to miss because they don't fail the build — they'd silently change runtime behavior instead. Both were checked directly against this codebase and are **not a concern here**:

1. **`fetch()` is no longer cached by default in Next 15** (previously cached; now opt-in via `cache: 'force-cache'`). This codebase's CMS layer (`website/lib/sanity.ts`) uses `@sanity/client`'s own `.fetch()` method with `useCdn: true` (Sanity's own CDN caching), not Next's native `fetch()` — so this default change doesn't touch it at all.
2. **`GET` Route Handlers are no longer cached by default in Next 15.** This codebase has zero `GET` route handlers (`contact`, `subscribe`, `verify-certificate` are all `POST`-only) — not applicable.

## The fix (not applied — out of scope for this test-and-report pass)

Each of the 3 affected files needs the same two-line-shaped change:

```diff
- export function generateMetadata({ params }: { params: { slug: string } }): Metadata {
-   const p = getPostBySlug(params.slug);
+ export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }): Promise<Metadata> {
+   const { slug } = await params;
+   const p = getPostBySlug(slug);

- export default async function BlogPost({ params }: { params: { slug: string } }) {
-   const p = getPostBySlug(params.slug);
+ export default async function BlogPost({ params }: { params: Promise<{ slug: string }> }) {
+   const { slug } = await params;
+   const p = getPostBySlug(slug);
```

Apply the equivalent change to `app/events/[slug]/page.tsx` and `app/services/[slug]/page.tsx` (same `params.slug` access pattern in each, confirmed by reading all three files). This is a small, mechanical, well-understood fix — but it's real application-code surgery on production routes, not a config tweak, so it belongs in its own dedicated PR with its own review, not bundled into a "verify release readiness" pass.

## Recommend Merge: **NO**

Not as-is. The build genuinely fails — this isn't a flaky CI artifact or a stale check (verified by reproducing it locally, twice, including via `npm run build` directly and via Playwright's `webServer`). Classification: **Test First** — apply the 3-file params fix above in a follow-up commit on this same PR (or a new PR built on it), re-run this exact gate sequence (lint/tsc/test/build/Playwright), and only merge once `npm run build` succeeds locally and in CI. Once fixed, this should be a low-risk merge — the scope is fully bounded (3 files, one pattern, two runtime-default changes both ruled out), and everything else about this upgrade (lint, types, unit tests) is already clean.
