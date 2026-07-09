import type { Metadata } from "next";
import { pageMeta } from "@/lib/seo";
import { fetchSiteSettings } from "@/lib/content";
import { terms, legalUpdated } from "@/content/legal";
import PageHeader from "@/components/layout/PageHeader";

/*
 * NOTE FOR THE BUSINESS: these terms reflect the current offering (in-studio
 * classes, UPI payment, no online checkout). Please have counsel review and
 * confirm cancellation/refund terms and governing-law jurisdiction before
 * launch, and add a registered business address.
 */

export async function generateMetadata(): Promise<Metadata> {
  const site = await fetchSiteSettings();
  return pageMeta({
    title: "Terms & Conditions",
    description: `The terms that apply when you use the ${site.full} website and attend classes.`,
    path: "/terms",
  });
}

export default async function TermsPage() {
  return (
    <>
      <PageHeader
        eyebrow="The fine print"
        title="Terms &"
        titleAccent="Conditions."
        intro={`Last updated ${legalUpdated}. By using this website and attending our classes, you agree to the following.`}
        trail={[{ label: "Terms & Conditions", href: "/terms" }]}
      />
      <section className="bg-surface px-6 py-16 md:px-10 md:py-24">
        <div className="mx-auto max-w-2xl">
          {terms.map((s) => (
            <div key={s.heading}>
              <h2 className="mt-12 font-display text-2xl text-fg md:text-3xl">{s.heading}</h2>
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
