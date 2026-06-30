import type { Metadata } from "next";
import { pageMeta } from "@/lib/seo";
import { trainers, site } from "@/lib/content";
import PageHeader from "@/components/layout/PageHeader";
import TrainerCard from "@/components/cards/TrainerCard";
import EmptyState from "@/components/ui/EmptyState";
import CtaLink from "@/components/ui/CtaLink";

export const metadata: Metadata = pageMeta({
  title: "Trainers & Teachers",
  description: `Meet the teachers behind ${site.full} — guiding breath, movement and recovery in ${site.city}.`,
  path: "/trainers",
});

export default function TrainersPage() {
  return (
    <>
      <PageHeader
        eyebrow="Who guides you"
        title="Taught by"
        titleAccent="hand."
        intro="Small batches, close attention. Every session is led personally — your practice is watched, corrected and cared for."
        trail={[{ label: "Trainers", href: "/trainers" }]}
      />

      <section className="bg-void px-6 py-20 md:px-10 md:py-28">
        <div className="mx-auto max-w-6xl">
          {trainers.length > 0 ? (
            <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
              {trainers.map((t) => (
                <TrainerCard key={t.name} t={t} />
              ))}
            </div>
          ) : (
            <EmptyState
              title="Teachers, introduced soon"
              message="Profiles for our teaching team are being prepared. In the meantime, reach out and we'll tell you who you'll be practising with."
              cta={{ href: "/contact", label: "Ask about our teachers" }}
            />
          )}

          {trainers.length > 0 && (
            <p className="mt-12 max-w-2xl font-body text-[14px] leading-relaxed text-mist">
              Our teaching circle grows as the academy does. More teacher profiles
              will be introduced here — with their lineage, focus and the batches
              they lead.
            </p>
          )}
        </div>
      </section>

      <section className="border-t border-[var(--line-dark)] bg-void px-6 py-24 text-center md:px-10 md:py-32">
        <h2 className="font-display text-[clamp(30px,4.5vw,56px)] font-light tracking-tight text-bone">
          Practise with <em className="text-ember">us.</em>
        </h2>
        <div className="mt-9 flex justify-center">
          <CtaLink href="/contact">Book a first class</CtaLink>
        </div>
      </section>
    </>
  );
}
