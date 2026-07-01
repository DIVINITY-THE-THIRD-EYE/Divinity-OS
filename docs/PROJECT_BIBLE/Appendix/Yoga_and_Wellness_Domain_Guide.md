# Appendix — Yoga & Wellness Domain Guide

> Domain knowledge that doesn't fit the engineering phases but is essential to model the product correctly. Grounded in the website's concept/content; items not in the repo are `[Needs Verification]`.

## The practice & concept

The academy is breath-centred. **Pranayama (breath control)** is treated as the heart of the practice and the product's organizing metaphor ("Breathe"). The hero is literally a breathing guide on a real cadence — **inhale 4s · hold 4s · exhale 6s** — inviting visitors to breathe along.

## The Method (signature sequence)

**Align → Awaken → Ascend.** This is the one place numbering is used on the site, because it's a real progression:
1. **Align** — establish posture/foundation/breath.
2. **Awaken** — activate energy/movement.
3. **Ascend** — deepen toward stillness/elevation.

## Disciplines (offerings)

Grouped by **intention**, not decorative numbering:
- **For the body** — physical/asana-focused practice.
- **For the breath** — pranayama/breathwork.
- **For healing** — therapeutic/restorative practice.

> Exact class list, levels, and durations are CMS/content-driven (`discipline.ts` schema, `lib/content.ts`) and partly `[Needs Verification]`. Treat the three intentions as the taxonomy.

## Class / batch model (how the software sees it)

- A **batch** = a scheduled class group with a **location** (lat/long + radius) and time (`batches` table).
- Students **enroll** into batches; **attendance** is geofenced (must be physically present within the radius).
- **Holidays** suspend the schedule (`holidays`).
- **Therapeutic logs** capture per-student therapeutic/diet guidance with trainer comments.
- **Transformation scores** track each student's progress ("The Third Eye").

## Therapeutic / wellness programs

The academy positions itself as wellness (not just fitness): therapeutic logs + diet guidance + progress tracking suggest individualized programs. Structured diet/workout-plan entities are a **future** consideration (`[Needs Verification]`) — today this is expressed via therapeutic logs.

## Trainer certifications

`[Needs Verification]`: certification/qualification data is not modeled in the schema. The website has a Trainers page (`app/trainers`) with trainer cards; certification details should be added to content + possibly the data model if needed for trust/compliance.

## Safety considerations (product-relevant)

- Onboarding collects **health information** and an **emergency contact** — these exist so trainers can practice safely with each student. Handle as sensitive data ([26_Compliance_Legal](../26_Compliance_Legal.md)).
- Geofencing ensures attendance reflects real presence (safety + integrity).
- Reduced-motion and accessibility floors make the digital experience safe/inclusive too.

## Domain vocabulary

See [GLOSSARY](../GLOSSARY.md) for: pranayama, Method, Disciplines, batch, transformation score, therapeutic log. Add academy-specific class names here as they're confirmed.
