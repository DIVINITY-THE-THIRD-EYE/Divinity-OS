import type { MetadataRoute } from "next";
import { fetchSiteSettings } from "@/lib/content";

export default async function manifest(): Promise<MetadataRoute.Manifest> {
  const site = await fetchSiteSettings();
  return {
    id: "/",
    name: site.full,
    short_name: site.name,
    description:
      "A yoga, fitness and wellness academy in Lucknow — breath, movement and stillness.",
    start_url: "/",
    scope: "/",
    lang: "en-IN",
    categories: ["health", "fitness", "lifestyle"],
    display: "standalone",
    background_color: "#15161e",
    theme_color: "#15161e",
    icons: [
      { src: "/icon.png", sizes: "512x512", type: "image/png", purpose: "any" },
      { src: "/apple-icon.png", sizes: "180x180", type: "image/png" },
    ],
  };
}
