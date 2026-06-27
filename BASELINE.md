# BASELINE — Divinity (Phase 0 freeze)

Frozen engineering baseline. Captured **2026-06-26**. All future phases compare against this.
Generated from real environment/build output; items that need a live tool run (Lighthouse/axe) are
marked **TO RUN** with the method to fill them — not guessed.

## Repository
| Field | Value | Label |
|---|---|---|
| Commit hash | **`c7e05402ef3a4ff5996b59aaf5c0bf848523c5f6`** (short `c7e0540`) | MEASURED |
| Branch | `main` | MEASURED |
| Tags | `dossier-v1.0`, `baseline-phase0` | MEASURED |
| Initial commit | "chore: Phase 0 engineering baseline freeze" — 155 files | MEASURED |
| Remote | none yet — `git remote add origin <url>` then push (GitHub-side) | PROPOSED |
| Branch protection / signed commits | configure on GitHub after push (not possible locally) | PROPOSED |
| Project | `divinity-third-eye` v1.0.0 (private) | MEASURED |
| Path | `divinity-third-eye/divinity` | MEASURED |

## Toolchain
| Field | Value |
|---|---|
| Node | **v24.15.0** ⚠️ newer than Next 14.2's officially-tested line (18/20 LTS); builds clean, but pin via `.nvmrc`/`engines` for reproducibility |
| Package manager | **npm 11.12.1** |
| Build command | `next build` (`npm run build`) |
| Dev / start / lint | `next dev` · `next start` · `next lint` |
| Lockfile | `package-lock.json` — **SHA-256 `a6dc2477b6636c0613fbf8978b21ce2afb9c4d97490c4c4b3a4c159aca0e5e3c`**, 1902 lines |
| node_modules | 110 top-level packages installed |

## Environment variables (all optional — graceful fallback by design)
| Var | Purpose | Required? |
|---|---|---|
| `BREVO_API_KEY` | Contact email delivery | No → accept+log fallback |
| `BREVO_TO_EMAIL` / `BREVO_TO_NAME` | Enquiry recipient | Defaults provided |
| `BREVO_FROM_EMAIL` / `BREVO_FROM_NAME` | Verified sender | Defaults provided |
| `NEXT_PUBLIC_SANITY_PROJECT_ID` | Enable Sanity CMS | No → local content fallback |
| `NEXT_PUBLIC_SANITY_DATASET` | Sanity dataset | Default `production` |
| `NEXT_PUBLIC_SANITY_API_VERSION` | Sanity API pin | Default `2024-01-01` |
> `BREVO_API_KEY` is **server-only** (used in the API route, never shipped to client). `NEXT_PUBLIC_*`
> are non-secret Sanity ids by design.

## Installed package inventory (resolved, top-level)
**dependencies:** `next@14.2.35` · `react@18.3.1` · `react-dom@18.3.1` · `framer-motion@11.18.2` ·
`gsap@3.15.0` · `lenis@1.3.23` · `@sanity/client@6.29.1`
**devDependencies:** `typescript@5.9.3` · `tailwindcss@3.4.19` · `postcss@8.5.15` ·
`autoprefixer@10.5.1` · `@types/node@20.19.43` · `@types/react@18.3.31` · `@types/react-dom@18.3.7`
> Declared ranges (`package.json`) use carets/`~`; the above are the **resolved** versions in the lockfile.

## Bundle sizes (from `next build`)
| Route | Size | First-Load JS |
|---|---|---|
| `/` (home, static ○) | 110 kB | **198 kB** |
| `/_not-found` | 873 B | 88.1 kB |
| `/api/contact` (ƒ dynamic) | 0 B | 0 B |
| `/opengraph-image` (ƒ) | 0 B | 0 B |
| `/icon.png`, `/apple-icon.png`, `/robots.txt`, `/sitemap.xml` | 0 B | 0 B |
| **Shared by all** | — | **87.3 kB** (chunks: ~53.6 kB + ~31.7 kB + ~1.9 kB) |

- **Budget reference:** First-Load JS for `/` = **198 kB** → hard budget ≤ **210 kB** (`design/11`).
- `.next` build output dir: 181 MB (includes cache/artifacts; not the served payload).

## Lighthouse (TO RUN — not captured headlessly this session)
No Chrome debug bridge available here, so scores aren't fabricated. **Run before Phase 1 starts** and
paste results into `design/phase0/performance-baseline.md`:
```
npx unlighthouse --site http://localhost:3000      # or:
npx lighthouse http://localhost:3000 --preset=desktop --output=json --output-path=./design/phase0/reports/lh-desktop.json
npx lighthouse http://localhost:3000 --form-factor=mobile --output=json --output-path=./design/phase0/reports/lh-mobile.json
```
Targets (must meet before declaring baseline "green"): Perf ≥95, A11y ≥95, SEO 100, BP ≥95;
LCP <2.0s, CLS <0.05, INP <150ms (`design/11`).

## Baseline artifact index
Architecture diagrams · quality gates · performance/a11y/SEO baselines · component & motion inventories ·
token freeze · tech-debt re-score · release strategy → **`design/phase0/`**.

## Freeze rule
The current application is **frozen**. Phase 0 adds only baseline/CI/doc artifacts (no app code, no
`package.json`/dependency changes). Only components tagged *Needs Improvement* / *Experimental*
(`design/phase0/component-freeze.md`) may change in Phase 1.
