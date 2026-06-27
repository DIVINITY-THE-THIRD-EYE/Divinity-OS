"use client";

import Image from "next/image";
import { site } from "@/lib/content";

const whatsappHref = `https://wa.me/${site.whatsapp}?text=${encodeURIComponent(
  "Namaste — I'd like to know more about practising at Divinity."
)}`;

const cols = [
  {
    title: "Practice",
    links: [
      ["Yoga", "#disciplines"],
      ["Fitness", "#disciplines"],
      ["Therapeutic", "#disciplines"],
      ["Wellness", "#disciplines"],
    ],
  },
  {
    title: "Academy",
    links: [
      ["About", "#about"],
      ["Schedule", "#schedule"],
      ["Membership", "#membership"],
      ["Begin", "#contact"],
    ],
  },
];

export default function Footer() {
  return (
    <footer className="border-t border-[var(--line-dark)] bg-void px-6 pb-10 pt-16 md:px-10">
      <div className="mx-auto grid max-w-6xl gap-12 md:grid-cols-[2fr_1fr_1fr_1.3fr]">
        <div>
          <span className="flex items-center gap-2.5">
            <Image src={site.logoMark} alt="" width={28} height={28} className="h-7 w-7" />
            <span className="font-mono text-[12px] uppercase tracking-label text-ember">
              {site.full}
            </span>
          </span>
          <p className="mt-5 max-w-xs font-body text-[13px] leading-relaxed text-mist">
            A yoga, fitness and wellness academy in {site.city}. Ancient
            practice, modern transformation — body, breath and being, in balance.
          </p>
        </div>

        {cols.map((c) => (
          <div key={c.title}>
            <h2 className="eyebrow mb-5 text-ember">{c.title}</h2>
            {c.links.map(([label, href]) => (
              <a
                key={label}
                href={href}
                className="mb-2.5 block font-body text-[13px] text-mist transition-colors hover:text-bone"
              >
                {label}
              </a>
            ))}
          </div>
        ))}

        <div>
          <h2 className="eyebrow mb-5 text-ember">Visit &amp; connect</h2>
          <p className="mb-2.5 font-body text-[13px] text-mist">{site.city}</p>
          <p className="mb-2.5 font-body text-[13px] text-mist">{site.entity}</p>
          <a
            href={site.instagram}
            target="_blank"
            rel="noopener noreferrer"
            className="mb-2.5 block font-body text-[13px] text-mist transition-colors hover:text-bone"
          >
            Instagram
          </a>
          <a
            href={whatsappHref}
            target="_blank"
            rel="noopener noreferrer"
            className="block font-body text-[13px] text-mist transition-colors hover:text-bone"
          >
            WhatsApp · Enquire
          </a>
        </div>
      </div>

      <div className="mx-auto mt-14 flex max-w-6xl flex-wrap items-center justify-between gap-3 border-t border-[var(--line-dark)] pt-7">
        <p className="font-mono text-[11px] text-mist">
          © {new Date().getFullYear()} {site.full}
        </p>
        <p className="font-mono text-[11px] uppercase tracking-label text-ember">
          Align · Awaken · Ascend
        </p>
      </div>
    </footer>
  );
}
