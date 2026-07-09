import type { Metadata } from "next";
import { pageMeta } from "@/lib/seo";
import { fetchSiteSettings } from "@/lib/content";
import PageHeader from "@/components/layout/PageHeader";
import VerifyForm from "@/components/VerifyForm";

export async function generateMetadata(): Promise<Metadata> {
  const site = await fetchSiteSettings();
  return pageMeta({
    title: "Verify a Certificate",
    description: `Confirm the authenticity of a certificate issued by ${site.full}.`,
    path: "/verify",
  });
}

export default async function VerifyPage() {
  return (
    <>
      <PageHeader
        eyebrow="Trust & authenticity"
        title="Verify a"
        titleAccent="certificate."
        intro="Each certificate Divinity issues carries a unique code. Enter it below to confirm it's genuine."
        trail={[{ label: "Verify", href: "/verify" }]}
      />
      <section className="bg-surface px-6 py-16 md:px-10 md:py-24">
        <VerifyForm />
        <p className="mx-auto mt-10 max-w-md text-center font-body text-[13px] leading-relaxed text-fg-muted">
          The code is printed on the certificate (format <span className="font-mono text-fg">DIV-XXXX-XXXX</span>).
          If you can&apos;t verify it online, please{" "}
          <a href="/contact" className="text-accent underline-offset-4 hover:underline">
            contact the academy
          </a>{" "}
          with the code.
        </p>
      </section>
    </>
  );
}
