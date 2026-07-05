# CodeQL & GitHub Advanced Security — current state and tradeoffs

## What's happening today

Both CodeQL workflows (`.github/workflows/codeql-website.yml`, `.github/workflows/codeql-flutter.yml`) run the **full CodeQL `security-and-quality` query suite** on every push and pull request that touches `website/` or `flutter-app/`, plus a weekly scheduled run. The analysis step itself always completes — it's the *upload* step that can't succeed, because this repository is **private** and does not have **GitHub Advanced Security** (the feature that powers the "Code scanning" tab) enabled. On GitHub, Advanced Security is free for public repositories but is a paid, org-level feature for private ones.

Before this fix, `github/codeql-action/analyze@v3`'s default (`upload: always`) tried to upload results anyway and failed every single run with: *"Code scanning is not enabled for this repository. Please enable code scanning in the repository settings."* — the analysis itself was never the problem.

## What was changed

Both workflows now pass `upload: never` to the analyze step (a documented, first-party option — see `github/codeql-action`'s own `analyze/action.yml`: *"'never' avoids uploading the SARIF file to Code Scanning, even if the code scanning run fails."*), plus `output: codeql-results` and a follow-up `actions/upload-artifact@v4` step that attaches the raw SARIF output as a downloadable build artifact (30-day retention) on every run.

**No paid GitHub feature was enabled.** This keeps the workflow compatible with GitHub Free/Team plans on a private repo.

## What's retained

- CodeQL's full `security-and-quality` query suite still runs against every push/PR to `website/` and `flutter-app/`, on the exact same schedule as before.
- The raw SARIF results (the actual list of anything CodeQL found) are still produced and are downloadable from the workflow run's **Artifacts** section for 30 days — nothing is silently discarded.
- CI no longer falsely reports a failure that has nothing to do with the code being scanned.

## What's lost, compared to having Advanced Security enabled

- **No Security tab.** Findings aren't visible in GitHub's Security → Code scanning alerts UI — you have to download and open the SARIF artifact manually (e.g. with the [SARIF Viewer VS Code extension](https://marketplace.visualstudio.com/items?itemName=MS-SarifVSCode.sarif-viewer), or any SARIF-aware tool) to see anything CodeQL flagged.
- **No PR-line annotations.** Advanced Security normally posts inline review comments on the exact line a finding was introduced; that doesn't happen here.
- **No historical tracking.** GitHub's dashboard tracking of "alerts opened/fixed over time" doesn't apply without Code scanning enabled.
- **No automatic gating on findings.** This was already true even before this fix — CodeQL's own pass/fail here was always about whether the *scan process* errored, never about whether it *found* a vulnerability. So this specific loss isn't new; it just becomes more visible now that the workflow isn't crying wolf about something unrelated.

In practice: going from the old state (workflow always red, for a reason unrelated to code quality) to this state (workflow green, findings sitting in a downloadable artifact) does not remove any protection that was actually working — the Security tab / PR annotations were never functioning without Advanced Security regardless of how `upload` was configured.

## Recommendation

If security-scanning visibility becomes a priority, the real fix is enabling **GitHub Advanced Security** for this repository (Settings → Code security and analysis → Code scanning, or the equivalent org-level setting) — that unlocks the Security tab, inline PR annotations, and historical tracking, and at that point `upload: never` should be reverted back to the default (`upload: always`, or simply remove the `upload`/`output`/artifact-upload lines) in both `codeql-website.yml` and `codeql-flutter.yml`. That's a billing/plan decision for whoever owns the GitHub organization, not something this repo's workflow files can decide on their own — this document exists so that decision can be made deliberately, with the tradeoff spelled out, rather than by accident.
