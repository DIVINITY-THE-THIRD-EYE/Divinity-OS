import CtaLink from "@/components/ui/CtaLink";
import Magnetic from "@/components/Magnetic";
import BatchPickerCta from "./BatchPickerCta";
import { introOffer } from "@/content/offers";

/** Act III, section 8 — the last word before Footer. */
export default function FinalCta() {
  return (
    <section
      aria-labelledby="final-cta-heading"
      className="relative overflow-hidden border-t border-[var(--line-dark)] bg-void px-6 py-32 text-center md:px-10 md:py-44"
    >
      <div
        aria-hidden
        className="pointer-events-none absolute inset-0"
        style={{
          background:
            "radial-gradient(60% 60% at 50% 40%, rgba(124,58,237,0.14), transparent 65%)",
        }}
      />
      <div className="relative mx-auto max-w-2xl">
        <p className="eyebrow mb-6 text-ember">Begin today</p>
        <h2 id="final-cta-heading" className="font-display text-[clamp(40px,7vw,84px)] font-light leading-[0.95] tracking-tight text-bone">
          Your first <em className="text-ember">breath</em> with us.
        </h2>
        <p className="mx-auto mt-7 max-w-md font-body text-[16px] leading-relaxed text-mist">
          One message is all it takes — {introOffer.price} for your {introOffer.duration},
          no commitment. Tell us where you are, and we&apos;ll guide the first step.
        </p>
        <div className="mt-10 flex flex-wrap items-center justify-center gap-4">
          <Magnetic>
            <CtaLink href="/contact">Book a class — {introOffer.price} {introOffer.duration}</CtaLink>
          </Magnetic>
          <CtaLink href="/schedule" variant="ghost">
            See the schedule →
          </CtaLink>
        </div>
        <div className="mt-8">
          <BatchPickerCta />
        </div>
      </div>
    </section>
  );
}
