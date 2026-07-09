import Link from "next/link";
import type { ReactNode } from "react";

type Variant = "primary" | "outline" | "ghost";

const base =
  "inline-flex items-center gap-2 font-mono text-[11px] uppercase tracking-wide transition-colors";

const variants: Record<Variant, string> = {
  primary: "bg-accent px-7 py-3.5 text-surface hover:bg-ember-pale",
  outline: "border border-accent px-7 py-3.5 text-accent hover:bg-accent hover:text-surface",
  ghost: "text-fg-muted hover:text-accent",
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
