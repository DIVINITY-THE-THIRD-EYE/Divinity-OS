import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { pageMeta, absUrl } from "@/lib/seo";
import { posts, getPostBySlug, site } from "@/lib/content";
import PageHeader from "@/components/layout/PageHeader";
import CtaLink from "@/components/ui/CtaLink";

export function generateStaticParams() {
  return posts.map((p) => ({ slug: p.slug }));
}

export function generateMetadata({ params }: { params: { slug: string } }): Metadata {
  const p = getPostBySlug(params.slug);
  if (!p) return pageMeta({ title: "Article not found", description: "", path: `/blog/${params.slug}` });
  return pageMeta({
    title: p.title,
    description: p.excerpt,
    path: `/blog/${params.slug}`,
    type: "article",
    image: p.cover,
  });
}

export default function BlogPost({ params }: { params: { slug: string } }) {
  const p = getPostBySlug(params.slug);
  if (!p) notFound();

  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "Article",
    headline: p.title,
    description: p.excerpt,
    datePublished: p.date,
    author: { "@type": "Person", name: p.author },
    publisher: { "@type": "Organization", name: site.full },
    mainEntityOfPage: absUrl(`/blog/${p.slug}`),
    ...(p.cover ? { image: p.cover } : {}),
  };

  return (
    <>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />
      <PageHeader
        eyebrow={new Date(p.date).toLocaleDateString("en-IN", { day: "numeric", month: "long", year: "numeric" })}
        title={p.title}
        intro={p.excerpt}
        trail={[
          { label: "Blog", href: "/blog" },
          { label: p.title, href: `/blog/${p.slug}` },
        ]}
      />
      <article className="bg-void px-6 py-20 md:px-10 md:py-28">
        <div className="mx-auto max-w-2xl space-y-6 font-body text-[16px] leading-[1.85] text-mist">
          {p.body.split("\n\n").map((para, i) => (
            <p key={i}>{para}</p>
          ))}
          <p className="pt-4 font-mono text-[11px] uppercase tracking-wide text-ember">
            Written by {p.author}
          </p>
          <div className="pt-6">
            <CtaLink href="/blog" variant="ghost">← Back to the journal</CtaLink>
          </div>
        </div>
      </article>
    </>
  );
}
