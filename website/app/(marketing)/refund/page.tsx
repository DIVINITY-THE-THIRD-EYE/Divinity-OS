import type { Metadata } from "next";
import { pageMeta } from "@/lib/seo";
import { fetchSiteSettings } from "@/lib/content";
import { refund } from "@/content/legal";
import PageHeader from "@/components/layout/PageHeader";

// PH-009 (PLACEHOLDERS.md): no refund policy text exists yet — this page
// ships noindex, showing the placeholder plus a contact-us fallback so
// visitors who land here aren't left without a next step.

export async function generateMetadata(): Promise<Metadata> {
  const site = await fetchSiteSettings();
  return pageMeta({
    title: "Refund Policy",
    description: `Refund and cancellation policy for ${site.full}.`,
    path: "/refund",
    noindex: true,
  });
}

export default async function RefundPage() {
  return (
    <>
      <PageHeader
        eyebrow="The fine print"
        title="Refund"
        titleAccent="Policy."
        intro="Our refund and cancellation terms."
        trail={[{ label: "Refund Policy", href: "/refund" }]}
      />
      <section className="bg-surface px-6 py-16 md:px-10 md:py-24">
        <div className="mx-auto max-w-2xl">
          {refund.map((s) => (
            <div key={s.heading}>
              <h2 className="mt-12 font-display text-2xl text-fg md:text-3xl">{s.heading}</h2>
              <p className="mt-4 font-body text-[15px] leading-[1.85] text-fg-muted">{s.body}</p>
            </div>
          ))}
          <p className="mt-10 font-body text-[15px] leading-[1.85] text-fg-muted">
            Have a question about a cancellation or refund right now? Please{" "}
            <a href="/contact" className="text-accent underline-offset-4 hover:underline">
              contact us
            </a>{" "}
            directly and we&apos;ll help.
          </p>
        </div>
      </section>
    </>
  );
}
