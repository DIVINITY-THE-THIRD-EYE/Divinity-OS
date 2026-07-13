import Link from "next/link";
import { type Discipline, disciplineSlug } from "@/lib/content";

/** Discipline/program card — used in the homepage grid and the programs page. */
export default function ServiceCard({ d }: { d: Discipline }) {
  return (
    <Link
      href={`/programs/${d.slug ?? disciplineSlug(d)}`}
      data-hover
      className="group flex h-full flex-col justify-between rounded-[32px] bg-[var(--void)] p-7 shadow-clay-card transition-all duration-500 hover:-translate-y-2 hover:shadow-clay-card-hover md:p-9"
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
              className="rounded-full bg-[var(--void)] px-3 py-1.5 text-[10px] font-semibold uppercase tracking-wide text-accent shadow-clay-inset-sm"
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
