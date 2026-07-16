// Structured legal copy. Privacy/Terms text below was migrated verbatim from
// the pre-existing app/privacy and app/terms JSX (real, already-authored
// copy — not fabricated here). Refund policy has no text anywhere yet.

// contactLink: body ends mid-sentence; the page appends a hyperlinked
// "contact page" + period so the link works without HTML in content data.
export type LegalSection = { heading: string; body: string; contactLink?: boolean };

export const legalUpdated = "30 June 2026";

// TODO(PH-010): real text, migrated from the previous privacy/page.tsx JSX.
// Owner: please confirm this is current before launch (see PLACEHOLDERS.md PH-010).
export const privacy: LegalSection[] = [
  {
    heading: "",
    body: "We (“we”, “us”) operate this website. We respect your privacy and collect only what we need to respond to you and run our classes. We never sell your information.",
  },
  {
    heading: "What we collect",
    body: "When you use our contact or newsletter forms we collect the details you choose to share — typically your name, email address, phone number and your message. We do not run third-party advertising trackers, and we use only the essential cookies needed for the site to function.",
  },
  {
    heading: "How we use it",
    body: "We use your details to reply to your enquiry, arrange classes, and — only if you opt in — to send occasional updates about schedules and events. You can unsubscribe from updates at any time.",
  },
  {
    heading: "Who we share it with",
    body: "Form submissions and newsletter emails are delivered through our email provider (Brevo), which processes them on our behalf. Payments are made directly by UPI to our account — we do not collect or store card details on this site. We may disclose information if required by law.",
  },
  {
    heading: "How long we keep it",
    body: "We retain enquiry and member details only for as long as needed to serve you and to meet any legal obligations, after which they are deleted.",
  },
  {
    heading: "Your rights",
    body: "You may ask us to access, correct or delete the personal information we hold about you, or to stop contacting you. To make a request, reach us through our",
    contactLink: true,
  },
  {
    heading: "Children",
    body: "Our services are intended for adults. Minors should practise only with the consent and supervision of a parent or guardian.",
  },
  {
    heading: "Changes",
    body: "We may update this policy from time to time. Any changes will be posted on this page with a revised date above.",
  },
];

// TODO(PH-010): real text, migrated from the previous terms/page.tsx JSX.
// Owner: please confirm this is current before launch (see PLACEHOLDERS.md PH-010).
export const terms: LegalSection[] = [
  {
    heading: "Using this site",
    body: "This website is provided for information about the academy and its classes. We aim to keep details such as schedules and pricing accurate and current, but they may change; please confirm with us before relying on them.",
  },
  {
    heading: "Bookings & payment",
    body: "Class places are confirmed once payment is received. Payments are made by UPI directly to our account — this site does not process card payments. Prices are shown in Indian Rupees and include applicable taxes unless stated otherwise.",
  },
  {
    heading: "Cancellations & refunds",
    body: "If you need to cancel or reschedule, contact us as early as possible. Specific cancellation and refund terms are confirmed at the time of booking.",
  },
  {
    heading: "Health & safety",
    body: "Yoga and fitness involve physical activity. Please tell your teacher about any injury, medical condition or pregnancy before practising, and consult a doctor if you are unsure. You take part at your own discretion and are responsible for working within your limits.",
  },
  {
    heading: "Conduct",
    body: "We ask all members to be respectful of teachers, fellow students and the studio space. We may decline service where conduct is unsafe or disruptive.",
  },
  {
    heading: "Intellectual property",
    body: "The content, branding and imagery on this site belong to the academy and may not be reproduced without permission.",
  },
  {
    heading: "Contact",
    body: "Questions about these terms? Reach us through our",
    contactLink: true,
  },
];

// TODO(PH-009): refund policy text does not exist yet anywhere in the codebase.
export const refund: LegalSection[] = [
  { heading: "Status", body: "[PLACEHOLDER: refund policy — no text exists yet — see PLACEHOLDERS.md PH-009]" },
];
