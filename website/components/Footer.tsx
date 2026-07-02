"use client";

import Image from "next/image";
import Link from "next/link";
import { site } from "@/lib/content";
import { footerGroups, legalItems } from "@/lib/nav";
import { waHref } from "@/lib/links";
import { useLocale } from "@/lib/i18n/LocaleContext";

export default function Footer({ site: siteProp }: { site?: typeof site }) {
  const activeSite = siteProp || site;
  const { t } = useLocale();
  const whatsappHref = waHref("Namaste — I'd like to know more about practising at Divinity.", activeSite.whatsapp);

  return (
    <footer className="border-t border-[var(--line-dark)] bg-void px-6 pb-10 pt-16 md:px-10">
      <div className="mx-auto grid max-w-6xl gap-12 md:grid-cols-[2fr_1fr_1fr_1.3fr]">
        <div>
          <Link href="/" className="flex items-center gap-2.5" aria-label={`${activeSite.full} — home`}>
            <Image src={activeSite.logoMark} alt="" width={28} height={28} className="h-7 w-7" />
            <span className="font-mono text-[12px] uppercase tracking-label text-ember">
              {activeSite.full}
            </span>
          </Link>
          <p className="mt-5 max-w-xs font-body text-[13px] leading-relaxed text-mist">
            A yoga, fitness and wellness academy in {activeSite.city}. Ancient
            practice, modern transformation — body, breath and being, in balance.
          </p>
        </div>

        {footerGroups.map((c) => (
          <div key={c.title}>
            <h2 className="eyebrow mb-5 text-ember">{t(c.title)}</h2>
            {c.items.map((l) => (
              <Link
                key={l.href}
                href={l.href}
                className="mb-2.5 block font-body text-[13px] text-mist transition-colors hover:text-bone"
              >
                {t(l.label)}
              </Link>
            ))}
          </div>
        ))}

        <div>
          <h2 className="eyebrow mb-5 text-ember">{t("Visit & connect")}</h2>
          <p className="mb-2.5 font-body text-[13px] text-mist">{activeSite.city}</p>
          <p className="mb-2.5 font-body text-[13px] text-mist">{activeSite.entity}</p>
          <Link
            href="/contact"
            className="mb-2.5 block font-body text-[13px] text-mist transition-colors hover:text-bone"
          >
            {t("Contact & enquire")}
          </Link>
          <a
            href={activeSite.instagram}
            target="_blank"
            rel="noopener noreferrer"
            className="mb-2.5 block font-body text-[13px] text-mist transition-colors hover:text-bone"
          >
            {t("Instagram")}
          </a>
          <a
            href={whatsappHref}
            target="_blank"
            rel="noopener noreferrer"
            className="block font-body text-[13px] text-mist transition-colors hover:text-bone"
          >
            {t("WhatsApp")}
          </a>
        </div>
      </div>

      <div className="mx-auto mt-14 flex max-w-6xl flex-col gap-4 border-t border-[var(--line-dark)] pt-7 md:flex-row md:items-center md:justify-between">
        <p className="font-mono text-[11px] text-mist">
          © <span suppressHydrationWarning>{new Date().getFullYear()}</span> {activeSite.full}
        </p>
        <div className="flex flex-wrap items-center gap-x-5 gap-y-2">
          {legalItems.map((l) => (
            <Link
              key={l.href}
              href={l.href}
              className="font-mono text-[11px] text-mist transition-colors hover:text-bone"
            >
              {t(l.label)}
            </Link>
          ))}
          <span className="font-mono text-[11px] uppercase tracking-label text-ember">
            Align · Awaken · Ascend
          </span>
        </div>
      </div>
    </footer>
  );
}
