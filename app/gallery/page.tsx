import type { Metadata } from "next";
import { pageMeta } from "@/lib/seo";
import PageHeader from "@/components/layout/PageHeader";
import Gallery from "@/components/Gallery";
import CtaLink from "@/components/ui/CtaLink";

export const metadata: Metadata = pageMeta({
  title: "The Space — Gallery",
  description:
    "Inside Divinity — The Third Eye: warm wood, soft light, and a studio in Lucknow built for breath, movement and stillness.",
  path: "/gallery",
});

export default function GalleryPage() {
  return (
    <>
      <PageHeader
        eyebrow="The space"
        title="Where the practice"
        titleAccent="lives."
        intro="A quiet, lamp-lit hall in Lucknow — every prop the body might need, and room for the breath to settle."
        trail={[{ label: "Gallery", href: "/gallery" }]}
      />
      <Gallery showHeading={false} />
      <section className="border-t border-[var(--line-dark)] bg-void px-6 py-24 text-center md:px-10 md:py-32">
        <h2 className="font-display text-[clamp(30px,4.5vw,56px)] font-light tracking-tight text-bone">
          Come and <em className="text-ember">breathe</em> here.
        </h2>
        <div className="mt-9 flex justify-center">
          <CtaLink href="/contact">Plan your first visit</CtaLink>
        </div>
      </section>
    </>
  );
}
