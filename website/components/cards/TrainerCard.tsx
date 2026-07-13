import Image from "next/image";
import { type Trainer } from "@/lib/content";

/** Teacher/trainer card — used on the homepage preview and the trainers page. */
export default function TrainerCard({ t }: { t: Trainer }) {
  return (
    <article className="group flex flex-col overflow-hidden rounded-[32px] bg-[var(--void)] p-3 shadow-clay-card transition-all duration-500 hover:-translate-y-2 hover:shadow-clay-card-hover">
      {t.image && (
        <div className="relative aspect-[3/4] overflow-hidden rounded-[24px]">
          <Image
            src={t.image}
            alt={`${t.name}, ${t.role}`}
            fill
            sizes="(max-width: 768px) 90vw, 360px"
            className="object-cover object-top transition duration-700 ease-out will-change-transform group-hover:scale-[1.04]"
          />
        </div>
      )}
      <div className="flex flex-1 flex-col p-6">
        <h3 className="font-display text-2xl font-bold text-fg">{t.name}</h3>
        <p className="mt-1 text-[11px] font-bold uppercase tracking-wide text-accent">{t.role}</p>
        <p className="mt-4 font-body text-[14px] leading-[1.8] text-fg-muted">{t.bio}</p>
        {t.focus && t.focus.length > 0 && (
          <div className="mt-6 flex flex-wrap gap-2">
            {t.focus.map((f) => (
              <span
                key={f}
                className="rounded-full bg-[var(--void)] px-3 py-1.5 text-[10px] font-semibold uppercase tracking-wide text-accent shadow-clay-inset-sm"
              >
                {f}
              </span>
            ))}
          </div>
        )}
      </div>
    </article>
  );
}
