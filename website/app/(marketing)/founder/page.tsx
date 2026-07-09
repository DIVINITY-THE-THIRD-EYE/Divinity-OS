import type { Metadata } from "next";
import Image from "next/image";
import { pageMeta } from "@/lib/seo";
import { fetchSiteSettings } from "@/lib/content";
import { founder } from "@/content/founder";
import PageHeader from "@/components/layout/PageHeader";
import CtaLink from "@/components/ui/CtaLink";

export async function generateMetadata(): Promise<Metadata> {
  const site = await fetchSiteSettings();
  return pageMeta({
    title: founder.name,
    description: `${founder.title} of ${site.full} — ${founder.bio}`,
    path: "/founder",
  });
}

export default async function FounderPage() {
  const site = await fetchSiteSettings();

  return (
    <>
      <PageHeader
        eyebrow="The founder"
        title="Guided by"
        titleAccent={founder.name}
        intro={`${founder.title} of ${site.full}, in ${site.city || "Lucknow"}.`}
        trail={[{ label: "Founder", href: "/founder" }]}
      />

      <section className="bg-surface px-6 py-20 md:px-10 md:py-28">
        <div className="mx-auto grid max-w-6xl gap-12 md:grid-cols-[0.9fr_1.3fr] md:items-start md:gap-16">
          <div className="relative aspect-[3/4] w-full overflow-hidden">
            <Image
              src={founder.image}
              alt={`${founder.name}, ${founder.title}`}
              fill
              sizes="(max-width: 768px) 90vw, 420px"
              className="object-cover grayscale-[0.1]"
              priority
            />
          </div>

          <div className="space-y-6 font-body text-[16px] leading-[1.85] text-fg-muted">
            <p>{founder.bio}</p>

            {founder.credentials.length > 0 && (
              <div className="border-t border-[var(--line)] pt-6">
                <p className="font-mono text-[10px] uppercase tracking-wide text-fg">
                  Credentials
                </p>
                <ul className="mt-4 space-y-2">
                  {founder.credentials.map((c) => (
                    <li key={c} className="flex items-start gap-3">
                      <span className="mt-2 h-1 w-1 shrink-0 rounded-full bg-accent" />
                      {c}
                    </li>
                  ))}
                </ul>
              </div>
            )}

            <div className="flex flex-wrap gap-4 pt-4">
              <CtaLink href="/trainers">Meet the full team →</CtaLink>
              <CtaLink href="/contact" variant="ghost">Ask a question →</CtaLink>
            </div>
          </div>
        </div>
      </section>

      <section className="border-t border-[var(--line)] bg-surface px-6 py-24 text-center md:px-10 md:py-32">
        <h2 className="mx-auto max-w-2xl font-display text-[clamp(30px,4.5vw,56px)] font-light leading-tight tracking-tight text-fg">
          Practise with <em className="text-accent">{founder.name.split(" ")[0]}.</em>
        </h2>
        <div className="mt-9 flex justify-center">
          <CtaLink href="/schedule">See the schedule</CtaLink>
        </div>
      </section>
    </>
  );
}
