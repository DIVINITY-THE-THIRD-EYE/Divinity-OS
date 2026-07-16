import type { Metadata } from "next";
import { pageMeta } from "@/lib/seo";
import { fetchSiteSettings } from "@/lib/content";
import { introOffer } from "@/content/offers";
import PageHeader from "@/components/layout/PageHeader";
import About from "@/components/About";
import Manifesto from "@/components/Manifesto";
import Method from "@/components/Method";
import StatsBand from "@/components/StatsBand";
import CtaLink from "@/components/ui/CtaLink";

export async function generateMetadata(): Promise<Metadata> {
  const site = await fetchSiteSettings();
  return pageMeta({
    title: "About the Academy",
    description: `The story, philosophy and founder behind ${site.full} — a yoga, fitness and wellness academy in ${site.city}.`,
    path: "/about",
  });
}

export default async function AboutPage() {
  const site = await fetchSiteSettings();
  return (
    <>
      <PageHeader
        eyebrow="The academy"
        title="A practice rooted in"
        titleAccent="breath."
        intro={`Divinity — The Third Eye brings traditional yoga, modern fitness and therapeutic care together under one roof in ${site.city || "Lucknow"}. This is our story, our belief, and the path we walk with every student.`}
        trail={[{ label: "About", href: "/about" }]}
      />
      <About site={site} />
      <Manifesto />
      <Method />
      <StatsBand />
      <section className="border-t border-[var(--line)] bg-surface px-6 py-24 text-center md:px-10 md:py-32">
        <p className="eyebrow mb-5 text-accent">Begin today</p>
        <h2 className="mx-auto max-w-2xl font-display text-[clamp(32px,5vw,60px)] font-light leading-tight tracking-tight text-fg">
          Come and feel the <em className="text-accent">space</em> for yourself.
        </h2>
        <p className="mx-auto mt-4 max-w-md font-body text-[14px] leading-relaxed text-fg-muted">
          {introOffer.price} for your {introOffer.duration} — no commitment,
          just a first breath.
        </p>
        <div className="mt-9 flex flex-wrap justify-center gap-4">
          <CtaLink href="/contact">Book a first class</CtaLink>
          <CtaLink href="/founder" variant="ghost">Meet the founder →</CtaLink>
        </div>
      </section>
    </>
  );
}
