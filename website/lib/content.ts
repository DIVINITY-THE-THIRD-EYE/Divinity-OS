// Compatibility + merge layer over website/content/ (the real source of
// truth — see content/index.ts). Re-exports everything under the names this
// file used to define directly, so no consumer import needs to change.
// When Sanity is configured (see lib/sanity.ts), matching documents override
// these values; until then, the site renders from content/.

import { fetchOrFallback } from "./sanity";
import { site as siteCore } from "@/content/site";
import { contact, locationConfig } from "@/content/contact";
import { social } from "@/content/social";
import { founder } from "@/content/founder";

export type {
  Discipline,
} from "@/content/programs";
export type { Plan } from "@/content/pricing";
export type { ClassSlot } from "@/content/schedule";
export type { Testimonial } from "@/content/testimonials";
export type { Assurance } from "@/content/marketing";
export type { Trainer } from "@/content/trainers";
export type { Post } from "@/content/posts";
export type { EventItem } from "@/content/events";
export type { GalleryShot } from "@/content/gallery";

export {
  disciplines,
  method,
  slugify,
  disciplineSlug,
  getDisciplineBySlug,
} from "@/content/programs";
export { plans, payment } from "@/content/pricing";
export { schedule } from "@/content/schedule";
export { testimonials } from "@/content/testimonials";
export { mantra, manifestoLines, assurances } from "@/content/marketing";
export { faqs } from "@/content/faq";
export { trainers } from "@/content/trainers";
export { posts, getPostBySlug } from "@/content/posts";
export { events, getEventBySlug, upcomingEvents } from "@/content/events";
export { studioGallery } from "@/content/gallery";
export { locationConfig };

// The legacy flat `site` object — every consumer (`Nav`, `Footer`, `JsonLd`,
// `pageMeta`, ...) expects this exact shape. Assembled from the split
// content/ modules so each fact still has exactly one home.
export const site = {
  name: siteCore.name,
  full: siteCore.full,
  city: siteCore.city,
  entity: siteCore.entity,
  founder: founder.name,
  founderRole: founder.title,
  founderImage: founder.image,
  est: siteCore.est,
  url: siteCore.url,
  logoMark: siteCore.logoMark,
  logoFull: siteCore.logoFull,
  phone: contact.phone,
  whatsapp: contact.whatsapp,
  instagram: social.instagram,
};

export type SiteSettings = typeof site;

const SITE_SETTINGS_Q = `*[_type == "siteSettings"][0]{
  name,
  full,
  city,
  entity,
  founder,
  founderRole,
  founderImage,
  est,
  url,
  phone,
  whatsapp,
  instagram,
  logoMark,
  logoFull
}`;

/** Fetches site settings from Sanity, falling back to local static values. */
export async function fetchSiteSettings(): Promise<SiteSettings> {
  const data = await fetchOrFallback<Partial<SiteSettings>>(SITE_SETTINGS_Q, {});
  // Filter out null or undefined values from CMS to prevent breaking layout
  const cleanData = Object.fromEntries(
    Object.entries(data).filter(([_, v]) => v != null)
  );
  return {
    ...site,
    ...cleanData,
  } as SiteSettings;
}
