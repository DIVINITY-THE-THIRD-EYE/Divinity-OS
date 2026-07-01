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
    <div className="mx-auto flex max-w-xl flex-col items-center gap-5 border border-[var(--line-dark)] bg-deep/40 px-8 py-16 text-center">
      <span
        aria-hidden
        className="flex h-14 w-14 items-center justify-center rounded-full border border-[var(--line-dark)] font-display text-2xl text-ember"
      >
        {glyph}
      </span>
      <p className="font-display text-2xl italic text-bone">{title}</p>
      <p className="max-w-md font-body text-[15px] leading-relaxed text-mist">{message}</p>
      {cta && (
        <CtaLink href={cta.href} external={cta.external} variant="outline">
          {cta.label}
        </CtaLink>
      )}
    </div>
  );
}
