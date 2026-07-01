import type { MetadataRoute } from "next";
import { fetchSiteSettings } from "@/lib/content";

export default async function robots(): Promise<MetadataRoute.Robots> {
  const site = await fetchSiteSettings();
  const base = site.url.replace(/\/$/, "");
  return {
    rules: { userAgent: "*", allow: "/", disallow: "/api/" },
    sitemap: `${base}/sitemap.xml`,
  };
}
