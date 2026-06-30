// Single source of truth for site content.
// When Sanity is configured (see lib/sanity.ts), matching documents
// override these values. Until then, the site renders from here.

export type Discipline = {
  title: string;
  intention: "For the body" | "For the breath" | "For healing";
  description: string;
  tags: string[];
};

export type Plan = {
  name: string;
  price: string;
  cadence: string;
  blurb: string;
  features?: string[];
  featured?: boolean;
};

export type ClassSlot = {
  time: string;
  batch: "Dawn" | "Midday" | "Dusk";
  name: string;
  detail: string;
  level: string;
};

export type Testimonial = {
  quote: string;
  name: string;
  meta: string;
};

export const site = {
  name: "Divinity",
  full: "Divinity — The Third Eye",
  city: "Lucknow, Uttar Pradesh",
  entity: "Amaratv Krishi LLP",
  founder: "Sachin Rajvanshi",
  founderRole: "Founder & Guide",
  founderImage: "/founder.webp",
  est: "2024",
  url: "https://divinity.example", // ← set to your real domain before launch
  // Brand marks (see public/brand)
  logoMark: "/brand/logo-mark.png", // ember lotus, transparent — for dark surfaces
  logoFull: "/brand/logo-full.png", // full lockup with wordmark — for light surfaces
  // Placeholders — replace with the academy's real numbers/handles
  phone: "+91 90000 00000",
  whatsapp: "919000000000", // digits only, for wa.me links
  instagram: "https://instagram.com/",
};

// UPI payment (see public/payment-qr.png). Replace the QR with the academy's
// own before launch — the bank/handle below should match the real account.
export const payment = {
  bank: "UCO Bank",
  qr: "/payment-qr.png",
  note: "Scan with any UPI app — GPay, PhonePe, Paytm — then share a screenshot to confirm your enrolment.",
};

// Trust signals / assurance badges. Keep these TRUTHFUL — each one below is
// grounded in a real fact already on this site (verified UPI flow, the founder,
// small batches, a registered LLP, privacy-by-design). Edit freely, but don't
// invent certifications the academy doesn't actually hold.
export type Assurance = {
  icon: "shield" | "guide" | "users" | "lock" | "spark" | "badge";
  title: string;
  detail: string;
};

export const assurances: Assurance[] = [
  {
    icon: "shield",
    title: "Secure UPI payments",
    detail: "Every payment is verified by our team and a receipt is issued — no hidden auto-charges.",
  },
  {
    icon: "guide",
    title: "Guided by the founder",
    detail: `Personal guidance from ${site.founder} and our instructors, not a faceless app.`,
  },
  {
    icon: "users",
    title: "Small, focused batches",
    detail: "Dawn, midday and dusk batches are kept small so you get real, hands-on attention.",
  },
  {
    icon: "lock",
    title: "Your data stays private",
    detail: "Health and contact details are access-controlled and never sold or shared.",
  },
  {
    icon: "spark",
    title: "Risk-free first week",
    detail: "Begin your practice with a ₹99 first week before you commit to a plan.",
  },
  {
    icon: "badge",
    title: "A registered academy",
    detail: "Run by Amaratv Krishi LLP, serving Lucknow since 2024.",
  },
];

// Practice words for the kinetic marquee (a little Sanskrit, on theme)
export const mantra = [
  "Breathe",
  "आसन",
  "Move",
  "प्राण",
  "Heal",
  "ध्यान",
  "Align",
  "Awaken",
  "Ascend",
];

export const faqs = [
  {
    q: "I've never practised yoga. Can I still join?",
    a: "Yes. Most members start as complete beginners. Dawn and dusk batches are all-levels, and your first sessions are paced gently while you learn the foundations of breath and posture.",
  },
  {
    q: "Do you teach fitness, or only yoga?",
    a: "Both. Alongside Hatha and Vinyasa yoga we run strength, conditioning and mobility training — and most members blend the two. Your plan is shaped around your goals.",
  },
  {
    q: "I have an injury or a medical condition. Is that a problem?",
    a: "Not at all — it's exactly what therapeutic yoga is for. We build a gentle, restorative practice around your history and limits. Please share details when you enquire so we can prepare.",
  },
  {
    q: "How do payments work?",
    a: "Pay by UPI and confirm with a screenshot — there's no card gateway required. Monthly, quarterly and annual memberships are available, plus a single drop-in class if you'd like to feel the space first.",
  },
  {
    q: "Where are you located?",
    a: "We're in Lucknow, Uttar Pradesh. Reach out via the enquiry form or WhatsApp and we'll share the exact address and the best batch for you.",
  },
];

