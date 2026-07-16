import type { Metadata } from "next";
import Link from "next/link";
import { pageMeta } from "@/lib/seo";
import { posts } from "@/lib/content";
import PageHeader from "@/components/layout/PageHeader";
import EmptyState from "@/components/ui/EmptyState";

export const metadata: Metadata = pageMeta({
  title: "Journal",
  description:
    "Notes on breath, posture, recovery and the philosophy of practice from the teachers at Divinity — The Third Eye.",
  path: "/blog",
  // BD-003: current posts are staging placeholders (see content/posts.ts),
  // not real articles — noindex until PH-012 is resolved with real ones.
  noindex: true,
});

export default function BlogPage() {
  const sorted = [...posts].sort((a, b) => +new Date(b.date) - +new Date(a.date));

  return (
    <>
      <PageHeader
        eyebrow="Journal"
        title="From the"
        titleAccent="mat."
        intro="Guides, reflections and the thinking behind the practice — written by the people who teach it."
        trail={[{ label: "Blog", href: "/blog" }]}
      />

      <section className="bg-surface px-6 py-20 md:px-10 md:py-28">
        <div className="mx-auto max-w-6xl">
          {sorted.length > 0 ? (
            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
              {sorted.map((p) => (
                <Link
                  key={p.slug}
                  href={`/blog/${p.slug}`}
                  data-hover
                  className="group flex flex-col border border-[var(--line)] p-7 transition-colors hover:border-ember/40"
                >
                  <p className="font-mono text-[10px] uppercase tracking-wide text-accent">
                    {new Date(p.date).toLocaleDateString("en-IN", { day: "numeric", month: "long", year: "numeric" })}
                  </p>
                  <h2 className="mt-3 font-display text-2xl leading-tight text-fg">{p.title}</h2>
                  <p className="mt-3 font-body text-[14px] leading-[1.8] text-fg-muted">{p.excerpt}</p>
                </Link>
              ))}
            </div>
          ) : (
            <EmptyState
              title="The journal opens soon"
              message="We're writing our first pieces — on breath, recovery, and the quiet discipline of daily practice. Join the mailing list to read them first."
              cta={{ href: "/contact", label: "Stay in touch" }}
            />
          )}
        </div>
      </section>
    </>
  );
}
