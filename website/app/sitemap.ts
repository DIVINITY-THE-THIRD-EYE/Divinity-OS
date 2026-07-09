import type { MetadataRoute } from "next";
import {
  disciplines,
  disciplineSlug,
  posts,
  events,
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
    { path: "/schedule", priority: 0.8, changeFrequency: "weekly" },
    { path: "/trainers", priority: 0.7, changeFrequency: "monthly" },
    { path: "/gallery", priority: 0.6, changeFrequency: "monthly" },
    { path: "/blog", priority: 0.7, changeFrequency: "weekly" },
    { path: "/events", priority: 0.7, changeFrequency: "weekly" },
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

  for (const p of posts) {
    entries.push({
      url: `${base}/blog/${p.slug}`,
      lastModified: new Date(p.date),
      changeFrequency: "yearly",
      priority: 0.5,
    });
  }

  for (const e of events) {
    entries.push({
      url: `${base}/events/${e.slug}`,
      lastModified: new Date(e.date),
      changeFrequency: "yearly",
      priority: 0.5,
    });
  }

  return entries;
}
