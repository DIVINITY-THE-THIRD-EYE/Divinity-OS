import type { Metadata } from "next";
import { pageMeta } from "@/lib/seo";
import { waHref } from "@/lib/links";
import PageHeader from "@/components/layout/PageHeader";
import EmptyState from "@/components/ui/EmptyState";

export const metadata: Metadata = pageMeta({
  title: "Member Stories",
  description:
    "Real reflections from Divinity — The Third Eye members, as they're shared and permissioned.",
  path: "/testimonials",
  // BD-003: content/testimonials.ts currently holds staging placeholders,
  // not real member quotes (verbatim-labeled "[STAGING CONTENT]") — noindex
  // until PH-006 is resolved. Deliberately NOT reusing the Voices carousel
  // here: showing "[STAGING CONTENT]" as the entire content of a page whose
  // sole purpose is testimonials would read as fabricated, not staged —
  // the honest empty-handling this task requires.
  noindex: true,
});

const shareHref = waHref(
  "Namaste — I'd like to share a reflection on my practice at Divinity."
);

export default function TestimonialsPage() {
  return (
    <>
      <PageHeader
        eyebrow="Voices"
        title="Member"
        titleAccent="stories."
        intro="We're gathering reflections from the people who practise here — with their permission, in their own words."
        trail={[{ label: "Testimonials", href: "/testimonials" }]}
      />

      <section className="bg-surface px-6 py-20 md:px-10 md:py-28">
        <div className="mx-auto max-w-3xl">
          <EmptyState
            title="Stories, coming soon"
            message="Real words from real practitioners will live here once members share them and give us permission to publish. If you practise with us and would like your reflection featured, we'd love to hear it."
            cta={{ href: shareHref, label: "Share your story on WhatsApp", external: true }}
          />
        </div>
      </section>
    </>
  );
}
