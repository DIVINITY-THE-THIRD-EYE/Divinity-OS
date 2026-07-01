# Decision Tree — "Where do I work / what do I read?"

```mermaid
graph TD
  Start{What are you doing?} --> A[Changing the website]
  Start --> B[Changing the app]
  Start --> C[Changing data/security]
  Start --> D[Business/ops question]

  A --> A1{What kind?}
  A1 -->|page/SEO| A2[Read 04 · edit app/ + lib/seo + sitemap]
  A1 -->|content/CMS| A3[Read 25 · edit lib/content or Sanity]
  A1 -->|motion/design| A4[Read 11 · design/ tokens + motion-spec]
  A1 -->|form/api| A5[Read 08 · app/api + rate-limit + validation]

  B --> B1{Which feature?}
  B1 -->|new feature| B2[Read AI_CONTEXT · scaffold data/domain/presentation]
  B1 -->|auth/roles| B3[Read 10]
  B1 -->|payments| B4[Read 05+09 · migrations + c8 test]
  B1 -->|attendance| B5[Read 05 · check_in RPC + c2 test]

  C --> C1[Read 09 + 12 · add migration NNN + cN test · keep c1–c8 green]
  D --> D1[Read 00/01/17 + Appendices · mark unknowns Needs Verification]
```

## Quick routing table

| Task | Read first | Then |
|---|---|---|
| Add a website route | [04_Public_Website](04_Public_Website.md) | update `nav.ts`, `seo.ts`, `sitemap.ts`, JSON-LD |
| Add an app feature | [AI_CONTEXT](AI_CONTEXT.md) + [MODULE_INDEX](MODULE_INDEX.md) | follow `data/domain/presentation`, add tests |
| Change schema | [09_Database](09_Database.md) | new migration + `cN` test, run security suite |
| Touch RLS/roles | [10](10_Auth_Authorization.md) + [12](12_Security.md) | use `is_admin`/`is_trainer`, keep c1–c8 green |
| Change payments | [05](05_Student_Mobile_App.md)+[09](09_Database.md) | migration + c8 test, mind locks/triggers |
| Wire an integration | [14_Integrations](14_Integrations.md) | keep web zero-config (fallbacks) |
| Deploy / CI | [15_DevOps_Infrastructure](15_DevOps_Infrastructure.md) | build live trees, not `Divinity/apps/*` |
| Business/legal fact | [01](01_Business_Product.md)/[26](26_Compliance_Legal.md) | confirm `[Needs Verification]`, don't guess |

## Which skill helps?

- App code: `Divinity:dart-flutter-patterns`, `Divinity:flutter-dart-code-review`.
- Web: `Divinity:nextjs-turbopack`, `Divinity:react-patterns`, `Divinity:frontend-design`.
- DB/security: `Divinity:postgres-patterns`, `Divinity:security-review`.
- Design/a11y: `Divinity:accessibility`, `Divinity:10k-checklist`, `Divinity:motion-ui`.
