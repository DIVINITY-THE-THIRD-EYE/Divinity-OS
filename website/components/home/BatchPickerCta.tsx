"use client";

import { useMemo, useState } from "react";
import CtaLink from "@/components/ui/CtaLink";
import { waHref } from "@/lib/links";
import { schedule } from "@/content/schedule";
import { introOffer } from "@/content/offers";

/** One representative time per batch (Dawn/Midday/Dusk), first occurrence wins. */
function uniqueBatches() {
  const seen = new Map<string, string>();
  Object.values(schedule)
    .flat()
    .forEach((slot) => {
      if (!seen.has(slot.batch)) seen.set(slot.batch, slot.time);
    });
  return Array.from(seen.entries()).map(([batch, time]) => ({ batch, time }));
}

/**
 * No backend — selecting a batch just rebuilds the prefilled WhatsApp link.
 * If content/schedule.ts ever ships empty (placeholder state), falls back to
 * a plain WhatsApp CTA with no picker.
 */
export default function BatchPickerCta() {
  const batches = useMemo(uniqueBatches, []);
  const [selected, setSelected] = useState(batches[0]?.batch ?? "");

  if (batches.length === 0) {
    return (
      <CtaLink
        href={waHref(
          `Namaste — I'd like to join under the ${introOffer.price} ${introOffer.duration} offer.`
        )}
        external
      >
        Chat on WhatsApp
      </CtaLink>
    );
  }

  const chosen = batches.find((b) => b.batch === selected) ?? batches[0];
  const href = waHref(
    `Namaste — I'd like to join the ${chosen.batch} batch (${chosen.time}) under the ${introOffer.price} ${introOffer.duration} offer.`
  );

  return (
    <div className="flex flex-col items-center gap-3 sm:flex-row">
      <label htmlFor="batch-picker" className="sr-only">
        Choose a batch
      </label>
      <select
        id="batch-picker"
        value={selected}
        onChange={(e) => setSelected(e.target.value)}
        className="border border-[var(--line-dark)] bg-transparent px-4 py-3 font-mono text-[11px] uppercase tracking-wide text-bone focus:border-ember focus:outline-none"
      >
        {batches.map((b) => (
          <option key={b.batch} value={b.batch} className="bg-deep text-bone">
            {b.batch} · {b.time}
          </option>
        ))}
      </select>
      <CtaLink href={href} external>
        Join the {chosen.batch.toLowerCase()} batch
      </CtaLink>
    </div>
  );
}
