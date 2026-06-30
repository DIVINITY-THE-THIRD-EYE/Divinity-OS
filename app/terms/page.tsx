import type { Metadata } from "next";
import { pageMeta } from "@/lib/seo";
import { site } from "@/lib/content";
import PageHeader from "@/components/layout/PageHeader";

/*
 * NOTE FOR THE BUSINESS: these terms reflect the current offering (in-studio
 * classes, UPI payment, no online checkout). Please have counsel review and
 * confirm cancellation/refund terms and governing-law jurisdiction before
 * launch, and add a registered business address.
 */

export const metadata: Metadata = pageMeta({
  title: "Terms & Conditions",
  description: `The terms that apply when you use the ${site.full} website and attend classes.`,
  path: "/terms",
});

const updated = "30 June 2026";

function H({ children }: { children: React.ReactNode }) {
  return <h2 className="mt-12 font-display text-2xl text-bone md:text-3xl">{children}</h2>;
}
function P({ children }: { children: React.ReactNode }) {
  return <p className="mt-4 font-body text-[15px] leading-[1.85] text-mist">{children}</p>;
}

export default function TermsPage() {
  return (
    <>
      <PageHeader
        eyebrow="The fine print"
        title="Terms &"
        titleAccent="Conditions."
        intro={`Last updated ${updated}. By using this website and attending our classes, you agree to the following.`}
        trail={[{ label: "Terms & Conditions", href: "/terms" }]}
      />
      <section className="bg-void px-6 py-16 md:px-10 md:py-24">
        <div className="mx-auto max-w-2xl">
          <H>Using this site</H>
          <P>
            This website is provided for information about {site.full} and its
            classes. We aim to keep details such as schedules and pricing accurate
            and current, but they may change; please confirm with us before relying
            on them.
          </P>

          <H>Bookings & payment</H>
          <P>
            Class places are confirmed once payment is received. Payments are made
            by UPI directly to our account — this site does not process card
            payments. Prices are shown in Indian Rupees and include applicable
            taxes unless stated otherwise.
          </P>

          <H>Cancellations & refunds</H>
          <P>
            If you need to cancel or reschedule, contact us as early as possible.
            Specific cancellation and refund terms are confirmed at the time of
            booking.
          </P>

          <H>Health & safety</H>
          <P>
            Yoga and fitness involve physical activity. Please tell your teacher
            about any injury, medical condition or pregnancy before practising, and
            consult a doctor if you are unsure. You take part at your own
            discretion and are responsible for working within your limits.
          </P>

          <H>Conduct</H>
          <P>
            We ask all members to be respectful of teachers, fellow students and
            the studio space. We may decline service where conduct is unsafe or
            disruptive.
          </P>

          <H>Intellectual property</H>
          <P>
            The content, branding and imagery on this site belong to {site.full}
            and may not be reproduced without permission.
          </P>

          <H>Contact</H>
          <P>
            Questions about these terms? Reach us through our{" "}
            <a href="/contact" className="text-ember underline-offset-4 hover:underline">contact page</a>.
          </P>
        </div>
      </section>
    </>
  );
}
