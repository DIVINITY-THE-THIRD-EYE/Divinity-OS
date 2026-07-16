import type { Metadata } from "next";
import Link from "next/link";
import { pageMeta } from "@/lib/seo";
import { events, upcomingEvents } from "@/lib/content";
import PageHeader from "@/components/layout/PageHeader";
import EmptyState from "@/components/ui/EmptyState";

export const metadata: Metadata = pageMeta({
  title: "Events & Workshops",
  description:
    "Workshops, retreats and community gatherings at Divinity — The Third Eye in Lucknow. See what's coming next.",
  path: "/events",
  // BD-003: all current entries are staging placeholders (see content/events.ts),
  // not real events — noindex until PH-011 is resolved with real ones.
  noindex: true,
});

function fmt(date: string) {
  return new Date(date).toLocaleDateString("en-IN", { day: "numeric", month: "long", year: "numeric" });
}

export default function EventsPage() {
  const upcoming = upcomingEvents();
  const past = events
    .filter((e) => !upcoming.includes(e))
    .sort((a, b) => +new Date(b.date) - +new Date(a.date));

  return (
    <>
      <PageHeader
        eyebrow="What's next"
        title="Gather, learn,"
        titleAccent="grow."
        intro="Deep-dive workshops, seasonal retreats and community days. Reserve early — places are limited and fill quickly."
        trail={[{ label: "Events", href: "/events" }]}
      />

      <section className="bg-surface px-6 py-20 md:px-10 md:py-28">
        <div className="mx-auto max-w-6xl space-y-16">
          {upcoming.length > 0 ? (
            <div>
              <p className="eyebrow mb-8 text-accent">Upcoming</p>
              <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
                {upcoming.map((e) => (
                  <Link
                    key={e.slug}
                    href={`/events/${e.slug}`}
                    data-hover
                    className="group flex flex-col border border-[var(--line)] p-7 transition-colors hover:border-ember/40"
                  >
                    <p className="font-mono text-[10px] uppercase tracking-wide text-accent">{fmt(e.date)}</p>
                    <h2 className="mt-3 font-display text-2xl leading-tight text-fg">{e.title}</h2>
                    <p className="mt-3 font-body text-[14px] leading-[1.8] text-fg-muted">{e.summary}</p>
                    <p className="mt-5 font-mono text-[10px] uppercase tracking-wide text-fg-muted">{e.location}</p>
                  </Link>
                ))}
              </div>
            </div>
          ) : (
            <EmptyState
              title="No events scheduled yet"
              message="We're planning our first workshops and retreats. Join the mailing list and you'll be the first to know when dates open."
              cta={{ href: "/contact", label: "Notify me" }}
            />
          )}

          {past.length > 0 && (
            <div>
              <p className="eyebrow mb-8 text-fg-muted">Past gatherings</p>
              <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
                {past.map((e) => (
                  <Link
                    key={e.slug}
                    href={`/events/${e.slug}`}
                    className="flex flex-col border border-[var(--line)] p-7 opacity-70 transition-opacity hover:opacity-100"
                  >
                    <p className="font-mono text-[10px] uppercase tracking-wide text-fg-muted">{fmt(e.date)}</p>
                    <h3 className="mt-3 font-display text-xl leading-tight text-fg">{e.title}</h3>
                  </Link>
                ))}
              </div>
            </div>
          )}
        </div>
      </section>
    </>
  );
}
