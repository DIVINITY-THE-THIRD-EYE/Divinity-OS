# Phase 30 — Knowledge Management

> How the Divinity knowledge base is organized and maintained.

## Project Bible Index

This folder **is** the knowledge base. Entry points: [README](README.md) → [MASTER_INDEX](MASTER_INDEX.md) → phase docs. AI agents start at [AI_CONTEXT](AI_CONTEXT.md).

## AI Memory

- Repo-level: [AI_CONTEXT.md](AI_CONTEXT.md) + `Divinity/CLAUDE.md` (agentic-OS) + `Divinity/data/` working memory.
- Decisions: [DECISION_LOG.md](DECISION_LOG.md) + `design/adr/`.
- CodeGraph output (regenerable) at `Divinity/docs/graph/`.

## Decision Tree

See [DECISION_TREE.md](DECISION_TREE.md) — routes a task to the right phase doc + skill.

## Glossary

[GLOSSARY.md](GLOSSARY.md) — domain + technical terms.

## FAQ

[FAQ.md](FAQ.md).

## Cross References

Every phase links to related phases and to source files. The Bible is hyperlinked end-to-end (see MASTER_INDEX).

## Ownership Matrix

[OWNERSHIP_MATRIX.md](OWNERSHIP_MATRIX.md) — area → owner role.

## File Index

[FILE_INDEX.md](FILE_INDEX.md) — key files → purpose.

## Module Index

[MODULE_INDEX.md](MODULE_INDEX.md) — modules → responsibility.

## Search Index

[SEARCH_INDEX.md](SEARCH_INDEX.md) — keyword → where to look.

## Documentation Maintenance Process

1. **On architectural/schema/security change:** update the relevant phase doc + [DECISION_LOG](DECISION_LOG.md) in the same PR.
2. **On new feature:** add to [MODULE_INDEX](MODULE_INDEX.md), [FILE_INDEX](FILE_INDEX.md), relevant phase, and tests.
3. **Resolve `[Needs Verification]`:** when a flagged fact is confirmed, replace the marker with the fact + source.
4. **Quarterly:** review the whole Bible for drift; regenerate CodeGraph; re-run the discovery scan.
5. **Keep one source of truth:** don't duplicate facts across phases — link instead.
