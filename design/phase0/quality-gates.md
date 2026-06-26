# Automated Quality Gates (Phase 0)

Every PR must pass all gates or it cannot merge. The workflow lives at `.github/workflows/ci.yml`
(**scaffold** — inert until this becomes a git repo on GitHub and the devDeps + scripts below are added).
This is intentionally **not activated automatically** so the frozen app and its `package.json` stay
untouched in Phase 0; activation is the first task of the engineering setup.

## Gate matrix
| Gate | Tool (free) | Pass criterion | Doc |
|---|---|---|---|
| TypeScript | `tsc --noEmit` | 0 type errors | — |
| Lint | `next lint` / ESLint | 0 errors (run in **CI**, not build) | TD5 (`22`) |
| Formatting | Prettier `--check` (or Biome) | no diffs | — |
| Unit tests | Vitest | all pass; cover utils (`escapeHtml`, validation, `fetchOrFallback`) | — |
| Accessibility | `@axe-core/playwright` | **0 critical/serious** | `09` |
| Bundle size | `size-limit` | first-load `/` ≤ **210 kB** | `11` |
| Lighthouse | `@lhci/cli` | Perf ≥95, A11y ≥95, SEO 100, BP ≥95; LCP<2.0s, CLS<0.05, INP<150ms | `11` |
| Visual regression | Playwright `toHaveScreenshot` | ≤0.1% diff on static surfaces (dynamic masked) | `20` |
| Dead links | `linkinator` | 0 broken links | — |
| Broken images | Playwright (`naturalWidth>0`) | 0 broken images | — |

## To activate (engineering setup task — not done in Phase 0)
1. `git init` + push to GitHub (see `release-strategy.md`); enable branch protection requiring these checks.
2. Add devDeps:
   ```
   npm i -D vitest @vitejs/plugin-react jsdom \
     @playwright/test @axe-core/playwright \
     @lhci/cli size-limit @size-limit/file \
     prettier eslint-config-prettier linkinator wait-on
   ```
3. Add npm scripts (does **not** alter app code):
   ```jsonc
   "typecheck": "tsc --noEmit",
   "format:check": "prettier --check .",
   "test:unit": "vitest run",
   "test:a11y": "playwright test a11y",
   "test:vrt": "playwright test visual",
   "test:images": "playwright test images",
   "size": "size-limit"
   ```
4. Add configs: `lighthouserc.json`, `.size-limit.json`, `playwright.config.ts`, `vitest.config.ts`
   (snippets below).
5. Generate VRT baselines after a green build (`design/20`).

## Config snippets (ready to copy)
**`.size-limit.json`**
```json
[{ "name": "First-Load JS (/)", "path": ".next/static/chunks/*.js", "limit": "210 kB" }]
```
**`lighthouserc.json`**
```json
{
  "ci": {
    "collect": { "url": ["http://localhost:3000/"], "numberOfRuns": 3 },
    "assert": {
      "assertions": {
        "categories:performance": ["error", { "minScore": 0.95 }],
        "categories:accessibility": ["error", { "minScore": 0.95 }],
        "categories:seo": ["error", { "minScore": 1.0 }],
        "categories:best-practices": ["error", { "minScore": 0.95 }],
        "largest-contentful-paint": ["error", { "maxNumericValue": 2000 }],
        "cumulative-layout-shift": ["error", { "maxNumericValue": 0.05 }]
      }
    }
  }
}
```
**`vitest.config.ts`** — `environment: 'jsdom'`, include `lib/**` + component logic tests.
**`playwright.config.ts`** — projects for `a11y`, `visual`, `images`; baseURL `http://localhost:3000`;
emulate `prefers-reduced-motion: reduce` for deterministic VRT (`design/20 §5`).

## Note on Node
CI pins **Node 20 LTS** even though local dev is on Node 24 (BASELINE). Add `.nvmrc` (`20`) and
`"engines": { "node": ">=20 <23" }` to `package.json` during activation for reproducible builds.
