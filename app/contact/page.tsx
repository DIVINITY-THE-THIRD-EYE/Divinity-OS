import type { Metadata } from "next";
import { pageMeta } from "@/lib/seo";
import { site } from "@/lib/content";
import { waHref } from "@/lib/links";
import PageHeader from "@/components/layout/PageHeader";
import Contact from "@/components/Contact";
import Faq from "@/components/Faq";

export const metadata: Metadata = pageMeta({
  title: "Contact & Enquire",
  description: `Get in touch with ${site.full} in ${site.city} — book a class, ask about a practice, or plan your first visit.`,
  path: "/contact",
});

export default function ContactPage() {
  return (
    <>
      <PageHeader
        eyebrow="Begin today"
        title="Let's start with a"
        titleAccent="hello."
        intro="Tell us where you are and what you're looking for. We'll reply with the best batch for you and the simplest way to begin."
        trail={[{ label: "Contact", href: "/contact" }]}
      >
        <div className="flex flex-wrap gap-x-8 gap-y-3 font-mono text-[11px] uppercase tracking-wide text-mist">
          <a href={waHref("Namaste — I'd like to enquire about Divinity.")} target="_blank" rel="noopener noreferrer" className="transition-colors hover:text-ember">
            WhatsApp
          </a>
          <a href={site.instagram} target="_blank" rel="noopener noreferrer" className="transition-colors hover:text-ember">
            Instagram
          </a>
          <span className="text-mist/70">{site.city}</span>
        </div>
      </PageHeader>
      <Contact />
      <Faq />
    </>
  );
}
