import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { pageMeta, absUrl } from "@/lib/seo";
import {
  disciplines,
  disciplineSlug,
  getDisciplineBySlug,
  site,
} from "@/lib/content";
import PageHeader from "@/components/layout/PageHeader";
import ServiceCard from "@/components/cards/ServiceCard";
import CtaLink from "@/components/ui/CtaLink";

export function generateStaticParams() {
  return disciplines.map((d) => ({ slug: disciplineSlug(d) }));
}

export function generateMetadata({ params }: { params: { slug: string } }): Metadata {
  const d = getDisciplineBySlug(params.slug);
  if (!d) return pageMeta({ title: "Service not found", description: "", path: `/services/${params.slug}` });
  return pageMeta({
    title: d.title,
    description: d.description,
    path: `/services/${params.slug}`,
  });
}

export default function ServiceDetail({ params }: { params: { slug: string } }) {
  const d = getDisciplineBySlug(params.slug);
  if (!d) notFound();

  const related = disciplines.filter((x) => x.title !== d.title).slice(0, 3);

  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "Service",
    name: d.title,
    description: d.description,
    serviceType: d.title,
    areaServed: "Lucknow",
    provider: { "@type": "Organization", name: site.full, url: absUrl("/") },
    url: absUrl(`/services/${params.slug}`),
  };

  return (
    <>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />
      <PageHeader
        eyebrow={d.intention}
        title={d.title}
        intro={d.description}
        trail={[
          { label: "Services", href: "/services" },
          { label: d.title, href: `/services/${params.slug}` },
        ]}
      >
        <div className="flex flex-wrap gap-2">
          {d.tags.map((t) => (
            <span
              key={t}
              className="border border-[var(--line-dark)] px-3 py-1.5 font-mono text-[9px] uppercase tracking-wide text-ember"
            >
              {t}
            </span>
          ))}
        </div>
      </PageHeader>

      <section className="bg-void px-6 py-20 md:px-10 md:py-28">
        <div className="mx-auto grid max-w-6xl gap-12 md:grid-cols-[1.4fr_1fr] md:gap-20">
          <div className="space-y-6 font-body text-[16px] leading-[1.85] text-mist">
            <p>{d.description}</p>
            <p>
              Sessions are guided from start to finish and paced to your level —
              whether you are a complete beginner or returning to a long practice.
              Tell us your goals when you enquire and we&apos;ll place you in the
              batch that fits, and shape the work around your body.
            </p>
            <div className="flex flex-wrap gap-4 pt-4">
              <CtaLink href="/contact">Enquire about {d.title}</CtaLink>
              <CtaLink href="/schedule" variant="ghost">See the schedule →</CtaLink>
            </div>
          </div>
          <aside className="border border-[var(--line-dark)] p-8">
            <p className="eyebrow mb-5 text-ember">At a glance</p>
            <dl className="space-y-4 font-body text-[14px] text-mist">
              <div>
                <dt className="font-mono text-[10px] uppercase tracking-wide text-bone">Intention</dt>
                <dd className="mt-1">{d.intention}</dd>
              </div>
              <div>
                <dt className="font-mono text-[10px] uppercase tracking-wide text-bone">Best for</dt>
                <dd className="mt-1">{d.tags.join(" · ")}</dd>
              </div>
              <div>
                <dt className="font-mono text-[10px] uppercase tracking-wide text-bone">Where</dt>
                <dd className="mt-1">{site.city}</dd>
              </div>
            </dl>
          </aside>
        </div>
      </section>

      <section className="border-t border-[var(--line-dark)] bg-void px-6 py-20 md:px-10 md:py-28">
        <div className="mx-auto max-w-6xl">
          <p className="eyebrow mb-10 text-ember">Continue exploring</p>
          <div className="grid gap-5 md:grid-cols-3">
            {related.map((r) => (
              <ServiceCard key={r.title} d={r} />
            ))}
          </div>
        </div>
      </section>
    </>
  );
}
