# 18 — API & Data Contracts

Documents the **existing** contact API (verbatim to the code), the **proposed** subscribe API, the
content data model, and the Sanity contract. Includes validation, errors, auth, rate limits, versioning,
and sequence diagrams.

---

## 1. `POST /api/contact` (existing — `app/api/contact/route.ts`)
Runtime: **nodejs**. Stateless. No auth (public form).

**Request** `application/json`
```ts
{ name?: string; email?: string; intention?: string; message?: string }
```
**Validation**
- `name` trimmed, required (non-empty).
- `email` trimmed, required, regex `^[^\s@]+@[^\s@]+\.[^\s@]+$`.
- `intention`, `message` optional, trimmed; **HTML-escaped** server-side before email.

**Responses**
| Status | Body | When |
|---|---|---|
| 200 | `{ ok: true, delivered: true }` | Brevo accepted (key set) |
| 200 | `{ ok: true, delivered: false }` | **No `BREVO_API_KEY`** → accepted + logged (dev/zero-config) |
| 400 | `{ error: "Invalid request." }` | malformed JSON |
| 422 | `{ error: "Please add your name and a valid email." }` | validation fail |
| 502 | `{ error: "We couldn't send that just now. Please try again." }` | Brevo non-OK / network error |

**Upstream:** `POST https://api.brevo.com/v3/smtp/email` with `sender`, `to`, `replyTo:{visitor}`,
`subject`, `htmlContent`. Secrets via env: `BREVO_API_KEY`, `BREVO_TO_EMAIL/NAME`, `BREVO_FROM_EMAIL/NAME`.

**Sequence**
```
Contact.tsx --POST /api/contact--> route
  route: parse → validate → (no key? log+200 delivered:false)
                          → (key? fetch Brevo → 200 delivered:true | 502)
Contact.tsx: status → "done" | error message (aria-live, R9)
```
**Gaps (→ `21`/`22`):** no rate limit, no honeypot/CSRF, no size cap, errors only `console`-logged.

---

## 2. `POST /api/subscribe` (proposed — R3, mirror of contact)
Runtime: nodejs. Public.

**Request** `{ email: string; source?: "section"|"footer"; consent?: boolean }`
**Validation:** same email regex; `consent` required true; **honeypot** field rejected silently; basic
per-IP rate limit.
**Responses**
| Status | Body | When |
|---|---|---|
| 200 | `{ ok:true, subscribed:true }` | added to Brevo list |
| 200 | `{ ok:true, subscribed:false }` | no key → accept+log (zero-config) |
| 422 | `{ error: "Enter a valid email." }` | invalid/missing consent |
| 429 | `{ error: "Please wait a moment." }` | rate-limited |
| 502 | `{ error: "Couldn't subscribe right now." }` | upstream error |

**Upstream:** `POST https://api.brevo.com/v3/contacts` `{ email, listIds:[<id>], updateEnabled:true }`.
Env: `BREVO_API_KEY`, `BREVO_LIST_ID`. Lead magnet (free breathing practice) delivered via Brevo
automation or a static asset link in the confirmation.

---

## 3. Content data model (`lib/content.ts` — canonical types)
```ts
type Discipline = { title; intention:"For the body"|"For the breath"|"For healing"; description; tags:string[] }
type Plan       = { name; price; cadence; blurb; features?:string[]; featured?:boolean }
type ClassSlot  = { time; batch:"Dawn"|"Midday"|"Dusk"; name; detail; level }
type Testimonial= { quote; name; meta }
type GalleryShot= { src; alt; w:number; h:number }
site = { name, full, city, entity, founder, founderRole, founderImage, est, url, logoMark, logoFull, phone, whatsapp, instagram }
payment = { bank, qr, note }
// proposed additions (typed): offer, stats[], newsletter, quote, Discipline.intensity?
```
**Contract rule:** local types are the source of truth; Sanity documents must match these shapes
(ADR-0004). All optional additions are back-compatible.

## 4. Sanity contract (`lib/sanity.ts`)
- `fetchOrFallback<T>(query, fallback, params?)`: returns Sanity data only if `projectId` set **and**
  result non-empty; any error → `fallback`. `useCdn:true`, `apiVersion` pinned.
- GROQ queries live in `app/page.tsx` (disciplines/plans/testimonials). Read-only, public dataset.

## 5. Cross-cutting
- **Auth:** none today (public marketing site). Future product auth = Supabase (ADR-0011).
- **Rate limits:** add to both routes (IP token-bucket; e.g. 5/min). Currently absent (debt).
- **Versioning:** routes are unversioned internal endpoints; if they become public/app APIs, prefix
  `/api/v1/*` and keep response shapes additive (never break fields).
- **Idempotency:** form posts are non-idempotent but low-harm (duplicate email); dedupe in Brevo by email.
- **Errors:** never leak upstream detail to the client (already the case); log server-side; add Sentry (`12 §8`).
