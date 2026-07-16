import Link from "next/link";
import type { ReactNode } from "react";

type Variant = "primary" | "outline" | "ghost";

const base =
  "inline-flex items-center justify-center gap-2 text-[13px] font-bold uppercase tracking-wide transition-all duration-200 focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-accent/30 focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--void)]";

// Clay physics: primary bulges out (violet gradient + clay-button shadow),
// lifts on hover, squishes on press. Outline/ghost stay flat-recessed.
const variants: Record<Variant, string> = {
  primary:
    "rounded-2xl bg-gradient-to-br from-accent-light to-accent px-8 py-4 text-white shadow-clay-button hover:-translate-y-0.5 hover:shadow-clay-button-hover active:scale-[0.96] active:shadow-clay-pressed",
  outline:
    "rounded-2xl bg-[var(--void)] px-8 py-4 text-accent shadow-clay-raised hover:-translate-y-0.5 hover:shadow-clay-raised-hover active:scale-[0.96] active:shadow-clay-pressed",
  ghost:
    "rounded-xl px-3 py-2 text-fg-muted hover:text-accent hover:bg-accent/5",
};

/** Route-aware CTA. `external` switches to a plain anchor (wa.me, Instagram). */
export default function CtaLink({
  href,
  children,
  variant = "primary",
  external = false,
  className = "",
  ariaLabel,
}: {
  href: string;
  children: ReactNode;
  variant?: Variant;
  external?: boolean;
  className?: string;
  ariaLabel?: string;
}) {
  const cls = `${base} ${variants[variant]} ${className}`;
  if (external) {
    return (
      <a href={href} target="_blank" rel="noopener noreferrer" className={cls} aria-label={ariaLabel}>
        {children}
      </a>
    );
  }
  return (
    <Link href={href} className={cls} aria-label={ariaLabel}>
      {children}
    </Link>
  );
}
