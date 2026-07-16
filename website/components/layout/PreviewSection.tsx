import type { ReactNode } from "react";
import SectionHeading from "../ui/SectionHeading";

/**
 * Homepage preview block: a section shell with a heading + optional "view all"
 * CTA, then its preview content. Keeps every homepage teaser consistent.
 */
export default function PreviewSection({
  id,
  eyebrow,
  title,
  titleAccent,
  cta,
  tone = "dark",
  children,
}: {
  id?: string;
  eyebrow?: string;
  title: string;
  titleAccent?: string;
  cta?: { href: string; label: string };
  tone?: "dark" | "light";
  children: ReactNode;
}) {
  const light = tone === "light";
  return (
    <section
      id={id}
      className={`border-t border-[var(--line-dark)] px-6 py-24 md:px-10 md:py-32 ${
        light ? "bg-deep text-ink" : "bg-void"
      }`}
    >
      <div className="mx-auto max-w-6xl">
        <SectionHeading
          eyebrow={eyebrow}
          title={title}
          titleAccent={titleAccent}
          cta={cta}
          light={light}
        />
        {children}
      </div>
    </section>
  );
}
