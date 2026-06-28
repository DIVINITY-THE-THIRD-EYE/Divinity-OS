import type { MetadataRoute } from "next";
import { site } from "@/lib/content";

export default function manifest(): MetadataRoute.Manifest {
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
