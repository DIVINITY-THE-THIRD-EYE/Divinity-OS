import type { Metadata } from "next";
import { pageMeta, buildFaqJsonLd } from "@/lib/seo";
import { faqs } from "@/lib/content";
import PageHeader from "@/components/layout/PageHeader";
import Faq from "@/components/Faq";

export const metadata: Metadata = pageMeta({
  title: "Frequently Asked Questions",
  description:
    "Answers to common questions about practising at Divinity — The Third Eye: getting started, payments, injuries, and where we are.",
  path: "/faq",
});

export default function FaqPage() {
  const jsonLd = buildFaqJsonLd(faqs);

  return (
    <>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />
      <PageHeader
        eyebrow="Before you begin"
        title="Questions,"
        titleAccent="answered."
        intro="Everything most people ask before their first class. Still curious? Reach out directly."
        trail={[{ label: "FAQ", href: "/faq" }]}
      />
      <Faq showHeading={false} />
    </>
  );
}
