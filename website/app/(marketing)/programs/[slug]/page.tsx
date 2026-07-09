import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { pageMeta, absUrl } from "@/lib/seo";
import {
  disciplines,
  disciplineSlug,
  getDisciplineBySlug,
  fetchSiteSettings,
} from "@/lib/content";
import PageHeader from "@/components/layout/PageHeader";
import ServiceCard from "@/components/cards/ServiceCard";
import CtaLink from "@/components/ui/CtaLink";

// "therapeutic-yoga" has its own static route (app/(marketing)/programs/
// therapeutic-yoga/page.tsx) with richer content (longDescription/whoFor/
// sessions) — Next.js always prefers a static route over this dynamic one
// for that exact path, but generateStaticParams must still exclude it, or
// the build tries to emit two pages for the same output path.
export function generateStaticParams() {
  return disciplines
    .filter((d) => disciplineSlug(d) !== "therapeutic-yoga")
    .map((d) => ({ slug: disciplineSlug(d) }));
}

export function generateMetadata({ params }: { params: { slug: string } }): Metadata {
  const d = getDisciplineBySlug(params.slug);
  if (!d) return pageMeta({ title: "Program not found", description: "", path: `/programs/${params.slug}` });
  return pageMeta({
    title: d.title,
    description: d.description,
    path: `/programs/${params.slug}`,
  });
}

export default async function ServiceDetail({ params }: { params: { slug: string } }) {
  const d = getDisciplineBySlug(params.slug);
  if (!d) notFound();

  const site = await fetchSiteSettings();
  const related = disciplines.filter((x) => x.title !== d.title).slice(0, 3);

  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "Service",
    name: d.title,
    description: d.description,
    serviceType: d.title,
    areaServed: "Lucknow",
    provider: { "@type": "Organization", name: site.full, url: absUrl("/") },
    url: absUrl(`/programs/${params.slug}`),
  };

  return (
    <>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />
      <PageHeader
        eyebrow={d.intention}
        title={d.title}
        intro={d.description}
        trail={[
          { label: "Programs", href: "/programs" },
          { label: d.title, href: `/programs/${params.slug}` },
        ]}
      >
        <div className="flex flex-wrap gap-2">
          {d.tags.map((t) => (
            <span
              key={t}
              className="border border-[var(--line)] px-3 py-1.5 font-mono text-[9px] uppercase tracking-wide text-accent"
            >
              {t}
            </span>
          ))}
        </div>
      </PageHeader>

      <section className="bg-surface px-6 py-20 md:px-10 md:py-28">
        <div className="mx-auto grid max-w-6xl gap-12 md:grid-cols-[1.4fr_1fr] md:gap-20">
          <div className="space-y-6 font-body text-[16px] leading-[1.85] text-fg-muted">
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
          <aside className="border border-[var(--line)] p-8">
            <p className="eyebrow mb-5 text-accent">At a glance</p>
            <dl className="space-y-4 font-body text-[14px] text-fg-muted">
              <div>
                <dt className="font-mono text-[10px] uppercase tracking-wide text-fg">Intention</dt>
                <dd className="mt-1">{d.intention}</dd>
              </div>
              <div>
                <dt className="font-mono text-[10px] uppercase tracking-wide text-fg">Best for</dt>
                <dd className="mt-1">{d.tags.join(" · ")}</dd>
              </div>
              <div>
                <dt className="font-mono text-[10px] uppercase tracking-wide text-fg">Where</dt>
                <dd className="mt-1">{site.city}</dd>
              </div>
            </dl>
          </aside>
        </div>
      </section>

      <section className="border-t border-[var(--line)] bg-surface px-6 py-20 md:px-10 md:py-28">
        <div className="mx-auto max-w-6xl">
          <p className="eyebrow mb-10 text-accent">Continue exploring</p>
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
