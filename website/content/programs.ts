// The six disciplines taught, and the three-step method that frames them.

export type Discipline = {
  title: string;
  intention: "For the body" | "For the breath" | "For healing";
  description: string;
  tags: string[];
};

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
