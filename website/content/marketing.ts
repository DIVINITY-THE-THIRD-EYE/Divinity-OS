// Brand-voice copy that isn't tied to a single business entity above:
// the kinetic marquee words, the manifesto, and the trust-badge assurances.

import { founder } from "./founder";

// Practice words for the kinetic marquee (a little Sanskrit, on theme)
export const mantra = [
  "Breathe",
  "आसन",
  "Move",
  "प्राण",
  "Heal",
  "ध्यान",
  "Align",
  "Awaken",
  "Ascend",
];

export const manifestoLines = [
  "Before the body moves, the breath moves.",
  "Before the mind settles, the breath settles.",
  "We do not chase the body —",
  "we follow the breath inward,",
  "until practice becomes presence.",
];

// Trust signals / assurance badges. Keep these TRUTHFUL — each one below is
// grounded in a real fact already on this site (verified UPI flow, the founder,
// small batches, a registered LLP, privacy-by-design). Edit freely, but don't
// invent certifications the academy doesn't actually hold.
export type Assurance = {
  icon: "shield" | "guide" | "users" | "lock" | "spark" | "badge";
  title: string;
  detail: string;
};

export const assurances: Assurance[] = [
  {
    icon: "shield",
    title: "Secure UPI payments",
    detail: "Every payment is verified by our team and a receipt is issued — no hidden auto-charges.",
  },
  {
    icon: "guide",
    title: "Guided by the founder",
    detail: `Personal guidance from ${founder.name} and our instructors, not a faceless app.`,
  },
  {
    icon: "users",
    title: "Small, focused batches",
    detail: "Dawn, midday and dusk batches are kept small so you get real, hands-on attention.",
  },
  {
    icon: "lock",
    title: "Your data stays private",
    detail: "Health and contact details are access-controlled and never sold or shared.",
  },
  {
    icon: "spark",
    title: "Risk-free first week",
    detail: "Begin your practice with a ₹99 first week before you commit to a plan.",
  },
  {
    icon: "badge",
    title: "A registered academy",
    detail: "Run by Amaratv Krishi LLP, serving Lucknow since 2024.",
  },
];