export const manifestoLines = [
  "Before the body moves, the breath moves.",
  "Before the mind settles, the breath settles.",
  "We do not chase the body —",
  "we follow the breath inward,",
  "until practice becomes presence.",
];

export const disciplines: Discipline[] = [
  {
    title: "Hatha & Vinyasa Yoga",
    intention: "For the body",
    description:
      "Traditional asana, breath and flow. Build flexibility, strength and a steady mind through practice rooted in lineage.",
    tags: ["All levels", "Dawn & dusk"],
  },
  {
    title: "Fitness Training",
    intention: "For the body",
    description:
      "Strength, conditioning and mobility, programmed to your body and your goals — structured, progressive, guided throughout.",
    tags: ["Strength", "Conditioning"],
  },
  {
    title: "Pranayama & Meditation",
    intention: "For the breath",
    description:
      "The science of breath. Learn to lengthen, hold and direct the breath — the bridge between effort and stillness.",
    tags: ["Breathwork", "Stillness"],
  },
  {
    title: "Wellness Programs",
    intention: "For the breath",
    description:
      "Holistic cycles blending movement, breath, meditation and rest — structured journeys that change how you feel and live.",
    tags: ["Holistic", "Cyclical"],
  },
  {
    title: "Therapeutic Yoga",
    intention: "For healing",
    description:
      "Gentle, restorative practice for injury recovery and chronic conditions — shaped around your history and your limits.",
    tags: ["Recovery", "By appointment"],
  },
  {
    title: "Diet & Lifestyle",
    intention: "For healing",
    description:
      "Nutrition, sleep and daily rhythm. Long-term guidance to build a life that sustains your wellbeing beyond the mat.",
    tags: ["Nutrition", "Long-term"],
  },
];

export const method = [
  {
    step: "01",
    name: "Align",
    body: "We read your body, your health and your goals — then set a foundation of posture and breath built for you alone.",
  },
  {
    step: "02",
    name: "Awaken",
    body: "Practice deepens. Strength builds, stiffness releases, awareness grows. This is where the real change begins.",
  },
  {
    step: "03",
    name: "Ascend",
    body: "Wellbeing becomes a way of living. You carry the practice off the mat and into every ordinary hour of the day.",
  },
];

export const schedule: Record<string, ClassSlot[]> = {
  Mon: [
    { time: "6:00", batch: "Dawn", name: "Hatha Yoga", detail: "Asana & breath", level: "All levels" },
    { time: "11:00", batch: "Midday", name: "Therapeutic Yoga", detail: "Recovery focus", level: "By appt" },
    { time: "18:30", batch: "Dusk", name: "Strength Training", detail: "Resistance work", level: "All levels" },
  ],
  Tue: [
    { time: "6:00", batch: "Dawn", name: "Vinyasa Flow", detail: "Dynamic sequence", level: "Intermediate" },
    { time: "18:30", batch: "Dusk", name: "Pranayama", detail: "Breath & meditation", level: "Open" },
  ],
  Wed: [
    { time: "6:00", batch: "Dawn", name: "Hatha Yoga", detail: "Asana & breath", level: "All levels" },
    { time: "11:00", batch: "Midday", name: "Therapeutic Yoga", detail: "Recovery focus", level: "By appt" },
    { time: "18:30", batch: "Dusk", name: "Conditioning", detail: "Endurance circuit", level: "All levels" },
  ],
  Thu: [
    { time: "6:00", batch: "Dawn", name: "Vinyasa Flow", detail: "Dynamic sequence", level: "Intermediate" },
    { time: "18:30", batch: "Dusk", name: "Power Yoga", detail: "Strength & heat", level: "All levels" },
  ],
  Fri: [
    { time: "6:00", batch: "Dawn", name: "Hatha Yoga", detail: "Asana & breath", level: "All levels" },
    { time: "11:00", batch: "Midday", name: "Therapeutic Yoga", detail: "Recovery focus", level: "By appt" },
    { time: "18:30", batch: "Dusk", name: "Mobility", detail: "Joints & flexibility", level: "All levels" },
  ],
  Sat: [
    { time: "6:00", batch: "Dawn", name: "Meditation & Pranayama", detail: "Stillness practice", level: "Open" },
    { time: "18:30", batch: "Dusk", name: "Community Workshop", detail: "Rotating theme", level: "Open" },
  ],
};

