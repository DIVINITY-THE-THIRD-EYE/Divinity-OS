# 12 — Claude Code Tooling for This Project

This is a curated list — the environment has hundreds of installed skills for unrelated domains (marketing automations, other SaaS integrations, etc.). Only tools genuinely applicable to this monorepo's day-to-day engineering are listed.

## Skills

| Skill | When to use | Example invocation |
|---|---|---|
| `flutter-dart-code-review` / `flutter-expert` | Reviewing or writing Flutter/Dart code — repository pattern, Riverpod state, widget structure | `/flutter-dart-code-review` after a feature PR, before merge |
| `nextjs` / `nextjs-app-router-patterns` / `nextjs-best-practices` | Any App Router routing, data-fetching, or server/client component question on `website/` | `/nextjs-app-router-patterns` when adding a new dynamic route |
| `supabase` / `supabase-postgres-best-practices` / `rls-design` | Writing a new migration, designing RLS policies, or reviewing trigger/function patterns | `/rls-design` before adding a new table's policies — this project's `is_admin()`/`is_trainer()` helper pattern (migration 012) is exactly what this skill would recommend |
| `security-review` / `owasp-audit` / `dependency-audit` | Periodic security passes, or before a release that touches auth/payments/storage | `/dependency-audit` on `website/` to track the `next@14.2.35` CVE list found this session |
| `database-optimizer` / `postgres-pro` | If a `get_reports_*` RPC needs performance tuning as data grows | `/postgres-pro` when adding indexes for a new report query |
| `test-generation` / `tdd` | Writing new pgTAP tests or Flutter/vitest tests for a new feature, following this repo's existing 1:1 migration-to-test-file convention | `/test-generation` to draft a `c24_*_test.sql` for the next migration |
| `playwright` / `playwright-expert` | Running/extending the website's `e2e/` suite (not exercised this audit session — see [10_Testing_Report.md](10_Testing_Report.md)) | `/playwright-expert` to get the e2e suite running in CI |
| `github-actions` / `ci-cd` | Any workflow-file change, like this session's `release-please` fix | `/github-actions` before editing `.github/workflows/*` |
| `accessibility` / `a11y-audit` / `wcag-review` | A dedicated a11y pass on the website (flagged as not deeply assessed this session) | `/a11y-audit` against the built site |
| `code-review` | General PR review beyond a specific framework's lens | `/code-review` on any non-trivial PR |

## Custom, project-specific skill

- **`divinity-project-ingestion`** — a project-specific skill present in this environment (`.claude/skills/divinity-project-ingestion/`). Its exact current content wasn't re-verified this session; per this audit's general finding that in-repo/skill docs can lag the codebase (see [01_Project_Overview.md](01_Project_Overview.md)), **cross-check anything it asserts about project structure or status against this audit's live-verified findings before trusting it**, the same way `docs/PROJECT_BIBLE` needed cross-checking.

## MCP servers used this session

- **Context7** — used to verify the exact `release-please-action@v4` config schema before writing the CI fix, rather than guessing from training data (which would have been v3-shaped and wrong). This is the correct use of Context7 per this environment's own global instructions: "use even when you think you know the answer."
- **Claude Preview** (browser tooling) — used to verify the website renders correctly, check responsive behavior, and confirm no console errors, without needing a separate manual QA pass.
- **Bash/git/gh** — used throughout for running the actual verification gates and checking real CI history (`gh run list`), which is what caught the release-please failure as a *confirmed, ongoing* problem rather than a guess from reading the YAML alone.

## Subagent types used this session

- **Explore** (×3, run in parallel) — used for the structural architecture mapping of `flutter-app/`, `website/`, and `supabase/` respectively. This matched the intended use case exactly: broad, citation-heavy location/mapping work exceeding what a few direct greps would efficiently cover, while the actual judgment calls (security analysis, root-causing the pgTAP failure, deciding what's a real bug vs. a documented trade-off) were done directly, not delegated — Explore agents read excerpts and are not suited to open-ended analysis or correctness judgments.

## Optimal workflow for remaining work

1. **Payment_screenshots bucket re-verification** — this needs the project owner directly (production Supabase dashboard access), not a Claude Code skill. No tool substitutes for this.
2. **Next.js CVE upgrade evaluation** — `/dependency-audit`, then a manual `npm install next@latest` in a throwaway branch, followed by the full website gate suite (`tsc`, `lint`, `vitest`, `build`, and ideally the not-yet-run Playwright e2e suite) before deciding whether to merge.
3. **Website i18n expansion** (if the owner decides to close that gap) — `/nextjs-app-router-patterns` for the routing implications of full-page translation, paired with straightforward content work; no exotic tooling needed beyond what's already in `lib/i18n/`.
4. **Playwright e2e suite** — `/playwright-expert` to get `playwright install` and CI wiring sorted, since this audit found the suite exists but was never actually run in this pass.
5. **Ongoing:** when adding any new migration, follow the existing convention — a numbered migration file with a header-comment rationale, a matching `cNN_*_test.sql` pgTAP file, and if it touches RLS, reuse `is_admin()`/`is_trainer()` rather than a fresh policy pattern. Commit only after the relevant gate (`flutter test`, `vitest run`, or `supabase test db`) is green, matching this session's own fix pattern (one concern per commit, verification evidence in the message).
