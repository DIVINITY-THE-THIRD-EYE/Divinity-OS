import { fetchOrFallback } from "@/lib/sanity";
import {
  disciplines as dDisciplines,
  plans as dPlans,
  testimonials as dTestimonials,
  trainers,
  posts,
  upcomingEvents,
  type Discipline,
  type Plan,
  type Testimonial,
} from "@/lib/content";

import BreathHero from "@/components/BreathHero";
import StatsBand from "@/components/StatsBand";
import Marquee from "@/components/Marquee";
import About from "@/components/About";
import Disciplines from "@/components/Disciplines";
import Method from "@/components/Method";
import Gallery from "@/components/Gallery";
import Membership from "@/components/Membership";
import TrustBadges from "@/components/TrustBadges";
import Newsletter from "@/components/Newsletter";
import Voices from "@/components/Voices";
import Faq from "@/components/Faq";

import PreviewSection from "@/components/layout/PreviewSection";
import TrainerCard from "@/components/cards/TrainerCard";
import CtaLink from "@/components/ui/CtaLink";
import EmptyState from "@/components/ui/EmptyState";

const DISCIPLINES_Q = `*[_type=="discipline"]|order(order asc){title,intention,description,tags}`;
const PLANS_Q = `*[_type=="plan"]|order(order asc){name,price,cadence,blurb,features,featured}`;
const TESTIMONIALS_Q = `*[_type=="testimonial"]|order(order asc){quote,name,meta}`;

export default async function Home() {
  const [disciplines, plans, testimonials] = await Promise.all([
    fetchOrFallback<Discipline[]>(DISCIPLINES_Q, dDisciplines),
    fetchOrFallback<Plan[]>(PLANS_Q, dPlans),
    fetchOrFallback<Testimonial[]>(TESTIMONIALS_Q, dTestimonials),
  ]);

  const events = upcomingEvents();

  return (
    <>
      <BreathHero />
      <StatsBand />
      <Marquee />

      {/* About preview */}
      <About />

      {/* Featured services — signature horizontal scroll */}
      <Disciplines items={disciplines} />
      <div className="border-t border-[var(--line-dark)] bg-void px-6 pb-24 text-center md:px-10 md:pb-32">
        <CtaLink href="/services" variant="outline">
          Explore every practice
        </CtaLink>
      </div>

      {/* The method */}
      <Method />

      {/* Featured trainers */}
      <PreviewSection
        eyebrow="Who guides you"
        title="Taught by"
        titleAccent="hand."
        cta={{ href: "/trainers", label: "Meet the team" }}
      >
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {trainers.slice(0, 3).map((t) => (
            <TrainerCard key={t.name} t={t} />
          ))}
        </div>
      </PreviewSection>

      {/* Gallery preview */}
      <PreviewSection
        eyebrow="The space"
        title="Where the practice"
        titleAccent="lives."
        cta={{ href: "/gallery", label: "Enter the space" }}
      >
        <Gallery limit={6} showHeading={false} />
      </PreviewSection>

      {/* Membership preview */}
      <Membership plans={plans} />
      <div className="bg-bone px-6 pb-24 text-center md:px-10 md:pb-32">
        <CtaLink href="/pricing" variant="outline" className="!text-ember-deep !border-ember-deep hover:!bg-ember-deep hover:!text-bone">
          See all plans & the plan finder
        </CtaLink>
      </div>

      {/* Trust / assurance band */}
      <TrustBadges />

      <Newsletter />

      {/* Testimonials — carousel when present, polished empty state otherwise */}
      {testimonials.length > 0 ? (
        <Voices items={testimonials} />
      ) : (
        <PreviewSection eyebrow="Voices" title="Member" titleAccent="stories.">
          <EmptyState
            title="Stories, coming soon"
            message="We're gathering reflections from our members. Real words from real practitioners will live here shortly."
          />
        </PreviewSection>
      )}

      {/* Latest blog preview */}
      <PreviewSection
        eyebrow="Journal"
        title="From the"
        titleAccent="mat."
        cta={{ href: "/blog", label: "Read the journal" }}
      >
        {posts.length > 0 ? (
          <div className="grid gap-6 md:grid-cols-3">
            {posts.slice(0, 3).map((p) => (
              <article key={p.slug} className="border border-[var(--line-dark)] p-7">
                <h3 className="font-display text-2xl text-bone">{p.title}</h3>
                <p className="mt-3 font-body text-[14px] text-mist">{p.excerpt}</p>
              </article>
            ))}
          </div>
        ) : (
          <EmptyState
            title="The journal opens soon"
            message="Guides on breath, posture, recovery and the philosophy behind the practice are on their way."
            cta={{ href: "/blog", label: "Visit the journal" }}
          />
        )}
      </PreviewSection>

      {/* Upcoming events preview */}
      <PreviewSection
        eyebrow="What's next"
        title="Upcoming"
        titleAccent="gatherings."
        cta={{ href: "/events", label: "All events" }}
      >
        {events.length > 0 ? (
          <div className="grid gap-6 md:grid-cols-3">
            {events.slice(0, 3).map((e) => (
              <article key={e.slug} className="border border-[var(--line-dark)] p-7">
                <h3 className="font-display text-2xl text-bone">{e.title}</h3>
                <p className="mt-3 font-body text-[14px] text-mist">{e.summary}</p>
              </article>
            ))}
          </div>
        ) : (
          <EmptyState
            title="No events scheduled yet"
            message="Workshops, retreats and community gatherings will be announced here. Join the mailing list to hear first."
            cta={{ href: "/events", label: "See events" }}
          />
        )}
      </PreviewSection>

      {/* FAQ preview */}
      <Faq limit={4} />
      <div className="bg-bone px-6 pb-24 text-center md:px-10 md:pb-32">
        <CtaLink href="/contact" variant="outline" className="!text-ember-deep !border-ember-deep hover:!bg-ember-deep hover:!text-bone">
          Have a question? Talk to us
        </CtaLink>
      </div>

      {/* Final CTA */}
      <section className="relative overflow-hidden border-t border-[var(--line-dark)] bg-void px-6 py-32 text-center md:px-10 md:py-44">
        <div
          aria-hidden
          className="pointer-events-none absolute inset-0"
          style={{
            background:
              "radial-gradient(60% 60% at 50% 40%, rgba(208,138,62,0.14), transparent 65%)",
          }}
        />
        <div className="relative mx-auto max-w-2xl">
          <p className="eyebrow mb-6 text-ember">Begin today</p>
          <h2 className="font-display text-[clamp(40px,7vw,84px)] font-light leading-[0.95] tracking-tight text-bone">
            Your first <em className="text-ember">breath</em> with us.
          </h2>
          <p className="mx-auto mt-7 max-w-md font-body text-[16px] leading-relaxed text-mist">
            One message is all it takes. Tell us where you are, and we&apos;ll
            guide the first step.
          </p>
          <div className="mt-10 flex flex-wrap items-center justify-center gap-4">
            <CtaLink href="/contact">Book a class — ₹99 first week</CtaLink>
            <CtaLink href="/schedule" variant="ghost">
              See the schedule →
            </CtaLink>
          </div>
        </div>
      </section>
    </>
  );
}
