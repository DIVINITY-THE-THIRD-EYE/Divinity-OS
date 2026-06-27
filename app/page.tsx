import SmoothScroll from "@/components/SmoothScroll";
import Cursor from "@/components/Cursor";
import Ambient from "@/components/Ambient";
import ScrollProgress from "@/components/ScrollProgress";
import IntroCurtain from "@/components/IntroCurtain";
import CommandPalette from "@/components/CommandPalette";
import WhatsAppFab from "@/components/WhatsAppFab";
import Nav from "@/components/Nav";
import PromoBar from "@/components/PromoBar";
import StickyCta from "@/components/StickyCta";
import BreathHero from "@/components/BreathHero";
import StatsBand from "@/components/StatsBand";
import Marquee from "@/components/Marquee";
import Manifesto from "@/components/Manifesto";
import About from "@/components/About";
import Disciplines from "@/components/Disciplines";
import Gallery from "@/components/Gallery";
import Method from "@/components/Method";
import Schedule from "@/components/Schedule";
import Membership from "@/components/Membership";
import PlanCalculator from "@/components/PlanCalculator";
import Newsletter from "@/components/Newsletter";
import Voices from "@/components/Voices";
import Faq from "@/components/Faq";
import Contact from "@/components/Contact";
import Footer from "@/components/Footer";

import { fetchOrFallback } from "@/lib/sanity";
import {
  disciplines as dDisciplines,
  plans as dPlans,
  testimonials as dTestimonials,
  schedule,
  type Discipline,
  type Plan,
  type Testimonial,
} from "@/lib/content";

// GROQ — used only when a Sanity project is configured; otherwise the
// local content in lib/content.ts is returned by fetchOrFallback.
const DISCIPLINES_Q = `*[_type=="discipline"]|order(order asc){title,intention,description,tags}`;
const PLANS_Q = `*[_type=="plan"]|order(order asc){name,price,cadence,blurb,features,featured}`;
const TESTIMONIALS_Q = `*[_type=="testimonial"]|order(order asc){quote,name,meta}`;

export default async function Page() {
  const [disciplines, plans, testimonials] = await Promise.all([
    fetchOrFallback<Discipline[]>(DISCIPLINES_Q, dDisciplines),
    fetchOrFallback<Plan[]>(PLANS_Q, dPlans),
    fetchOrFallback<Testimonial[]>(TESTIMONIALS_Q, dTestimonials),
  ]);

  return (
    <>
      <IntroCurtain />
      <Ambient />
      <ScrollProgress />
      <SmoothScroll />
      <Cursor />
      <CommandPalette />
      <PromoBar />
      <Nav />

      <main>
        <BreathHero />
        <StatsBand />
        <Marquee />
        <Manifesto />
        <About />
        <Disciplines items={disciplines} />
        <Gallery />
        <Method />
        <Schedule data={schedule} />
        <Membership plans={plans} />
        <PlanCalculator />
        <Newsletter />
        <Voices items={testimonials} />
        <Faq />
        <Contact />
        <Footer />
      </main>

      <WhatsAppFab />
      <StickyCta />
    </>
  );
}
