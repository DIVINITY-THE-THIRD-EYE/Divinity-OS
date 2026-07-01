# 19 — Content Strategy

Codifies the voice already present in the build (Manifesto, Disciplines, Method) so new copy stays
consistent. All copy lives in `lib/content.ts` (ADR-0004).

## 1. Tone of voice
**Calm · grounded · poetic-but-clear · warm · never salesy.** The site speaks like a teacher, not a gym.
- **Do:** short, breath-paced sentences; sensory, concrete imagery ("swimming in syrup" energy, but ours);
  Sanskrit used sparingly and correctly (आसन, प्राण, ध्यान, आज्ञा, ॐ).
- **Don't:** hype, exclamation marks, jargon, pressure ("ACT NOW"), wellness clichés ("unlock your best self").
- **Reading level:** plain, inclusive; explain Sanskrit on first use.

## 2. Messaging hierarchy
1. **Core promise:** "Breathe your way inward." (breath-led yoga, fitness & wellness in Lucknow)
2. **Proof of substance:** real teacher, real space (founder, gallery, stats), three-step Method.
3. **Range:** disciplines for body / breath / healing.
4. **Reassurance:** beginners welcome; therapeutic care; simple UPI payment.
5. **Ask:** a low-commitment first class / enquiry.

## 3. SEO content strategy (preserve existing, extend)
- Primary intents: "yoga Lucknow", "beginner yoga Lucknow", "therapeutic yoga", "pranayama classes",
  "fitness + yoga academy". (Already in metadata/keywords.)
- Each new section earns a keyworded `<h2>` + supporting copy (Stats, StartHere, intensity tags) — `03 §14`.
- Keep core copy server-rendered (not behind JS islands) for crawlability.
- Structured data: extend JSON-LD with Offer (and Event/Course for R11).

## 4. Landing-page copy principles
- One idea per section; lead with benefit, support with substance.
- Headlines = Cormorant display with one italic accent word (existing device).
- CTAs are invitations, not commands: "Begin", "Book your first class", "Breathe with us".
- Every section ends with a path forward (anchor or CTA).

## 5. Microcopy
| Surface | Principle | Example |
|---|---|---|
| Buttons | verb + warmth | "Book your first class", "Send enquiry", "Begin" |
| Labels | quiet, lowercase mono eyebrows | "what draws you", "name" |
| Helper | reassure | "Beginners welcome — we'll pace your first sessions gently." |
| Placeholders | concrete | "Anything we should know — goals, history, questions." |

## 6. Form messaging
- **Success:** affirm + next step — "Thank you. We'll reach out shortly to begin." (existing pattern).
- **Error (field):** specific, kind — "Please add a valid email." (no blame).
- **Error (system):** human, retryable — "We couldn't send that just now. Please try again."
- **Submitting:** "Sending…" (existing). Announce all via `aria-live` (R9, `09`).

## 7. Empty-state messaging
- Schedule with no class: "No classes today — see the full week." + link.
- Gallery/loading: quiet skeleton, no spinners-of-doom.
- Future app lists: one calm line + one action (`10 §8.7`).

## 8. Error messaging guidelines
- Never expose stack/upstream detail (already enforced server-side).
- Tone: reassuring, brief, actionable; offer WhatsApp as a human fallback for repeated failures.
- `role="alert"` for errors, `role="status"` for success.

## 9. Notification guidelines (future app)
- Respect time-sensitivity (class start) vs. promotional (offers — opt-in).
- Frequency caps; never guilt-trip ("you've been away…"); celebrate gently.
- Honour quiet hours and per-type channels (Android) / categories (iOS).

## 10. Governance
- All strings in `lib/content.ts`; PRs touching copy reviewed against this doc.
- Sanskrit verified for accuracy; founder/credentials/claims must be true (risk K5, `03 §17`).
- Future i18n: keep sentences whole (no concatenation), ready for locale files (`09 §9`).
