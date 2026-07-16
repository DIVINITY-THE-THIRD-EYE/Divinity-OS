import type { Discipline } from "@/content/programs";
import PageHeader from "@/components/layout/PageHeader";
import CtaLink from "@/components/ui/CtaLink";
import { introOffer } from "@/content/offers";

/**
 * Deep-page template for a single discipline (08_CORE_PAGES.md). Fed by a
 * `content/programs.ts` entry — any discipline with `longDescription`/
 * `whoFor` filled in can get a page like this with no new component code.
 */
export default function ProgramDetail({
  discipline,
  city,
}: {
  discipline: Discipline;
  city: string;
}) {
  const d = discipline;
  const slug = d.slug ?? "";

  return (
    <>
      <PageHeader
        eyebrow={d.intention}
        title={d.title}
        intro={d.longDescription ?? d.description}
        trail={[
          { label: "Programs", href: "/programs" },
          { label: d.title, href: `/programs/${slug}` },
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
            <p>{d.longDescription ?? d.description}</p>

            {d.whoFor && (
              <div className="border-t border-[var(--line)] pt-6">
                <p className="font-mono text-[10px] uppercase tracking-wide text-fg">
                  Who this is for
                </p>
                <p className="mt-3">{d.whoFor}</p>
              </div>
            )}

            {d.sessions && d.sessions.length > 0 && (
              <div className="border-t border-[var(--line)] pt-6">
                <p className="font-mono text-[10px] uppercase tracking-wide text-fg">
                  Sessions
                </p>
                <ul className="mt-3 space-y-2">
                  {d.sessions.map((s) => (
                    <li key={s} className="flex items-start gap-3">
                      <span className="mt-2 h-1 w-1 shrink-0 rounded-full bg-accent" />
                      {s}
                    </li>
                  ))}
                </ul>
              </div>
            )}

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
                <dd className="mt-1">{city}</dd>
              </div>
            </dl>
          </aside>
        </div>
      </section>

      <section className="border-t border-[var(--line)] bg-surface px-6 py-24 text-center md:px-10 md:py-32">
        <p className="eyebrow mb-5 text-accent">Begin today</p>
        <h2 className="mx-auto max-w-2xl font-display text-[clamp(30px,4.5vw,56px)] font-light leading-tight tracking-tight text-fg">
          {introOffer.price} for your <em className="text-accent">{introOffer.duration}.</em>
        </h2>
        <div className="mt-9 flex justify-center">
          <CtaLink href="/contact">Book a first class</CtaLink>
        </div>
      </section>
    </>
  );
}
