import Link from "next/link";
import { type Discipline, disciplineSlug } from "@/lib/content";

/** Discipline/program card — used in the homepage grid and the programs page. */
export default function ServiceCard({ d }: { d: Discipline }) {
  return (
    <Link
      href={`/programs/${d.slug ?? disciplineSlug(d)}`}
      data-hover
      className="group flex h-full flex-col justify-between border border-[var(--line)] p-7 transition-colors hover:border-ember/40 md:p-9"
    >
      <div>
        <p className="eyebrow mb-6 text-accent">{d.intention}</p>
        <h3 className="font-display text-[clamp(24px,3vw,38px)] font-light leading-tight tracking-tight text-fg">
          {d.title}
        </h3>
        <p className="mt-4 font-body text-[14px] leading-[1.8] text-fg-muted">{d.description}</p>
      </div>
      <div className="mt-7 flex items-center justify-between gap-4">
        <div className="flex flex-wrap gap-2">
          {d.tags.map((t) => (
            <span
              key={t}
              className="border border-[var(--line)] px-3 py-1.5 font-mono text-[9px] uppercase tracking-wide text-accent"
            >
              {t}
            </span>
          ))}
        </div>
        <span
          aria-hidden
          className="shrink-0 font-mono text-accent opacity-0 transition-opacity group-hover:opacity-100"
        >
          →
        </span>
      </div>
    </Link>
  );
}
