import { fetchOrFallback } from "@/lib/sanity";
import {
  disciplines as dDisciplines,
  testimonials as dTestimonials,
  type Discipline,
  type Testimonial,
} from "@/lib/content";

import Hero from "@/components/home/Hero";
import AboutStrip from "@/components/home/AboutStrip";
import Programs from "@/components/home/Programs";
import Benefits from "@/components/home/Benefits";
import Trainer from "@/components/home/Trainer";
import Voices from "@/components/Voices";
import GalleryPreview from "@/components/home/GalleryPreview";
import FinalCta from "@/components/home/FinalCta";
import CtaLink from "@/components/ui/CtaLink";

const DISCIPLINES_Q = `*[_type=="discipline"]|order(order asc){title,intention,description,tags}`;
const TESTIMONIALS_Q = `*[_type=="testimonial"]|order(order asc){quote,name,meta}`;

// 9-section homepage (D001 three acts). Section order is exact — see
// WEBSITE_REBUILD/04_HOMEPAGE.md. Footer (section 9) is shared chrome, mounted
// once in app/(marketing)/layout.tsx, not repeated here.
export default async function Home() {
  const [disciplines, testimonials] = await Promise.all([
    fetchOrFallback<Discipline[]>(DISCIPLINES_Q, dDisciplines),
    fetchOrFallback<Testimonial[]>(TESTIMONIALS_Q, dTestimonials),
  ]);

  return (
    <>
      {/* Act I */}
      <Hero />
      <AboutStrip />
      <Programs items={disciplines} />
      <div className="border-t border-[var(--line-dark)] bg-void px-6 pb-24 text-center md:px-10 md:pb-32">
        <CtaLink href="/services" variant="outline">
          Explore every practice
        </CtaLink>
      </div>

      {/* Act II */}
      <Benefits />
      <Trainer />

      {/* Act III — Voices renders nothing when there are no real testimonials yet */}
      {testimonials.length > 0 && <Voices items={testimonials} />}
      <GalleryPreview />
      <FinalCta />
    </>
  );
}
