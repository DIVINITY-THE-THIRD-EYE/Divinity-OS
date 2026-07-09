import type { Metadata } from "next";
import { pageMeta } from "@/lib/seo";
import { fetchSiteSettings } from "@/lib/content";
import { privacy, legalUpdated } from "@/content/legal";
import PageHeader from "@/components/layout/PageHeader";

/*
 * NOTE FOR THE BUSINESS: this policy describes the site's actual data flow
 * (contact/newsletter forms delivered via Brevo, offline UPI payments, no
 * third-party ad tracking). Please have it reviewed against the DPDP Act 2023
 * and confirmed by counsel before launch, and fill in a registered address and
 * a dedicated privacy contact email if available.
 */

export async function generateMetadata(): Promise<Metadata> {
  const site = await fetchSiteSettings();
  return pageMeta({
    title: "Privacy Policy",
    description: `How ${site.full} collects, uses and protects your information.`,
    path: "/privacy",
  });
}

export default async function PrivacyPage() {
  return (
    <>
      <PageHeader
        eyebrow="Your privacy"
        title="Privacy"
        titleAccent="Policy."
        intro={`Last updated ${legalUpdated}. This page explains what information we collect and how we use it.`}
        trail={[{ label: "Privacy Policy", href: "/privacy" }]}
      />
      <section className="bg-surface px-6 py-16 md:px-10 md:py-24">
        <div className="mx-auto max-w-2xl">
          {privacy.map((s) => (
            <div key={s.heading || s.body}>
              {s.heading && (
                <h2 className="mt-12 font-display text-2xl text-fg md:text-3xl">{s.heading}</h2>
              )}
              <p className="mt-4 font-body text-[15px] leading-[1.85] text-fg-muted">
                {s.body}
                {s.contactLink && (
                  <>
                    {" "}
                    <a href="/contact" className="text-accent underline-offset-4 hover:underline">
                      contact page
                    </a>
                    .
                  </>
                )}
              </p>
            </div>
          ))}
        </div>
      </section>
    </>
  );
}
