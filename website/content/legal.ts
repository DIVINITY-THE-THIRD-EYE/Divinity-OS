// Structured legal copy. The privacy/terms pages currently render their text
// directly in JSX (app/privacy, app/terms) — migrating that into these
// structured sections happens when those pages are rebuilt (08/11). Refund
// policy doesn't exist anywhere yet.

export type LegalSection = { heading: string; body: string };

// TODO(PH-010): existing privacy copy lives in app/privacy/page.tsx JSX.
export const privacy: LegalSection[] = [
  { heading: "Status", body: "[PLACEHOLDER: privacy policy migration pending — see PLACEHOLDERS.md PH-010]" },
];

// TODO(PH-010): existing terms copy lives in app/terms/page.tsx JSX.
export const terms: LegalSection[] = [
  { heading: "Status", body: "[PLACEHOLDER: terms migration pending — see PLACEHOLDERS.md PH-010]" },
];

// TODO(PH-009): refund policy text does not exist yet anywhere in the codebase.
export const refund: LegalSection[] = [
  { heading: "Status", body: "[PLACEHOLDER: refund policy — no text exists yet — see PLACEHOLDERS.md PH-009]" },
];
