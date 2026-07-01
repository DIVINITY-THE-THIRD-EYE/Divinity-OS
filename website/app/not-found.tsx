import Link from "next/link";
import { primaryNav } from "@/lib/nav";
import CtaLink from "@/components/ui/CtaLink";

export default function NotFound() {
  return (
    <section className="relative flex min-h-[80vh] flex-col items-center justify-center overflow-hidden bg-void px-6 py-32 text-center md:px-10">
      <div
        aria-hidden
        className="pointer-events-none absolute inset-0"
        style={{
          background:
            "radial-gradient(55% 55% at 50% 40%, rgba(208,138,62,0.12), transparent 65%)",
        }}
      />
      <div className="relative">
        <p className="eyebrow mb-6 text-ember">Lost the path</p>
        <p className="font-display text-[clamp(80px,18vw,200px)] font-light leading-none text-bone">
          4<span className="text-ember">ॐ</span>4
        </p>
        <h1 className="mt-4 font-display text-[clamp(26px,4vw,44px)] font-light text-bone">
          This page has wandered off.
        </h1>
        <p className="mx-auto mt-5 max-w-md font-body text-[15px] leading-relaxed text-mist">
          The page you were looking for doesn&apos;t exist or has moved. Let&apos;s
          guide you back to your practice.
        </p>

        <div className="mt-9 flex flex-wrap justify-center gap-4">
          <CtaLink href="/">Return home</CtaLink>
          <CtaLink href="/contact" variant="ghost">Contact us →</CtaLink>
        </div>

        <nav aria-label="Site sections" className="mt-12 flex flex-wrap justify-center gap-x-6 gap-y-3">
          {primaryNav.map((l) => (
            <Link
              key={l.href}
              href={l.href}
              className="font-mono text-[11px] uppercase tracking-wide text-mist transition-colors hover:text-ember"
            >
              {l.label}
            </Link>
          ))}
        </nav>
      </div>
    </section>
  );
}
