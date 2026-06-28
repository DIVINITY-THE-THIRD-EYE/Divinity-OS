"use client";

import Image from "next/image";
import { m } from "framer-motion";
import { studioGallery } from "@/lib/content";

export default function Gallery() {
  return (
    <section
      id="space"
      className="relative overflow-hidden border-t border-[var(--line-dark)] bg-void px-6 py-28 md:px-10 md:py-40"
    >
      <div className="mx-auto max-w-6xl">
        <div className="mb-14 flex flex-col gap-6 md:flex-row md:items-end md:justify-between">
          <div>
            <p className="eyebrow mb-6 flex items-center gap-3 text-ember">
              <span className="h-px w-9 bg-ember/50" /> The space
            </p>
            <h2 className="font-display text-[clamp(38px,5.5vw,78px)] font-light leading-[0.98] tracking-tight text-bone">
              Where the practice
              <br />
              <em className="text-ember">lives.</em>
            </h2>
          </div>
          <p className="max-w-xs font-body text-[15px] leading-relaxed text-mist">
            Warm wood, soft light and every prop the body might need — a studio in
            Lucknow built for breath, movement and stillness.
          </p>
        </div>

        {/* masonry — natural aspect ratios, no layout shift */}
        <div className="[column-fill:_balance] gap-4 sm:columns-2 sm:gap-5 lg:columns-3">
          {studioGallery.map((shot, i) => (
            <m.figure
              key={shot.src}
              initial={{ opacity: 0, y: 28 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-60px" }}
              transition={{ duration: 0.8, delay: (i % 3) * 0.08, ease: [0.22, 1, 0.36, 1] }}
              className="group mb-4 break-inside-avoid overflow-hidden border border-[var(--line-dark)] sm:mb-5"
            >
              <Image
                src={shot.src}
                alt={shot.alt}
                width={shot.w}
                height={shot.h}
                sizes="(max-width: 640px) 90vw, (max-width: 1024px) 45vw, 30vw"
                className="h-auto w-full object-cover grayscale-[0.18] transition duration-700 ease-out will-change-transform group-hover:scale-[1.04] group-hover:grayscale-0"
              />
            </m.figure>
          ))}
        </div>
      </div>
    </section>
  );
}
