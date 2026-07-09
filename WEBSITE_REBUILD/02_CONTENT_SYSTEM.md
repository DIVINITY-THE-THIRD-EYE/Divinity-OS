# 02 — CONTENT SYSTEM (single source of truth)

## PURPOSE
Create `website/content/` — typed modules holding EVERY editable business fact. Owner
edits one file; the whole site updates. Components never contain business data again.

## INPUTS
- `website/lib/content.ts` (existing fallback data + `fetchSiteSettings`) — IF MISSING: STOP (wrong repo state).
- `PLACEHOLDERS.md` — IF MISSING: recreate from playbook template.
- `DECISIONS.md` D005.

## OUTPUTS
Directory `website/content/` with these modules (all typed, all exported):

```
content/
  site.ts          # name, full name, url, city, founder name reference
  contact.ts       # phone, whatsapp, email, address, map link, hours
  social.ts        # instagram, facebook, youtube, etc.
  founder.ts       # name, title, bio, credentials[], photo path
  trainers.ts      # Trainer[] (name, role, quals, photo)
  programs.ts      # Discipline[] (the 6 disciplines: title, intention, description, tags)
  pricing.ts       # Plan[] (name, price, cadence, blurb, features, featured)
  offers.ts        # introOffer (₹99 first week: price, duration, terms), promoBar text
  statistics.ts    # StatItem[] (value, label, verified: boolean)
  testimonials.ts  # Testimonial[]
  gallery.ts       # GalleryImage[] (src, alt, caption, rights)
  events.ts        # EventItem[]
  posts.ts         # BlogPost[]
  faq.ts           # FaqItem[]
  schedule.ts      # Batch[] (display copy; live data note — see below)
  seo.ts           # per-route title/description overrides, keywords
  legal.ts         # privacy, terms, refund — structured sections
  index.ts         # re-exports everything
```

## DEPENDENCIES
None (Phase 1, first code task after precheck).

## FILES ALLOWED
- `website/content/**` (new)
- `website/lib/content.ts`, `website/lib/content.test.ts` (refactor to re-export/merge)
- `website/lib/sanity.ts` (only if the merge signature needs a type touch)
- Existing consumers' import lines ONLY if the re-export cannot keep old import paths working.
- `STATUS.md`, `CHANGELOG.md`, `PLACEHOLDERS.md`.

## FILES FORBIDDEN
- Components' JSX/logic, `app/` pages (their data now flows from content — imports stay
  stable via `lib/content.ts` re-exports), `supabase/`, `flutter-app/`.

## STEPS

1. Read `website/lib/content.ts` fully. List every exported constant/type and every file
   importing it (`grep -rl "@/lib/content" website/app website/components website/lib`).
2. Create `website/content/` modules. MOVE existing fallback data out of `lib/content.ts`
   into the matching module verbatim — do not rewrite copy in this task.
3. Missing data (founder bio, credentials, stats, testimonials, events, legal refund…):
   insert labeled placeholders `"[PLACEHOLDER: <what> — see PLACEHOLDERS.md PH-xxx]"` with
   `// TODO(PH-xxx)` comments. Update `PLACEHOLDERS.md` rows to point at exact file/field.
4. Rewrite `lib/content.ts` as the compatibility + merge layer:
   - re-export everything from `content/` under the OLD names (zero consumer changes), and
   - keep `fetchSiteSettings` / Sanity-override behavior (Sanity value wins when configured;
     `content/` is the fallback — same pattern as today's `fetchOrFallback`).
5. Add one Vitest file `content/content.test.ts`:
   - every module exports non-empty data of the right type;
   - no placeholder string appears in `site.ts` or `contact.ts` critical fields
     (name, url, phone, whatsapp) — these must be real;
   - every `[PLACEHOLDER:` occurrence has a matching `TODO(PH-` comment in the same file.
6. Hardcode sweep — find business data still living in components:
   ```bash
   grep -rn "₹\|+91\|wa.me\|@gmail\|@divinity" website/app website/components --include="*.tsx" -l
   ```
   For each hit that is business data: replace with a `content/` import. Record files
   changed. (Copy/microcopy like headings is NOT business data — leave it.)

## VALIDATION
```bash
cd website && npm run lint && npx tsc --noEmit && npm test && npm run build
```
Plus: the Step 6 grep re-run returns ZERO business-data hits in components
(document any allowed exceptions in STATUS with one-line reasons).

## IF VALIDATION FAILS
Type errors from moved data → fix types in `content/`, never loosen to `any`.
Consumer breaks → the re-export layer is wrong; fix `lib/content.ts`, do not edit consumers.

## CHECKPOINT
Commit: `feat(rebuild): 02 content system — single source of truth in website/content/`

## STOP CONDITION
All validation green, hardcode sweep clean, PLACEHOLDERS updated. Auto-continue.

## NEXT
`03_DESIGN_SYSTEM.md`
