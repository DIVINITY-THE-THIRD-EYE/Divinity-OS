import { site, disciplines, locationConfig } from "@/lib/content";
import { buildLocalBusinessJsonLd } from "@/lib/seo";

/**
 * Site-wide structured data — LocalBusiness only. FAQPage/Course schema
 * moved to the specific pages whose visible content they describe (/faq,
 * each program page) — emitting FAQPage/Course on every route regardless of
 * what's actually on that page is the kind of mismatch Google's structured
 * data guidelines flag (14_SEO.md).
 */
export default function JsonLd({ site: siteProp }: { site?: typeof site }) {
  const activeSite = siteProp || site;
  const data = {
    ...buildLocalBusinessJsonLd(activeSite, {
      latitude: locationConfig.latitude,
      longitude: locationConfig.longitude,
    }),
    knowsAbout: disciplines.map((d) => d.title),
  };

  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }}
    />
  );
}
