# WEBSITE_REBUILD — Execution Playbook

This directory is the **complete, self-sufficient instruction set** for rebuilding the
Divinity — The Third Eye website ("Living Anatomy" concept, approved). It is written so
that **any AI model or human developer** — strong or weak — can execute it without
inferring missing details.

## How to use this playbook (for the executing model)

1. Read `99_MODEL_INSTRUCTIONS.md` first. It is your operating manual.
2. Read `PROJECT_RULES.md`. These rules are absolute.
3. Read `STATUS.md` to find the current phase and the next file to execute.
4. Open `00_MASTER_EXECUTION.md` and follow the phase order. Never skip ahead.
5. Execute exactly ONE numbered file at a time, following its template sections
   (Purpose → Steps → Validation → Stop Condition).
6. After every completed file: update `STATUS.md` and `CHANGELOG.md`, then continue to
   the next file. Auto-continue is the default (D011 autonomy charter) — the only human
   approval gate is launch (19) and business rows in `PLACEHOLDERS.md`.
7. Engineering judgment is yours: objectively better implementation → do it, record it
   in `DECISIONS.md` → EVOLUTION LOG, update the task file, continue
   (`99_MODEL_INSTRUCTIONS.md` → Autonomy charter).

## File map

| File | What it builds |
|---|---|
| `00_MASTER_EXECUTION.md` | Phase order, gates, auto-continue rules |
| `01_REPO_PRECHECK.md` | Verify repo state before touching anything |
| `02_CONTENT_SYSTEM.md` | Single source of truth for ALL business data |
| `03_DESIGN_SYSTEM.md` | Tokens, day/night themes, typography |
| `04_HOMEPAGE.md` | 9-section homepage DOM (no 3D yet) |
| `05_MOTION_SCROLLSTORY.md` | Master scroll timeline, section choreography |
| `06_YOGA_CURSOR.md` | Surya Namaskar morphing cursor |
| `07_SCENE_3D.md` | 3D figure, silhouette fallback, mesh sourcing |
| `08_CORE_PAGES.md` | About, Founder, Trainers, Programs, Therapeutic, Meditation |
| `09_COMMERCE_PAGES.md` | Membership, Pricing, Schedule |
| `10_COMMUNITY_PAGES.md` | Events, Gallery, Testimonials, FAQ, Blog |
| `11_CONTACT_LEGAL.md` | Contact, Certificate Verify, Privacy, Terms, Refund |
| `12_STUDENT_LOGIN.md` | Supabase auth on the website (students only) |
| `13_FLUTTER_WEB.md` | Flutter Web app embedded after login |
| `14_SEO.md` | Metadata, schema.org, sitemap |
| `15_PERFORMANCE.md` | Budgets, Lighthouse CI, optimization |
| `16_ACCESSIBILITY.md` | WCAG 2.2 AA pass |
| `17_TESTING.md` | Unit, e2e, visual regression |
| `18_DEPLOYMENT.md` | Build, deploy, environments |
| `19_LAUNCH.md` | Final gate checklist |
| `99_MODEL_INSTRUCTIONS.md` | How the executing model must think |

Support files (living documents, updated continuously):

| File | Role |
|---|---|
| `STATUS.md` | Where we are. Updated after EVERY task. |
| `PROJECT_RULES.md` | Absolute rules. Never violated. |
| `DECISIONS.md` | Approved business/design decisions. Never re-ask. |
| `PLACEHOLDERS.md` | Registry of missing business data. Never invent. |
| `CHANGELOG.md` | What changed, when, by which phase. |

## Context documents (read-only background)

- Strategy: `DESIGN_STRATEGY_V2` (Living Anatomy concept — summarized in `DECISIONS.md`)
- Existing research dossier: `website/design/` (24 docs + ADRs) — valid research, reuse it
- Project knowledge base: `docs/PROJECT_BIBLE/`
