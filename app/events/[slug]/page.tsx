import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { pageMeta, absUrl } from "@/lib/seo";
import { events, getEventBySlug, site } from "@/lib/content";
import PageHeader from "@/components/layout/PageHeader";
import CtaLink from "@/components/ui/CtaLink";

export function generateStaticParams() {
  return events.map((e) => ({ slug: e.slug }));
}

export function generateMetadata({ params }: { params: { slug: string } }): Metadata {
  const e = getEventBySlug(params.slug);
  if (!e) return pageMeta({ title: "Event not found", description: "", path: `/events/${params.slug}` });
  return pageMeta({
    title: e.title,
    description: e.summary,
    path: `/events/${params.slug}`,
    type: "article",
    image: e.cover,
  });
}

export default function EventDetail({ params }: { params: { slug: string } }) {
  const e = getEventBySlug(params.slug);
  if (!e) notFound();

  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "Event",
    name: e.title,
    description: e.summary,
    startDate: e.date,
    ...(e.endDate ? { endDate: e.endDate } : {}),
    eventAttendanceMode: "https://schema.org/OfflineEventAttendanceMode",
    location: { "@type": "Place", name: e.location, address: site.city },
    organizer: { "@type": "Organization", name: site.full, url: absUrl("/") },
    url: absUrl(`/events/${e.slug}`),
  };

  return (
    <>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />
      <PageHeader
        eyebrow={new Date(e.date).toLocaleDateString("en-IN", { day: "numeric", month: "long", year: "numeric" })}
        title={e.title}
        intro={e.summary}
        trail={[
          { label: "Events", href: "/events" },
          { label: e.title, href: `/events/${e.slug}` },
        ]}
      >
        <p className="font-mono text-[11px] uppercase tracking-wide text-mist">{e.location}</p>
      </PageHeader>
      <section className="bg-void px-6 py-20 md:px-10 md:py-28">
        <div className="mx-auto max-w-2xl space-y-6 font-body text-[16px] leading-[1.85] text-mist">
          {e.body.split("\n\n").map((para, i) => (
            <p key={i}>{para}</p>
          ))}
          <div className="flex flex-wrap gap-4 pt-6">
            <CtaLink href="/contact">Reserve a place</CtaLink>
            <CtaLink href="/events" variant="ghost">← All events</CtaLink>
          </div>
        </div>
      </section>
    </>
  );
}
