import { site, faqs, disciplines } from "@/lib/content";

export default function JsonLd({ site: siteProp }: { site?: typeof site }) {
  const activeSite = siteProp || site;
  const data = [
    {
      "@context": "https://schema.org",
      "@type": ["HealthAndBeautyBusiness", "SportsActivityLocation"],
      name: activeSite.full,
      description:
        `A yoga, fitness and wellness academy in Lucknow guiding body and mind toward balance through breath, movement and stillness, founded by ${activeSite.founder}.`,
      url: activeSite.url,
      telephone: activeSite.phone,
      founder: { "@type": "Person", name: activeSite.founder },
      address: {
        "@type": "PostalAddress",
        addressLocality: "Lucknow",
        addressRegion: "Uttar Pradesh",
        addressCountry: "IN",
      },
      areaServed: "Lucknow",
      knowsAbout: disciplines.map((d) => d.title),
    },
    {
      "@context": "https://schema.org",
      "@type": "FAQPage",
      mainEntity: faqs.map((f) => ({
        "@type": "Question",
        name: f.q,
        acceptedAnswer: { "@type": "Answer", text: f.a },
      })),
    },
    {
      "@context": "https://schema.org",
      "@type": "Course",
      name: "Yoga, Fitness & Wellness Programs",
      description:
        "Hatha & Vinyasa yoga, fitness training, therapeutic yoga, pranayama, and wellness programs.",
      provider: { "@type": "Organization", name: activeSite.full, sameAs: activeSite.url },
    },
  ];

  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }}
    />
  );
}