export const plans: Plan[] = [
  {
    name: "The Devotee",
    price: "₹3,900",
    cadence: "per quarter",
    blurb: "All disciplines, three months. The complete practice.",
    features: [
      "All yoga & fitness batches",
      "Personalised diet plan",
      "Therapeutic sessions included",
      "Progress & milestone tracking",
      "Priority workshop access",
    ],
    featured: true,
  },
  {
    name: "The Seeker",
    price: "₹1,500",
    cadence: "per month",
    blurb: "One discipline, monthly. The simplest way to begin.",
  },
  {
    name: "The Yogi",
    price: "₹12,000",
    cadence: "per year",
    blurb: "Full annual access, one-on-one guidance, retreats & alumni circle.",
  },
  {
    name: "Drop-in",
    price: "₹200",
    cadence: "per class",
    blurb: "A single class, to feel the space before you commit.",
  },
];

// The space & the practice — real photography from the academy in Lucknow.
// Images live in public/studio and public/guru. width/height are the source
// dimensions so next/image reserves space (no layout shift).
export type GalleryShot = {
  src: string;
  alt: string;
  w: number;
  h: number;
};

export const studioGallery: GalleryShot[] = [
  { src: "/studio/yc_18.webp", alt: "The practice hall, set beneath the studio's lotus emblem", w: 6000, h: 4000 },
  { src: "/studio/yc_8.webp", alt: "The lamp-lit entrance to Divinity in Lucknow", w: 4000, h: 6000 },
  { src: "/guru/guru_9.webp", alt: "A bound headstand, held with control before the class", w: 1141, h: 1141 },
  { src: "/studio/yc_24.webp", alt: "Reception — where every visit to the academy begins", w: 4000, h: 6000 },
  { src: "/studio/yc_12.webp", alt: "Mats rolled and ready for the next breath", w: 6000, h: 4000 },
  { src: "/guru/guru_5.webp", alt: "Rooted in lineage — the asana as it has long been taught", w: 1140, h: 895 },
  { src: "/studio/yc_10.webp", alt: "A corner of calm — water, shrine and props for therapeutic work", w: 6000, h: 4000 },
  { src: "/studio/yc_5.webp", alt: "Blocks, bolsters and props for supported practice", w: 4000, h: 6000 },
];

// Real member stories only. Empty until verified testimonials are collected —
// the UI shows a polished "coming soon" state rather than fabricated quotes.
export const testimonials: Testimonial[] = [];

// ── Routing / slugs ───────────────────────────────────────────────
/** URL-safe slug from any title (used for /services/[slug] etc.). */
export function slugify(input: string): string {
  return input
    .toLowerCase()
    .replace(/&/g, "and")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

export const disciplineSlug = (d: Discipline) => slugify(d.title);
export const getDisciplineBySlug = (slug: string) =>
  disciplines.find((d) => disciplineSlug(d) === slug);

// ── Trainers ──────────────────────────────────────────────────────
// Add real teachers here as bios are confirmed. The Trainers page renders
// whatever exists and shows an empty state for the rest — never fabricated.
export type Trainer = {
  name: string;
  role: string;
  image?: string;
  bio: string;
  focus?: string[];
};

export const trainers: Trainer[] = [
  {
    name: site.founder,
    role: site.founderRole,
    image: site.founderImage,
    bio: "Sachin Rajvanshi founded Divinity to bring breath-led yoga, fitness and therapeutic practice together under one roof in Lucknow — meeting each student where they are and guiding them, patiently, toward where they wish to be.",
    focus: ["Hatha & Vinyasa", "Pranayama", "Therapeutic yoga"],
  },
];

// ── Blog ──────────────────────────────────────────────────────────
// CMS-ready. Empty by design — the /blog routes render an empty state until
// real articles are published. No placeholder posts.
export type Post = {
  slug: string;
  title: string;
  excerpt: string;
  body: string;
  date: string; // ISO
  author: string;
  cover?: string;
  tags?: string[];
};

export const posts: Post[] = [];
export const getPostBySlug = (slug: string) => posts.find((p) => p.slug === slug);

// ── Events ────────────────────────────────────────────────────────
// CMS-ready. Empty by design — the /events routes render an empty state.
export type EventItem = {
  slug: string;
  title: string;
  summary: string;
  body: string;
  date: string; // ISO start
  endDate?: string;
  location: string;
  cover?: string;
};

export const events: EventItem[] = [];
export const getEventBySlug = (slug: string) => events.find((e) => e.slug === slug);

/** Upcoming events, soonest first (today onward). */
export const upcomingEvents = () => {
  const now = Date.now();
  return events
    .filter((e) => new Date(e.date).getTime() >= now)
    .sort((a, b) => +new Date(a.date) - +new Date(b.date));
};
