import { site, faqs, disciplines } from "@/lib/content";

export default function JsonLd() {
  const data = [
    {
      "@context": "https://schema.org",
      "@type": ["HealthAndBeautyBusiness", "SportsActivityLocation"],
      name: site.full,
      description:
        "A yoga, fitness and wellness academy in Lucknow guiding body and mind toward balance through breath, movement and stillness.",
      url: site.url,
      telephone: site.phone,
      founder: { "@type": "Person", name: site.founder },
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
      provider: { "@type": "Organization", name: site.full, sameAs: site.url },
    },
  ];

  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }}
    />
  );
}
