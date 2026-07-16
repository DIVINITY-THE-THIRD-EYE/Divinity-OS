import type { Metadata } from "next";
import { pageMeta } from "@/lib/seo";
import { fetchOrFallback } from "@/lib/sanity";
import { plans as dPlans, type Plan } from "@/lib/content";
import { introOffer } from "@/content/offers";
import PageHeader from "@/components/layout/PageHeader";
import Membership from "@/components/Membership";
import PlanCalculator from "@/components/PlanCalculator";
import CtaLink from "@/components/ui/CtaLink";

export const metadata: Metadata = pageMeta({
  title: "Pricing & Membership",
  description:
    "Simple, transparent membership — monthly, quarterly and annual plans, plus a single drop-in class. Pay by UPI, no card gateway needed.",
  path: "/pricing",
});

const PLANS_Q = `*[_type=="plan"]|order(order asc){name,price,cadence,blurb,features,featured}`;

export default async function PricingPage() {
  const plans = await fetchOrFallback<Plan[]>(PLANS_Q, dPlans);
  return (
    <>
      <PageHeader
        eyebrow="Membership"
        title="Choose your"
        titleAccent="path."
        intro="No contracts, no card gateway — pay by UPI and confirm with a screenshot. Start with a single class, or commit to the full journey."
        trail={[{ label: "Pricing", href: "/pricing" }]}
      >
        <CtaLink href="/membership" variant="ghost">How does joining work? →</CtaLink>
      </PageHeader>
      <Membership plans={plans} showHeading={false} />

      <section className="border-t border-[var(--line)] bg-surface px-6 py-16 text-center md:px-10 md:py-20">
        <div className="mx-auto max-w-xl">
          <p className="eyebrow mb-4 text-accent">First-week offer</p>
          <p className="font-display text-2xl italic leading-tight text-fg">
            {introOffer.price} for your {introOffer.duration}.
          </p>
          <p className="mx-auto mt-4 max-w-md font-body text-[14px] leading-relaxed text-fg-muted">
            {introOffer.terms}
          </p>
          <div className="mt-7 flex justify-center">
            <CtaLink href="/contact">Claim the offer</CtaLink>
          </div>
        </div>
      </section>

      <PlanCalculator />
    </>
  );
}
