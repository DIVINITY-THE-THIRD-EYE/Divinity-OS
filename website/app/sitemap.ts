import type { MetadataRoute } from "next";
import {
  disciplines,
  disciplineSlug,
  fetchSiteSettings,
} from "@/lib/content";

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const site = await fetchSiteSettings();
  const base = site.url.replace(/\/$/, "");
  const now = new Date();

  const staticPaths: { path: string; priority: number; changeFrequency: MetadataRoute.Sitemap[number]["changeFrequency"] }[] = [
    { path: "/", priority: 1, changeFrequency: "monthly" },
    { path: "/about", priority: 0.8, changeFrequency: "monthly" },
    { path: "/programs", priority: 0.9, changeFrequency: "monthly" },
    { path: "/founder", priority: 0.6, changeFrequency: "monthly" },
    { path: "/pricing", priority: 0.9, changeFrequency: "monthly" },
    { path: "/membership", priority: 0.6, changeFrequency: "monthly" },
    { path: "/schedule", priority: 0.8, changeFrequency: "weekly" },
    { path: "/trainers", priority: 0.7, changeFrequency: "monthly" },
    { path: "/gallery", priority: 0.6, changeFrequency: "monthly" },
    { path: "/faq", priority: 0.6, changeFrequency: "monthly" },
    // /blog, /events, /events/[slug], /blog/[slug] and /testimonials are
    // deliberately excluded — all noindex (BD-003, staging placeholder
    // content, see PLACEHOLDERS.md PH-006/011/012). A sitemap entry for a
    // noindex page is a contradictory crawl signal.
    { path: "/contact", priority: 0.8, changeFrequency: "yearly" },
    { path: "/verify", priority: 0.4, changeFrequency: "yearly" },
    { path: "/privacy", priority: 0.3, changeFrequency: "yearly" },
    { path: "/terms", priority: 0.3, changeFrequency: "yearly" },
  ];

  const entries: MetadataRoute.Sitemap = staticPaths.map((p) => ({
    url: p.path === "/" ? base + "/" : base + p.path,
    lastModified: now,
    changeFrequency: p.changeFrequency,
    priority: p.priority,
  }));

  for (const d of disciplines) {
    entries.push({
      url: `${base}/programs/${d.slug ?? disciplineSlug(d)}`,
      lastModified: now,
      changeFrequency: "monthly",
      priority: 0.6,
    });
  }

  // Blog/event detail pages are noindex too (same BD-003 staging-content
  // reason as the listing pages above) — not added here.

  return entries;
}
