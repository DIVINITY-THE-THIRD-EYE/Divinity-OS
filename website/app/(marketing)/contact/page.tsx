import type { Metadata } from "next";
import { pageMeta } from "@/lib/seo";
import { fetchSiteSettings } from "@/lib/content";
import { waHref } from "@/lib/links";
import PageHeader from "@/components/layout/PageHeader";
import Contact from "@/components/Contact";
import Faq from "@/components/Faq";

export async function generateMetadata(): Promise<Metadata> {
  const site = await fetchSiteSettings();
  return pageMeta({
    title: "Contact & Enquire",
    description: `Get in touch with ${site.full} in ${site.city} — book a class, ask about a practice, or plan your first visit.`,
    path: "/contact",
  });
}

export default async function ContactPage() {
  const site = await fetchSiteSettings();
  return (
    <>
      <PageHeader
        eyebrow="Begin today"
        title="Let's start with a"
        titleAccent="hello."
        intro="Tell us where you are and what you're looking for. We'll reply with the best batch for you and the simplest way to begin."
        trail={[{ label: "Contact", href: "/contact" }]}
      >
        <div className="flex flex-wrap gap-x-8 gap-y-3 font-mono text-[11px] uppercase tracking-wide text-fg-muted">
          <a href={waHref("Namaste — I'd like to enquire about Divinity.", site.whatsapp)} target="_blank" rel="noopener noreferrer" className="transition-colors hover:text-accent">
            WhatsApp
          </a>
          <a href={site.instagram} target="_blank" rel="noopener noreferrer" className="transition-colors hover:text-accent">
            Instagram
          </a>
          <span className="text-fg-muted/70">{site.city}</span>
        </div>
      </PageHeader>
      <Contact site={site} />
      <Faq />
    </>
  );
}
