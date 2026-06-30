import Image from "next/image";
import { type Trainer } from "@/lib/content";

/** Teacher/trainer card — used on the homepage preview and the trainers page. */
export default function TrainerCard({ t }: { t: Trainer }) {
  return (
    <article className="group flex flex-col overflow-hidden border border-[var(--line-dark)]">
      {t.image && (
        <div className="relative aspect-[3/4] overflow-hidden">
          <Image
            src={t.image}
            alt={`${t.name}, ${t.role}`}
            fill
            sizes="(max-width: 768px) 90vw, 360px"
            className="object-cover grayscale-[0.15] transition duration-700 ease-out will-change-transform group-hover:scale-[1.03] group-hover:grayscale-0"
          />
        </div>
      )}
      <div className="flex flex-1 flex-col p-7">
        <h3 className="font-display text-2xl italic text-bone">{t.name}</h3>
        <p className="mt-1 font-mono text-[10px] uppercase tracking-wide text-ember">{t.role}</p>
        <p className="mt-4 font-body text-[14px] leading-[1.8] text-mist">{t.bio}</p>
        {t.focus && t.focus.length > 0 && (
          <div className="mt-6 flex flex-wrap gap-2">
            {t.focus.map((f) => (
              <span
                key={f}
                className="border border-[var(--line-dark)] px-3 py-1.5 font-mono text-[9px] uppercase tracking-wide text-ember"
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
