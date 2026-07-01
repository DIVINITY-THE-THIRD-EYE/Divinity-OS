# 15 — User Journey Maps

End-to-end journeys. Each: **Goal · User actions · System actions · Emotion · Friction · Opportunity ·
Success metric.** Journeys 1–4 + 8 are **in scope for this site today**; trainer/admin/therapy/teacher-
training/event flows are **future product** (separate app, ADR-0011) and mapped for completeness.

Legend: 🟢 in-scope now · 🔵 future product.

---

## 1. New visitor 🟢
| Stage | Detail |
|---|---|
| Goal | Understand what Divinity is; decide if it's for me |
| User actions | Land on hero → read "Breathe" → scroll Manifesto/About/Disciplines/Gallery |
| System actions | SSG page, breathing hero, scroll reveals, JSON-LD for SEO |
| Emotion | Calm, curious, "this feels premium" |
| Friction | No quick "how do I start?"; first ask is far down (Contact) |
| Opportunity | **PromoBar + hero intro CTA (R1)**, **Stats (R2)**, **StartHere (R4)** |
| Success metric | Scroll depth ≥ 50%, `cta_book` CTR, time-on-page |

## 2. Trial / first-class booking 🟢
| Stage | Detail |
|---|---|
| Goal | Try a class with low commitment |
| User actions | Click "Book your first class" → choose contact (form) or WhatsApp |
| System actions | Contact route → Brevo email (or fallback); WhatsApp deep link prefilled |
| Emotion | Hopeful, slightly cautious |
| Friction | No explicit trial offer today; form is the only path; no instant confirmation of next step |
| Opportunity | **Intro-offer (R1)**, **WhatsApp sticky (R1)**, success state with "what happens next" |
| Success metric | `cta_book`→`contact_submit`/`whatsapp_click` rate; enquiry→reply time |

## 3. Membership purchase 🟢
| Stage | Detail |
|---|---|
| Goal | Pick a plan and pay |
| User actions | Read Membership → use **PlanCalculator** → scan **UPI QR** → screenshot to confirm |
| System actions | Static plans (content/CMS); QR displayed; manual reconciliation by owner |
| Emotion | Evaluating value; wants reassurance |
| Friction | Manual UPI confirmation; no receipt/automation; prices are placeholders |
| Opportunity | **Incentive copy (R8)**, transparent trial terms (P12), real prices; future Razorpay (ADR-0006) |
| Success metric | `plan_calculator_complete`, plan CTA clicks, enquiries citing a plan |

## 4. Returning member 🟢→🔵
| Stage | Detail |
|---|---|
| Goal | Check schedule / re-engage |
| User actions | Open site → Schedule; (future) log into app for bookings |
| System actions | Static weekly schedule; (future) live schedule + auth |
| Emotion | Routine, wants speed |
| Friction | Schedule is static (no live booking); ⌘K helps power users only |
| Opportunity | Newsletter for updates (R3); **future app** for live booking/attendance |
| Success metric | Returning-visitor rate, newsletter open/click |

## 5. Trainer workflow 🔵
Goal: manage classes/attendance. Actions: log in → view roster → mark attendance (QR). System: auth +
Supabase + RLS. Emotion: efficiency. Friction: none today (doesn't exist). Opportunity: future trainer
app (`04`, ADR-0011). Metric: classes managed, attendance accuracy.

## 6. Admin workflow 🔵
Goal: manage members/content/payments. Actions: dashboard → CRUD members, plans, schedule, reconcile
payments. System: admin role (RLS), CMS (Sanity already a seam). Emotion: control. Opportunity: Sanity
Studio for content now; admin app later. Metric: time-to-update content, reconciliation time.

## 7. Event registration 🔵 (light 🟢 via enquiry)
Goal: register for a workshop/event. Now: enquire via Contact/WhatsApp. Future: event detail + ticket +
calendar add (Event schema, `03 §14`). Friction: no dedicated events flow today. Opportunity: dated
Foundations/events (R11) + Event JSON-LD. Metric: event enquiries → confirmed.

## 8. Therapy consultation 🟢 (intake) → 🔵 (scheduling)
Goal: book therapeutic yoga around an injury/condition. Now: Contact form **intention = "Therapeutic
yoga"** routes the enquiry (R9). Emotion: vulnerable — needs trust/care. Friction: no structured intake
(history/limits). Opportunity: typed routing (R9) + a gentle intake prompt; future private-session
scheduling. Metric: therapeutic enquiries, conversion to first session.

## 9. Teacher-training enrolment 🔵
Goal: enrol in YTT/foundations. Now: enquiry only. Future: course detail + cohort dates + application +
deposit (Course schema). Opportunity: dated cohort (R11) + Course JSON-LD (already in `JsonLd`). Metric:
training applications.

---

## Cross-journey insights
1. **Every in-scope journey converges on one weak point: the ask.** R1 (offer + persistent CTA) and R3
   (capture) improve 1–3 and 8 simultaneously.
2. **Therapy (8) needs the most care/trust** — typed routing + reassurance copy (R9, content strategy `19`).
3. **Future journeys (5–7, 9) all require the product backend (ADR-0011)** — keep them out of the static
   site; link out when ready.
