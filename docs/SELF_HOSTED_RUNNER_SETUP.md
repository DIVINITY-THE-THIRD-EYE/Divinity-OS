# Self-Hosted Runner Setup — CodeQL Workflows

**Status: prepared, not activated.** Both CodeQL workflows (`.github/workflows/codeql-flutter.yml`, `.github/workflows/codeql-website.yml`) now resolve their `runs-on` value from a repository/organization variable:

```yaml
runs-on: ${{ vars.CODEQL_RUNNER_LABEL || 'ubuntu-latest' }}
```

With `CODEQL_RUNNER_LABEL` unset (the current state), this evaluates to `'ubuntu-latest'` — **identical behavior to before this change.** Nothing runs on a self-hosted runner until that variable is deliberately set, and that has not been done as part of this work. This document exists so that decision can be made deliberately later, with the requirements spelled out.

## Why self-hosted at all

This account's free-tier GitHub Actions minutes (2,000/month on a private repo) were exhausted mid-audit-session, causing the Flutter CodeQL job to be killed mid-run by GitHub's own runner-shutdown mechanism (not a code or workflow bug — see `docs/GITHUB_ACTIONS_USAGE_REPORT.md`). A self-hosted runner uses your own compute instead of GitHub's metered minutes, which sidesteps that limit entirely for whichever jobs point at it. The tradeoff is that you now own the runner's uptime, security, and maintenance.

## Portability audit — are these workflows Windows/macOS/Linux-safe?

**Yes, both CodeQL workflows are already portable.** Every step is either a marketplace `uses:` action (which handles OS differences internally) or a single-line `run:` command (`flutter pub get`, `flutter build apk --debug`, `npm ci`) with no bash-specific syntax (no heredocs, no `|` pipes into shell builtins, no POSIX-only flags). Contrast this with `release-flutter.yml` elsewhere in this repo, which *does* use bash heredoc syntax (`cat > file <<EOF ... EOF`) and `base64 --decode` — that workflow would need rewriting before it could run on a Windows self-hosted runner without WSL or Git Bash. **That workflow is out of scope here and was not changed** — this document covers only the two CodeQL workflows, per this task's scope.

## Required dependencies per workflow

### `codeql-flutter.yml` (Java/Kotlin analysis of the Android build)

| Dependency | Why | Notes |
|---|---|---|
| Git | checkout | Any recent version |
| Java 17 (Temurin) | Android/Gradle build | `actions/setup-java@v4` will install it if the runner has internet access to Adoptium's CDN; otherwise pre-install and skip that step |
| Flutter SDK (stable channel) | `flutter build apk` | `subosito/flutter-action@v2` downloads it (needs network access to Flutter's storage CDN) unless pre-installed and cached |
| Android SDK + build-tools + platform-tools | `flutter build apk --debug` requires these | Not installed by any step in this workflow today — GitHub-hosted `ubuntu-latest` images ship these preinstalled; **a self-hosted runner must have the Android SDK installed and `ANDROID_HOME`/`ANDROID_SDK_ROOT` set, or this step will fail** |
| CodeQL CLI + java-kotlin extractor | `github/codeql-action/init@v3` downloads the CodeQL bundle (needs network access to GitHub's release CDN) |
| Disk space | CodeQL databases + Gradle caches + Android SDK + build output can total several GB per run | Budget at least 15-20 GB free, more if multiple concurrent jobs share the runner |
| RAM | CodeQL's Java/Kotlin extraction and query evaluation is memory-hungry — GitHub-hosted runners default to ~6.9 GB available to CodeQL | A self-hosted runner should have at least that much free RAM, more if other jobs share the machine |
| Network access | Adoptium (Java), Flutter's CDN, Google's Maven repo (Android Gradle Plugin + AndroidX deps), GitHub's CodeQL bundle CDN, `pub.dev` | If any of these are blocked by a corporate/network firewall, pre-populate the relevant caches instead |

### `codeql-website.yml` (JavaScript/TypeScript analysis)

| Dependency | Why | Notes |
|---|---|---|
| Git | checkout | |
| Node.js 20 | `npm ci`, CodeQL JS/TS extraction | `actions/setup-node@v4` installs it if network-accessible |
| CodeQL CLI + javascript-typescript extractor | same as above | |
| Disk space | Much lighter than the Flutter job — a few GB is generally sufficient | |
| Network access | npm registry, GitHub's CodeQL bundle CDN | |

## Registering a self-hosted runner

1. Go to the repository's **Settings → Actions → Runners → New self-hosted runner**.
2. Pick the target OS; GitHub generates a per-OS download-and-configure script. Run it on the machine you're dedicating to this.
3. During configuration, give the runner a **label** you'll reference later (e.g. `divinity-codeql`) in addition to the default `self-hosted` label. A dedicated, non-generic label avoids accidentally routing unrelated workflows onto this machine.
4. Start the runner as a service (the registration script explains the OS-specific service-install command) so it survives reboots and stays available for scheduled/dispatch runs.

## Activating it (not done by this change — a separate, deliberate step)

Once the runner is registered and verified reachable (`Settings → Actions → Runners` shows it "Idle"):

1. Go to **Settings → Secrets and variables → Actions → Variables** (repository or organization level).
2. Add a variable named `CODEQL_RUNNER_LABEL` with the value of the label you chose above (e.g. `divinity-codeql`).
3. The next scheduled run, push to `main`/`feature/trust-certificates`, or manual `workflow_dispatch` of either CodeQL workflow will pick up the self-hosted runner automatically — no further workflow-file changes needed.
4. To revert to GitHub-hosted runners, delete the `CODEQL_RUNNER_LABEL` variable (or set it to `ubuntu-latest`).

## Security considerations before activating

- Self-hosted runners execute the exact code in the workflow file at the time the job runs, with whatever access the runner's host machine has. Since these two workflows never run on `pull_request` anymore (see `docs/CODEQL_STRATEGY.md`), there's no exposure to untrusted fork-PR code triggering arbitrary execution on your machine — a real risk GitHub explicitly warns about for self-hosted runners on workflows that do run on `pull_request`.
- Keep the runner machine patched and treat it as you would any machine with access to this private repository's contents and secrets (`security-events: write` is the only permission these two workflows request, but a compromised runner host could still be a foothold).
- Consider running the self-hosted runner in an ephemeral/single-job mode (GitHub supports this) if the host is otherwise used for other things, so state doesn't leak between runs.

## Do not activate without approval

Per explicit direction: this document is preparation only. **Wait for approval before setting `CODEQL_RUNNER_LABEL`.**
