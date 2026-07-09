import type { Metadata } from "next";
import { pageMeta } from "@/lib/seo";
import { fetchOrFallback } from "@/lib/sanity";
import { disciplines as dDisciplines, type Discipline } from "@/lib/content";
import PageHeader from "@/components/layout/PageHeader";
import ServiceCard from "@/components/cards/ServiceCard";
import CtaLink from "@/components/ui/CtaLink";

export const metadata: Metadata = pageMeta({
  title: "Services & Programs",
  description:
    "Hatha & Vinyasa yoga, fitness training, pranayama & meditation, wellness programs, therapeutic yoga, and diet & lifestyle guidance — in Lucknow.",
  path: "/services",
});

const DISCIPLINES_Q = `*[_type=="discipline"]|order(order asc){title,intention,description,tags}`;

const intentions = ["For the body", "For the breath", "For healing"] as const;

export default async function ServicesPage() {
  const disciplines = await fetchOrFallback<Discipline[]>(DISCIPLINES_Q, dDisciplines);

  return (
    <>
      <PageHeader
        eyebrow="What we practice"
        title="Practices for body,"
        titleAccent="breath & healing."
        intro="Six disciplines, woven into one academy. Begin with one path or blend several — every plan is shaped around your body and your goals."
        trail={[{ label: "Services", href: "/services" }]}
      />

      <div className="bg-void px-6 py-20 md:px-10 md:py-28">
        <div className="mx-auto max-w-6xl space-y-16">
          {intentions.map((intention) => {
            const group = disciplines.filter((d) => d.intention === intention);
            if (group.length === 0) return null;
            return (
              <section key={intention} aria-label={intention}>
                <p className="eyebrow mb-7 flex items-center gap-3 text-ember">
                  <span className="h-px w-9 bg-ember/50" /> {intention}
                </p>
                <div className="grid gap-5 md:grid-cols-2 lg:grid-cols-3">
                  {group.map((d) => (
                    <ServiceCard key={d.title} d={d} />
                  ))}
                </div>
              </section>
            );
          })}
        </div>
      </div>

      <section className="border-t border-[var(--line-dark)] bg-void px-6 py-24 text-center md:px-10 md:py-32">
        <h2 className="mx-auto max-w-2xl font-display text-[clamp(30px,4.5vw,56px)] font-light leading-tight tracking-tight text-bone">
          Not sure where to <em className="text-ember">begin?</em>
        </h2>
        <div className="mt-9 flex flex-wrap justify-center gap-4">
          <CtaLink href="/pricing">Find your plan</CtaLink>
          <CtaLink href="/contact" variant="ghost">Ask us →</CtaLink>
        </div>
      </section>
    </>
  );
}
