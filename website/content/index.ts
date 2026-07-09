// Single source of truth for site content. Every module here holds one slice
// of editable business data — edit the file, the whole site updates.
// lib/content.ts re-exports this under the legacy flat names so existing
// imports (`@/lib/content`) keep working unchanged.

export * from "./site";
export * from "./contact";
export * from "./social";
export * from "./founder";
export * from "./trainers";
export * from "./programs";
export * from "./pricing";
export * from "./offers";
export * from "./statistics";
export * from "./testimonials";
export * from "./gallery";
export * from "./events";
export * from "./posts";
export * from "./faq";
export * from "./schedule";
export * from "./seo";
export * from "./legal";
export * from "./marketing";
