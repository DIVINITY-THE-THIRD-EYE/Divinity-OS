import type { Metadata } from "next";
import { pageMeta } from "@/lib/seo";
import { schedule } from "@/lib/content";
import PageHeader from "@/components/layout/PageHeader";
import Schedule from "@/components/Schedule";
import CtaLink from "@/components/ui/CtaLink";

export const metadata: Metadata = pageMeta({
  title: "Class Schedule",
  description:
    "The weekly rhythm at Divinity — dawn, midday and dusk batches across six days, from Hatha and Vinyasa to strength, pranayama and therapeutic yoga.",
  path: "/schedule",
});

export default function SchedulePage() {
  return (
    <>
      <PageHeader
        eyebrow="Weekly rhythm"
        title="Find your"
        titleAccent="hour."
        intro="Dawn for stillness, dusk for strength. Browse the week below, then enquire about the batch that fits your day."
        trail={[{ label: "Schedule", href: "/schedule" }]}
      />
      <Schedule data={schedule} showHeading={false} />
      <section className="border-t border-[var(--line)] bg-surface px-6 py-24 text-center md:px-10 md:py-32">
        <h2 className="mx-auto max-w-2xl font-display text-[clamp(30px,4.5vw,56px)] font-light leading-tight tracking-tight text-fg">
          Reserve your <em className="text-accent">place.</em>
        </h2>
        <div className="mt-9 flex flex-wrap justify-center gap-4">
          <CtaLink href="/contact">Book a class</CtaLink>
          <CtaLink href="/pricing" variant="ghost">See plans →</CtaLink>
        </div>
      </section>
    </>
  );
}
