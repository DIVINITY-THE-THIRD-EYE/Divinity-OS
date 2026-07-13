// Real member stories only. Staging placeholders until verified testimonials
// are collected — the UI shows a polished "coming soon" state rather than
// fabricated quotes.

import { stripStaging } from "@/lib/staging";

export type Testimonial = {
  quote: string;
  name: string;
  meta: string;
};

// TODO(PH-006): replace with real, permissioned quotes before launch.
// Staging placeholders render only when NEXT_PUBLIC_SHOW_STAGING=1 (staging
// env). In production the fallback is empty, so home's Voices carousel is
// omitted (page gates on length) and the empty states take over — visitors
// never see "[STAGING CONTENT]". See stripStaging() in lib/staging.ts.
const stagingTestimonials: Testimonial[] = [
  {
    quote: "[STAGING CONTENT] This is a high-quality demonstration testimonial. It represents how student stories will be displayed. Real member reflections will be loaded via Sanity CMS.",
    name: "Staging Member A",
    meta: "Staging Testimonial",
  },
  {
    quote: "[STAGING CONTENT] This is a high-quality demonstration testimonial. It shows the layout for batch-specific feedback. Real student words will be synced from the CMS before public launch.",
    name: "Staging Member B",
    meta: "Staging Testimonial",
  },
  {
    quote: "[STAGING CONTENT] This is a high-quality demonstration testimonial. It outlines how therapeutic-session feedback will be structured. Real testimonials will be published once consented.",
    name: "Staging Member C",
    meta: "Staging Testimonial",
  },
];

export const testimonials: Testimonial[] = stripStaging(stagingTestimonials, ["quote"]);
