import CtaLink from "./CtaLink";

/**
 * Polished "coming soon" state for content that isn't published yet (blog,
 * events, testimonials). Clearly distinct from real content.
 */
export default function EmptyState({
  title,
  message,
  cta,
  glyph = "ॐ",
}: {
  title: string;
  message: string;
  cta?: { href: string; label: string; external?: boolean };
  glyph?: string;
}) {
  return (
    <div className="mx-auto flex max-w-xl flex-col items-center gap-5 rounded-[32px] bg-[var(--void)] px-8 py-16 text-center shadow-clay-card">
      <span
        aria-hidden
        className="clay-breathe flex h-16 w-16 items-center justify-center rounded-full bg-[var(--void)] font-display text-2xl text-accent shadow-clay-inset"
      >
        {glyph}
      </span>
      <p className="font-display text-2xl font-bold text-fg">{title}</p>
      <p className="max-w-md font-body text-[15px] leading-relaxed text-fg-muted">{message}</p>
      {cta && (
        <CtaLink href={cta.href} external={cta.external} variant="outline">
          {cta.label}
        </CtaLink>
      )}
    </div>
  );
}
