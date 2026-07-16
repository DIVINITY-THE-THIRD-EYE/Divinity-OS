import type { Metadata } from "next";
import Image from "next/image";
import { pageMeta } from "@/lib/seo";
import { plans, payment } from "@/lib/content";
import PageHeader from "@/components/layout/PageHeader";
import Faq from "@/components/Faq";
import CtaLink from "@/components/ui/CtaLink";

export const metadata: Metadata = pageMeta({
  title: "How Membership Works",
  description:
    "What's included in a Divinity membership, and how joining works — pay by UPI, confirm with a screenshot, no card gateway.",
  path: "/membership",
});

const STEPS = [
  {
    step: "01",
    name: "Choose a plan",
    body: "Pick the plan that fits your commitment — a single drop-in class, monthly, quarterly or the full annual journey.",
  },
  {
    step: "02",
    name: "Pay by UPI",
    body: "Scan the QR code with any UPI app — GPay, PhonePe, Paytm — and complete the payment.",
  },
  {
    step: "03",
    name: "Confirm your screenshot",
    body: "Share a screenshot of the payment with our team and your place is reserved. No card gateway, no separate account to set up.",
  },
];

export default function MembershipPage() {
  const featured = plans.find((p) => p.featured) ?? plans[0];

  return (
    <>
      <PageHeader
        eyebrow="Membership"
        title="How joining"
        titleAccent="works."
        intro="No contracts, no card gateway. Here's exactly what's included and how to begin."
        trail={[{ label: "Membership", href: "/membership" }]}
      />

      <section className="bg-surface px-6 py-20 md:px-10 md:py-28">
        <div className="mx-auto max-w-4xl">
          <p className="eyebrow mb-6 text-accent">What&apos;s included</p>
          <h2 className="font-display text-[clamp(28px,4vw,44px)] font-light leading-tight tracking-tight text-fg">
            Every membership is built around {featured.name}.
          </h2>
          {featured.features && featured.features.length > 0 && (
            <ul className="mt-8 space-y-0">
              {featured.features.map((f) => (
                <li
                  key={f}
                  className="flex items-center gap-3 border-b border-[var(--line)] py-3 font-body text-[15px] text-fg-muted"
                >
                  <span className="h-1 w-1 shrink-0 rounded-full bg-accent" />
                  {f}
                </li>
              ))}
            </ul>
          )}
          <p className="mt-6 max-w-2xl font-body text-[14px] leading-relaxed text-fg-muted">
            Lighter plans (monthly, drop-in) include a subset of the above,
            shaped around one discipline rather than the full practice — see
            the exact features per plan on{" "}
            <CtaLink href="/pricing" variant="ghost">
              the pricing page →
            </CtaLink>
            .
          </p>
        </div>
      </section>

      <section className="border-t border-[var(--line)] bg-surface px-6 py-20 md:px-10 md:py-28">
        <div className="mx-auto max-w-5xl">
          <p className="eyebrow mb-12 text-accent">How joining works</p>
          <div className="grid gap-10 md:grid-cols-3 md:gap-8">
            {STEPS.map((s) => (
              <div key={s.step}>
                <span className="font-mono text-[11px] text-accent">{s.step}</span>
                <h3 className="mt-3 font-display text-2xl italic text-fg">{s.name}</h3>
                <p className="mt-3 font-body text-[14px] leading-relaxed text-fg-muted">
                  {s.body}
                </p>
              </div>
            ))}
          </div>

          <div className="mx-auto mt-16 flex max-w-2xl flex-col items-center gap-7 border border-[var(--line)] bg-surface-2/40 p-7 sm:flex-row sm:gap-9 sm:p-9">
            <div className="shrink-0 bg-white p-3 shadow-sm ring-1 ring-[var(--line)]">
              <Image
                src={payment.qr}
                alt={`UPI payment QR code for ${payment.bank}`}
                width={148}
                height={148}
                className="h-[148px] w-[148px]"
              />
            </div>
            <div className="text-center sm:text-left">
              <p className="eyebrow mb-2 text-accent">Pay by UPI</p>
              <p className="font-display text-2xl italic leading-tight text-fg">
                Scan to reserve your place.
              </p>
              <p className="mt-3 max-w-sm font-body text-[14px] leading-relaxed text-fg-muted">
                {payment.note}
              </p>
              <p className="mt-4 font-mono text-[10px] uppercase tracking-wide text-fg-muted">
                {payment.bank} · No card gateway needed
              </p>
            </div>
          </div>
        </div>
      </section>

      <Faq limit={3} />

      <section className="border-t border-[var(--line)] bg-surface px-6 py-24 text-center md:px-10 md:py-32">
        <h2 className="mx-auto max-w-2xl font-display text-[clamp(30px,4.5vw,56px)] font-light leading-tight tracking-tight text-fg">
          Ready to <em className="text-accent">begin?</em>
        </h2>
        <div className="mt-9 flex flex-wrap justify-center gap-4">
          <CtaLink href="/pricing">See all plans</CtaLink>
          <CtaLink href="/contact" variant="ghost">Ask a question →</CtaLink>
        </div>
      </section>
    </>
  );
}
