import CtaLink from "./CtaLink";

/**
 * Reusable section heading with an optional "view all" CTA — used by the
 * homepage preview sections and dedicated pages. `light` flips colours for
 * sections on the bone background.
 */
export default function SectionHeading({
  eyebrow,
  title,
  titleAccent,
  cta,
  light = false,
  className = "",
}: {
  eyebrow?: string;
  title: string;
  titleAccent?: string;
  cta?: { href: string; label: string };
  light?: boolean;
  className?: string;
}) {
  const accent = light ? "text-ember-deep" : "text-accent";
  const heading = light ? "text-ink" : "text-fg";
  return (
    <div
      className={`mb-12 flex flex-col gap-6 md:flex-row md:items-end md:justify-between ${className}`}
    >
      <div>
        {eyebrow && <p className={`eyebrow mb-4 ${accent}`}>{eyebrow}</p>}
        <h2
          className={`font-display text-[clamp(32px,5vw,64px)] font-light leading-[1.0] tracking-tight ${heading}`}
        >
          {title}
          {titleAccent && (
            <>
              {" "}
              <em className={accent}>{titleAccent}</em>
            </>
          )}
        </h2>
      </div>
      {cta && (
        <CtaLink href={cta.href} variant="ghost" className={`shrink-0 ${light ? "text-ink-mute hover:text-ember-deep" : ""}`}>
          {cta.label} →
        </CtaLink>
      )}
    </div>
  );
}
