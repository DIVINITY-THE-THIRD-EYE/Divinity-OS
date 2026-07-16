import Link from "next/link";
import { absUrl } from "@/lib/seo";

export type Crumb = { label: string; href: string };

/**
 * Accessible breadcrumb trail + BreadcrumbList structured data. Always begins
 * at Home; pass the trail from there (excluding Home).
 */
export default function Breadcrumbs({ trail }: { trail: Crumb[] }) {
  const items = [{ label: "Home", href: "/" }, ...trail];
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    itemListElement: items.map((c, i) => ({
      "@type": "ListItem",
      position: i + 1,
      name: c.label,
      item: absUrl(c.href),
    })),
  };

  return (
    <nav aria-label="Breadcrumb" className="font-mono text-[10px] uppercase tracking-wide text-fg-muted">
      <ol className="flex flex-wrap items-center gap-2">
        {items.map((c, i) => {
          const last = i === items.length - 1;
          return (
            <li key={c.href} className="flex items-center gap-2">
              {last ? (
                <span aria-current="page" className="text-accent">{c.label}</span>
              ) : (
                <Link href={c.href} className="transition-colors hover:text-accent">
                  {c.label}
                </Link>
              )}
              {!last && <span aria-hidden className="text-fg-muted/50">/</span>}
            </li>
          );
        })}
      </ol>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />
    </nav>
  );
}
