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

// Pure JSON-LD builders (14_SEO.md Step 3) — plain objects, no React, so
// they're directly unit-testable with JSON.parse(JSON.stringify(...)) +
// required-field assertions, and reused instead of duplicated inline per page.

/** Site-wide LocalBusiness (rendered once, in the root layout — JsonLd.tsx). */
export function buildLocalBusinessJsonLd(
  activeSite: typeof site,
  geo?: { latitude: number; longitude: number }
) {
  return {
    "@context": "https://schema.org",
    "@type": ["HealthAndBeautyBusiness", "SportsActivityLocation"],
    name: activeSite.full,
    description: `A yoga, fitness and wellness academy in Lucknow guiding body and mind toward balance through breath, movement and stillness, founded by ${activeSite.founder}.`,
    url: activeSite.url,
    telephone: activeSite.phone,
    founder: { "@type": "Person", name: activeSite.founder },
    address: {
      "@type": "PostalAddress",
      addressLocality: "Lucknow",
      addressRegion: "Uttar Pradesh",
      addressCountry: "IN",
    },
    ...(geo
      ? { geo: { "@type": "GeoCoordinates", latitude: geo.latitude, longitude: geo.longitude } }
      : {}),
    areaServed: "Lucknow",
    // Studio opening hours (PH-013) are a placeholder — omitted rather than
    // emitted as invalid openingHours structured data.
  };
}

/** Per-page FAQPage — only on /faq, where the same Q&A is visibly rendered. */
export function buildFaqJsonLd(faqs: { q: string; a: string }[]) {
  return {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: faqs.map((f) => ({
      "@type": "Question",
      name: f.q,
      acceptedAnswer: { "@type": "Answer", text: f.a },
    })),
  };
}

/** Per-program-page Course schema. */
export function buildCourseJsonLd(opts: {
  name: string;
  description: string;
  url: string;
  providerName: string;
  providerUrl: string;
}) {
  const { name, description, url, providerName, providerUrl } = opts;
  return {
    "@context": "https://schema.org",
    "@type": "Course",
    name,
    description,
    url,
    provider: { "@type": "Organization", name: providerName, url: providerUrl },
  };
}

/**
 * Person schema for /founder — verified facts only. Any credential wrapped
 * in the project's `[PLACEHOLDER: ...]` convention is filtered out so a
 * placeholder never reaches the index (PROJECT_RULES #3 / 14_SEO.md OUTPUTS).
 */
export function buildPersonJsonLd(opts: {
  name: string;
  jobTitle: string;
  url: string;
  worksForName: string;
  credentials?: string[];
}) {
  const { name, jobTitle, url, worksForName, credentials = [] } = opts;
  const realCredentials = credentials.filter((c) => !c.startsWith("[PLACEHOLDER"));
  return {
    "@context": "https://schema.org",
    "@type": "Person",
    name,
    jobTitle,
    url,
    worksFor: { "@type": "Organization", name: worksForName },
    ...(realCredentials.length > 0 ? { hasCredential: realCredentials } : {}),
  };
}
