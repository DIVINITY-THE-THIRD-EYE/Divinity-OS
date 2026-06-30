import type { Metadata } from "next";
import { pageMeta } from "@/lib/seo";
import { site } from "@/lib/content";
import PageHeader from "@/components/layout/PageHeader";

/*
 * NOTE FOR THE BUSINESS: this policy describes the site's actual data flow
 * (contact/newsletter forms delivered via Brevo, offline UPI payments, no
 * third-party ad tracking). Please have it reviewed against the DPDP Act 2023
 * and confirmed by counsel before launch, and fill in a registered address and
 * a dedicated privacy contact email if available.
 */

export const metadata: Metadata = pageMeta({
  title: "Privacy Policy",
  description: `How ${site.full} collects, uses and protects your information.`,
  path: "/privacy",
});

const updated = "30 June 2026";

function H({ children }: { children: React.ReactNode }) {
  return <h2 className="mt-12 font-display text-2xl text-bone md:text-3xl">{children}</h2>;
}
function P({ children }: { children: React.ReactNode }) {
  return <p className="mt-4 font-body text-[15px] leading-[1.85] text-mist">{children}</p>;
}

export default function PrivacyPage() {
  return (
    <>
      <PageHeader
        eyebrow="Your privacy"
        title="Privacy"
        titleAccent="Policy."
        intro={`Last updated ${updated}. This page explains what information we collect and how we use it.`}
        trail={[{ label: "Privacy Policy", href: "/privacy" }]}
      />
      <section className="bg-void px-6 py-16 md:px-10 md:py-24">
        <div className="mx-auto max-w-2xl">
          <P>
            {site.full} (&ldquo;we&rdquo;, &ldquo;us&rdquo;) operates this website. We respect your
            privacy and collect only what we need to respond to you and run our
            classes. We never sell your information.
          </P>

          <H>What we collect</H>
          <P>
            When you use our contact or newsletter forms we collect the details
            you choose to share — typically your name, email address, phone number
            and your message. We do not run third-party advertising trackers, and
            we use only the essential cookies needed for the site to function.
          </P>

          <H>How we use it</H>
          <P>
            We use your details to reply to your enquiry, arrange classes, and —
            only if you opt in — to send occasional updates about schedules and
            events. You can unsubscribe from updates at any time.
          </P>

          <H>Who we share it with</H>
          <P>
            Form submissions and newsletter emails are delivered through our email
            provider (Brevo), which processes them on our behalf. Payments are made
            directly by UPI to our account — we do not collect or store card
            details on this site. We may disclose information if required by law.
          </P>

          <H>How long we keep it</H>
          <P>
            We retain enquiry and member details only for as long as needed to
            serve you and to meet any legal obligations, after which they are
            deleted.
          </P>

          <H>Your rights</H>
          <P>
            You may ask us to access, correct or delete the personal information we
            hold about you, or to stop contacting you. To make a request, reach us
            through our <a href="/contact" className="text-ember underline-offset-4 hover:underline">contact page</a>.
          </P>

          <H>Children</H>
          <P>
            Our services are intended for adults. Minors should practise only with
            the consent and supervision of a parent or guardian.
          </P>

          <H>Changes</H>
          <P>
            We may update this policy from time to time. Any changes will be posted
            on this page with a revised date above.
          </P>
        </div>
      </section>
    </>
  );
}
