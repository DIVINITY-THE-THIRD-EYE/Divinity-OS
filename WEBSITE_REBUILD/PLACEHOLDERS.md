# PLACEHOLDERS — missing business data registry

Rule: **never invent business data.** When real data is unavailable, the executing model
(1) adds a row here, (2) creates a clearly-labeled placeholder in `website/content/`,
(3) continues working. The owner fills real values later by editing `website/content/`
files only — no code changes needed.

Placeholder values in content files MUST be wrapped so they are visually identifiable,
e.g. `"[PLACEHOLDER: founder bio — needs real text from owner]"`, and each content field
that is a placeholder carries a `// TODO(PH-xxx)` comment referencing this table.

| ID | Data needed | Content file / field | Status | Notes |
|---|---|---|---|---|
| PH-001 | Founder full biography (verified facts only) | `content/founder.ts` → `bio` | PENDING | Currently only name + short blurb exist on live site |
| PH-002 | Founder credentials / certifications | `content/founder.ts` → `credentials[]` | PENDING | Never invent (PROJECT_RULES #3) |
| PH-003 | Trainer profiles (names, photos, quals) | `content/trainers.ts` | PENDING | `public/guru/` photos exist — confirm identities + rights |
| PH-004 | Real member statistics (count, years, classes) | `content/statistics.ts` | PENDING | StatsBand numbers need business sign-off (dossier flag R2) |
| PH-005 | ₹99 first-week offer — exact terms | `content/offers.ts` → `introOffer` | PENDING | Offer exists on live site; terms/conditions unconfirmed (dossier flag R1/R8) |
| PH-006 | Testimonials (real, permissioned quotes) | `content/testimonials.ts` | PENDING | Live site ships an empty state today |
| PH-007 | Pricing plan final amounts | `content/pricing.ts` | PENDING | Fallback plans exist in `lib/content.ts` — confirm current prices |
| PH-008 | Class schedule (batches, times) | `content/schedule.ts` | PENDING | App `batches` table is authoritative — decide static copy vs live fetch |
| PH-009 | Refund policy text | `content/legal.ts` → `refund` | PENDING | Page required (D008); no legal text exists yet |
| PH-010 | Privacy policy / Terms review | `content/legal.ts` | PENDING | Pages exist — owner must confirm text is current |
| PH-011 | Events (upcoming, real) | `content/events.ts` | PENDING | Live site ships an empty state today |
| PH-012 | Blog posts (initial articles) | `content/posts.ts` | PENDING | Blog stays `noindex` until real content |
| PH-013 | Business contact set (phone, WhatsApp, email, address, hours) | `content/contact.ts` | CONFIRM | Values exist on live site — owner confirm current |
| PH-014 | Social media URLs | `content/social.ts` | CONFIRM | Verify each link live |
| PH-015 | Gallery captions / photo usage rights | `content/gallery.ts` | CONFIRM | `public/studio/` photos — confirm publication rights |
| PH-016 | Living Anatomy figure mesh (`public/models/figure.glb`) | `07_SCENE_3D.md` Step 1 | PENDING | A licensable CC-BY candidate was found ("A Man Sitting", Sketchfab, 18k tris, 9k verts — see DECISIONS.md asset registry) but downloading it (Sketchfab gates downloads behind an authenticated account UI) and processing it (decimate → glTF → gltf-transform + Draco) needs tooling (Blender / gltf-transform CLI / a logged-in Sketchfab session) not available in this environment. SilhouetteTier ships as the complete hero visual meanwhile (07's own Step 1.5 explicitly allows this — "do NOT stop the project"). Whoever has that tooling: verify the pose is actually cross-legged/seated (unconfirmed from the listing page) before committing to it, or pick a fresh candidate. |

Status values: `PENDING` (no real data), `CONFIRM` (data exists, needs owner confirmation),
`DONE` (owner provided/confirmed — move value into content file, keep row for history).

## Pending business decisions (owner input required — distinct from missing data)

Per the autonomy charter (D011): engineering decisions are the executor's; decisions that
change the BUSINESS land here and wait. The executor picks the safest default, labels it,
and continues — the row records what the owner must ratify or change.

| ID | Decision needed | Default taken meanwhile | Status |
|---|---|---|---|
| BD-001 | Launch approval (final go-live) | not launched | PENDING |
| BD-002 | Flutter Web hosting origin (subdomain `app.<domain>` needs DNS the owner controls) | path-based hosting until DNS granted | PENDING |
| BD-003 | Blog/events/testimonials go-live (flipping noindex needs real content the owner supplies) | pages built, noindex | PENDING |
| BD-004 | Analytics/RUM vendor (privacy + cost is a business call) | none installed | PENDING |

Add rows as they are discovered: `BD-xxx | <decision> | <safe default> | PENDING`.
