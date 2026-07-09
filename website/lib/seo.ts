import type { Metadata } from "next";
import { site } from "./content";

/**
 * Per-page metadata builder. metadataBase is set in the root layout, so
 * canonical/OG URLs resolve from the relative `path`.
 */
export function pageMeta(
  opts: {
    title: string;
    description: string;
    path: string;
    type?: "website" | "article";
    image?: string;
    // BD-003 (PLACEHOLDERS.md): blog/events/testimonials ship noindex until
    // real content replaces the staging placeholders — the owner flips this
    // per-page when that happens, no code change needed elsewhere.
    noindex?: boolean;
  },
  siteProp?: typeof site
): Metadata {
  const activeSite = siteProp || site;
  const base = activeSite.url.replace(/\/$/, "");
  const { title, description, path, type = "website", image, noindex } = opts;
  const fullTitle = title === activeSite.full ? title : `${title} · ${activeSite.full}`;
  const url = path === "/" ? base + "/" : `${base}${path}`;
  return {
    title: fullTitle,
    description,
    alternates: { canonical: path },
    ...(noindex ? { robots: { index: false, follow: true } } : {}),
    openGraph: {
      title: fullTitle,
      description,
      url,
      siteName: activeSite.full,
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
export const absUrl = (path: string, siteProp?: typeof site) => {
  const activeSite = siteProp || site;
  const base = activeSite.url.replace(/\/$/, "");
  return path === "/" ? base + "/" : `${base}${path}`;
};
