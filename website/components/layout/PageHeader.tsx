"use client";

import type { ReactNode } from "react";
import Reveal from "../Reveal";
import Breadcrumbs, { type Crumb } from "./Breadcrumbs";

/**
 * Shared hero header for every dedicated page. Clears the fixed nav and keeps
 * the eyebrow/title/intro rhythm consistent site-wide.
 */
export default function PageHeader({
  eyebrow,
  title,
  titleAccent,
  intro,
  trail,
  children,
}: {
  eyebrow?: string;
  title: ReactNode;
  titleAccent?: string;
  intro?: ReactNode;
  trail?: Crumb[];
  children?: ReactNode;
}) {
  return (
    <header className="relative overflow-hidden border-b border-[var(--line)] bg-surface px-6 pb-16 pt-32 md:px-10 md:pb-24 md:pt-44">
      <div
        aria-hidden
        className="pointer-events-none absolute inset-0"
        style={{
          background:
            "radial-gradient(80% 60% at 50% 0%, rgba(208,138,62,0.10), transparent 60%)",
        }}
      />
      <div className="relative mx-auto max-w-6xl">
        {trail && (
          <div className="mb-8">
            <Breadcrumbs trail={trail} />
          </div>
        )}
        <Reveal immediate>
          {eyebrow && <p className="eyebrow mb-6 text-accent">{eyebrow}</p>}
          <h1 className="font-display text-[clamp(40px,7vw,96px)] font-light leading-[0.95] tracking-tight text-fg">
            {title}
            {titleAccent && (
              <>
                {" "}
                <em className="text-accent">{titleAccent}</em>
              </>
            )}
          </h1>
          {intro && (
            <p className="mt-7 max-w-2xl font-body text-[17px] leading-relaxed text-fg-muted">
              {intro}
            </p>
          )}
          {children && <div className="mt-9">{children}</div>}
        </Reveal>
      </div>
    </header>
  );
}
