import type { Metadata } from "next";
import { pageMeta } from "@/lib/seo";
import { fetchOrFallback } from "@/lib/sanity";
import { plans as dPlans, type Plan } from "@/lib/content";
import PageHeader from "@/components/layout/PageHeader";
import Membership from "@/components/Membership";
import PlanCalculator from "@/components/PlanCalculator";

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
      />
      <Membership plans={plans} />
      <PlanCalculator />
    </>
  );
}
