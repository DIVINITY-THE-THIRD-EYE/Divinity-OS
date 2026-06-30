import type { Metadata } from "next";
import { site } from "./content";

const BASE = site.url.replace(/\/$/, "");

/**
 * Per-page metadata builder. metadataBase is set in the root layout, so
 * canonical/OG URLs resolve from the relative `path`.
 */
export function pageMeta(opts: {
  title: string;
  description: string;
  path: string;
  type?: "website" | "article";
  image?: string;
}): Metadata {
  const { title, description, path, type = "website", image } = opts;
  const fullTitle = title === site.full ? title : `${title} · ${site.full}`;
  const url = path === "/" ? BASE + "/" : `${BASE}${path}`;
  return {
    title: fullTitle,
    description,
    alternates: { canonical: path },
    openGraph: {
      title: fullTitle,
      description,
      url,
      siteName: site.full,
      type,
      locale: "en_IN",
      ...(image ? { images: [{ url: image }] } : {}),
    },
    twitter: {
      card: "summary_large_image",
      title: fullTitle,
      description,
    },
  };
}

/** Absolute URL for a path (for structured data). */
export const absUrl = (path: string) =>
  path === "/" ? BASE + "/" : `${BASE}${path}`;
